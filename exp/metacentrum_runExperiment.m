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

  cd(fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy'))
  
  startup

  % initialization
  if nargin < 1
    help metacentrum_runExperiment
    return
  end
  if nargin == 1
    eval(settingFiles)
  end
  
  if ~exist(data, 'var')
    data = fullfile('data', 'data_FC_190subjects.mat');
  end
  if ~exist(expname, 'var')
    expname = ['exp_', data, '_', char(datetime)];
  end
  if ~exist(walltime, 'var')
    walltime = '4h';
  end
  if ~exist(numOfMachines, 'var')
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
  
  % if experiment was not created yet
  if ~isdir(foldername) || ~exist(scriptname, 'file')
    createExperiment(expfolder, expname, settingFiles, data)
  end
  
  % metacentrum settings
  pbs_max_workers = 50;
  pbs_params = ['-l walltime=', walltime, ',nodes=^N^:ppn=1,mem=1gb,scratch=1gb,matlab_MATLAB_Distrib_Comp_Engine=^N^'];

  % licence loop
  while 1
    tf = license('checkout','Distrib_Computing_Toolbox');
    if tf == 1
      break
    end
    display(strcat(datestr(now),' waiting for licence '));
    pause(4);
  end

  % job settings
  cl = parallel.cluster.Torque;
  pause(2);
  mkdir(fullfile(foldername,'matlab_jobs'))
  cl.JobStorageLocation = fullfile(foldername,'matlab_jobs');
  cl.ClusterMatlabRoot = matlabroot;
  cl.OperatingSystem = 'unix';
  cl.ResourceTemplate = pbs_params;
  cl.HasSharedFilesystem = true;
  cl.NumWorkers = pbs_max_workers;

  job = createJob(cl);

  % tasks creating
  for id = 1:numOfMachines
%     [bbParams, sgParams] = getParamsFromIndex(id, bbParamDef, sgParamDef, cmParamDef);
%     fileID = [num2str(bbParams.functions(end)) '_' num2str(bbParams.dimensions(end)) 'D_' num2str(id)];
%     if (isfield(sgParams, 'modelType'))
%       model = sgParams.modelType;
%     else
%       model = 'NONE';
%     end
% 
%     metaOpts.logdir = logDir;
%     metaOpts.model = model;
%     metaOpts.nInstances = length(bbParams.instances);
    fprintf('Setting up job ID %d / %d ...\n', id, numOfMachines);
    tasks(id) = createTask(job, @metacentrum_task, 0, {id, settingFiles, data, expname});
  end

  tasks

  % submit job
  submit(job)
  
end