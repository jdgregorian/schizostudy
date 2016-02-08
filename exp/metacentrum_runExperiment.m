function metacentrum_runExperiment(expname, walltime, taskIDs)
% Tests settings in 'settingFiles' od 'data' and names the experiment as 
% 'expname'.
%
% Input:
%   expname       - name of the experiment | string
%   walltime      - maximum (wall)time for Metacentrum machines | string
%                   ('4h', '1d', '2d', ...)
%   numOfMachines - number of machines in Metacentrum | integer
%
% See Also:
%   runExperiment, createExperiment

%  cd(fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy'))
  
%  startup

  % initialization
  if nargin < 3
    taskIDs = [];
    if nargin < 2
      walltime = '4h';
        if nargin < 1
          help metacentrum_runExperiment
          return
        end
    end
  end
  
  % uncomment for metacentrum
%   metafolder = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy')];
  metafolder = '';
  
  expfolder = fullfile('exp', 'experiments');
  foldername = fullfile(expfolder, expname);
  scriptname = fullfile(foldername, [expname, '_runscript.m']);

  % if experiment was not created yet
  if ~isdir(foldername) || ~exist(scriptname, 'file')
    expContent = fileread([foldername, '.m']);
    % extract row with runExperiment function call without runExperiment
    % itself
    runExpId = strfind(expContent, 'runExperiment(');
    runExpRow = expContent(runExpId+14 : end);
    newLineIds = strfind(runExpRow, char(13));
    runExpRow = runExpRow(1: newLineIds(1));
    % delete white spaces, brackets, semicolons
    runExpRow([strfind(runExpRow, ' '), strfind(runExpRow, ')'), strfind(runExpRow, ';')]) = [];
    % check presence of brackets - could cause problems during splitting
    if isempty(runExpRow)|| ~(isempty(strfind(runExpRow, '[')) && isempty(strfind(runExpRow, '{')))
      warning('Rewrite (or add) runExperiment function call in experiment file not to include ''['' or ''{''')
      fprintf('Aborting metacentrum_runExperiment')
      return
    end
    % split to variables
    expVarNames = strsplit(runExpRow, ',');
    % evaluate experiment settings
    expSet = secureEval(expContent(1:runExpId - 1), expVarNames);
    data = expSet.data;
    
    % data check
    missing = ~((cellfun(@(x) exist(x, 'file'), data)) | (cellfun(@isdir, data)));
  
    % omit missing data
    if all(missing)
      error('There is no data for computing. Check if all data files and folders are correctly specified.')
    elseif any(missing)
      fprintf('missing: %d\n', length(missing))
      fprintf('Omitting missing data files:\n')
      cellfun(@(x) fprintf('%s\n', x), data(missing))
      fprintf('\n')
      data = data(~missing);
    end 
    
    data = cellfun(@(x) fullfile(metafolder, x), data, 'UniformOutput', false);
    createExperiment(expfolder, expSet.expname, expSet.settingFiles, data, expSet.addSettings)
    fprintf('Experiment created\n')
  end
  
  % load individual settings
  settings = loadSettings({scriptname});
  nLoadedTasks = length(settings);
  if isempty(taskIDs)
    taskIDs = 1:nLoadedTasks;
  else
    taskIDs(taskIDs > nLoadedTasks) = [];
  end
  nTasks = length(taskIDs);
  
  % the rest is commented for debugging
  
  % metacentrum settings
  pbs_max_workers = 50;
  pbs_params = ['-l walltime=', walltime, ',nodes=^N^:ppn=1,mem=1gb,scratch=1gb,matlab_MATLAB_Distrib_Comp_Engine=^N^'];

  % licence loop
  while 1
    [tf, ~] = license('checkout', 'Distrib_Computing_Toolbox');
    if tf == 1
      break
    end
    display(strcat(datestr(now), ' waiting for licence '));
    pause(4);
  end

  % job settings
  cl = parallel.cluster.Torque;
  pause(2);
  if ~isdir(fullfile(foldername, 'matlab_jobs'))
    mkdir(fullfile(foldername, 'matlab_jobs'))
  end
  cl.JobStorageLocation = fullfile(foldername, 'matlab_jobs');
  cl.ClusterMatlabRoot = matlabroot;
  cl.OperatingSystem = 'unix';
  cl.ResourceTemplate = pbs_params;
  cl.HasSharedFilesystem = true;
  cl.NumWorkers = pbs_max_workers;

  job = createJob(cl);

  % tasks creating
  for t = 1:nTasks
    id = taskIDs(t);
    fprintf('Setting up job ID %d / %d ...\n', id, nLoadedTasks);
    tasks(t) = createTask(job, @metacentrum_task, 0, {expname, id, settings{id}});
  end

  tasks

  % submit job
  submit(job)
  
end

function var = secureEval(expression, variables)
% function for secure evaluation
% if cell array 'variables' is not empty, return their values in structure
% var (for experiment settings use only)

  var = [];

  eval(expression)
  
  if nargin > 1
    % assign variable values to appropriate variables
    eval(['var.settingFiles = ', variables{1}, ';'])
    if ~iscell(var.settingFiles)
      var.settingFiles = {var.settingFiles};
    end
    eval(['var.data = ', variables{2}, ';'])
    if ~iscell(var.data)
      var.data = {var.data};
    end
    eval(['var.expname = ', variables{3}, ';'])
    if length(variables) > 3
      eval(['var.addSettings = ', variables{4}, ';'])
    else
      var.addSettings = '';
    end
  end

end
