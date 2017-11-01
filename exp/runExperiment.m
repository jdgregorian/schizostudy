function runExperiment(experimentFile, data, expname, addSettings, metacentrum)
% runExperiment(settingFiles, data, expname, addSettings, metacentrum) 
% tests settings in 'settingFiles' on 'data' and names the experiment as 
% 'expname'.
%
% runExperiment(experimentFile) runs experiment set in 'experimentFile'
%
% Input:
%   settingFiles - m-file or cell array of m-files with settings of
%                  classifiers
%   data         - char or cell array of char containing path(s) to data
%                  that should be tested
%   expname      - name of the experiment
%   addSettings  - additional settings for each settings from
%                  'settingFiles' | string or cell array of strings
%   metacentrum  - whether the experiment is running on metacentrum 
%                  | logical
%
% See Also:
%   metacentrum_runExperiment, createExperiment

  % initialization
  if nargin < 1
    help runExperiment
    return
  end
  if nargin == 1
    eval(experimentFile)
  else
    settingFiles = experimentFile;
  end
  
  % input check
  if ~exist('data', 'var')
    data = fullfile('data', 'data_FC_190subjects.mat');
  end
  if ~exist('expname', 'var')
    expname = ['exp_', data, '_', char(datetime)];
  end
  if ~exist('addSettings', 'var')
    addSettings = {''};
  end
  if ~exist('metacentrum', 'var')
    metacentrum = false;
  end
  
  if ~iscell(settingFiles)
    settingFiles = {settingFiles};
  end
  if ~iscell(data)
    data = {data};
  end
  
  % setting paths
  if metacentrum
    metafolder = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy')]; 
  else
    metafolder = '';
  end
  expfolder = fullfile(metafolder, 'exp', 'experiments');  
  foldername = fullfile(expfolder, expname);
  scriptname = fullfile(foldername, [expname, '_runscript.m']);

  % logfile creation
  [~, msg] = mkdir(fullfile(foldername, 'log'));
  ftest = fopen(fullfile(foldername, 'log', ['run_log_', strrep(datestr(clock), ':', '_'), '.txt']), 'w');
  if ftest ==-1
    warning('Cannot open log file!')
    ftest = 1;
  end
  
  % if experiment was not created yet
  if ~isdir(foldername) || ~exist(scriptname, 'file')
    fprintf(ftest, 'Creating experiment...\n');
    runscript = createExperiment(expfolder, expname, settingFiles, data, addSettings);
    assert(strcmp(runscript, scriptname), 'Script name and runscript name are not the same.')
  end
  
  % find available settings
  fprintf(ftest, 'Finding available settings...\n');
  [settings, resultNames] = loadSettings({scriptname});
  resultNames = cellfun(@eval, resultNames, 'UniformOutput', false);
  availableTaskID = updateTaskList(foldername, resultNames);
  nTasks = length(availableTaskID);
  
  % run available tasks
  attempts = 0;
  while any(availableTaskID) && (attempts < nTasks + 1)
    currentID = find(availableTaskID, 1, 'first');
    fprintf(ftest, 'Running task with ID: %d\n', currentID);
    availableTaskName = resultNames{currentID};
    fprintf(ftest, 'Available task name: %s\n', availableTaskName);
    taskRunFolder = fullfile(foldername, 'running', availableTaskName(1:end-4));
    [created, ~, messID] = mkdir(taskRunFolder);
    % succesful creation
    if created && ~strcmp(messID, 'MATLAB:MKDIR:DirectoryExists')
      fprintf(ftest, 'Directory ''running'' created.\n');
      availableSettings = settings{currentID};
      fprintf(ftest, 'Trying to evaluate following settings:\n %s\n', availableSettings);
      secureEval(availableSettings)
      fprintf(ftest, 'Settings computed.\n');
      rmdir(taskRunFolder, 's')
      attempts = 0;
    else
      attempts = attempts + 1;
    end
    
    % update task lists
    availableTaskID = updateTaskList(foldername, resultNames);
  end
  
  no_tasks_mess = ['No other tasks available.\n', ...
                   'If the experimental settings has changed, delete ', scriptname, ' and run the experiment again.\n'];
  fprintf(no_tasks_mess)
  fprintf(ftest, no_tasks_mess);
  
  if length(dir(fullfile(foldername, 'running'))) == 2
    rmdir(fullfile(foldername, 'running'))
  end
  
  fclose(ftest);

end

function secureEval(expression)
% function for secure evaluation of 'expression' without any influence on
% current code
  eval(expression)
end
