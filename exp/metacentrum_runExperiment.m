function metacentrum_runExperiment(settingFiles, data, expname, walltime, numOfMachines)
% Tests settings in 'settingFiles' od 'data' and names the experiment as 
% 'expname'.
%
% Input:
%    settingFiles  - m-file or cell array of m-files with settings of
%                    classifiers | string (cell array of strings)
%    data          - char or cell array of char containing path(s) to data
%                    that should be tested | string (cell array of strings)
%    expname       - name of the experiment | string
%    walltime      - maximum (wall)time for Metacentrum machines | string
%                    ('4h', '1d', '2d', ...)
%    numOfMachines - number of machines in Metacentrum | integer
%
% See Also:
% runExperiment createExperiment

%  cd(fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy'))
  
%  startup

  % initialization
  if nargin < 1
    help metacentrum_runExperiment
    return
  end
  if nargin == 1
    eval(settingFiles)
  end
 
  metafolder = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy')];
 
  if ~exist('data', 'var')
    data = fullfile('data', 'data_FC_190subjects.mat');
  end
  if ~exist('expname', 'var')
    expname = ['exp_', data, '_', char(datetime)];
  end
  if ~exist('walltime', 'var')
    walltime = '4h'; 
  end
  if ~exist('numOfMachines', 'var')
    numOfMachines = 10; 
  end
  
  if ~iscell(settingFiles)
    settingFiles = {settingFiles};
  end
  if ~iscell(data)
    data = {data};
  end
  
  expfolder = fullfile('exp', 'experiments');
  foldername = fullfile(expfolder, expname);
  scriptname = fullfile(foldername, [expname, '.m']);

  % data check
  missing = ~((cellfun(@(x) exist(x, 'file'), data)) | (cellfun(@isdir, data)));
  fprintf('missing: %d\n', missing)

  % omit missing data
  if all(missing)
    error('There is no data for computing. Check if all data files and folders are correctly specified.')
  elseif any(missing)
    fprintf('Omitting missing data files:\n')
    cellfun(@(x) fprintf('%s\n', x), data(missing))
    fprintf('\n')
    data = data(~missing);
  end  

  % if experiment was not created yet
  if ~isdir(foldername) || ~exist(scriptname, 'file')
    data = cellfun(@(x) fullfile(metafolder, x), data, 'UniformOutput', false);
    createExperiment(expfolder, expname, settingFiles, data)
    fprintf('Experiment created\n')
  end
  
  % metacentrum settings
  pbs_max_workers = 50;
  pbs_params = ['-l walltime=', walltime, ',nodes=^N^:ppn=1,mem=1gb,scratch=1gb,matlab_MATLAB_Distrib_Comp_Engine=^N^'];

  % licence loop
  while 1
    [tf, ~] = license('checkout','Distrib_Computing_Toolbox');
    if tf == 1
      break
    end
    display(strcat(datestr(now),' waiting for licence '));
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
  for id = 1:numOfMachines
    fprintf('Setting up job ID %d / %d ...\n', id, numOfMachines);
    tasks(id) = createTask(job, @metacentrum_task, 0, {expname, id});
  end

  tasks

  % submit job
  submit(job)
  
end
