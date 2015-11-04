function runExperiment(settingFiles, data, expname)
% Tests settings in 'settingFiles' od 'data' and names the experiment as 
% 'expname'.
%
% Input:
%    settingFiles  - m-file or cell array of m-files with settings of
%                    classifiers
%    data          - char or cell array of char containing path(s) to data
%                    that should be tested
%    expname       - name of the experiment
%
% See Also:
% metacentrum_runExperiment createExperiment

  % initialization
  if nargin < 1
    help runExperiment
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
  
  % find available settings
  [settings, resultNames] = loadSettings({scriptname});
  resultNames = cellfun(@eval, resultNames, 'UniformOutput', false);
  availableTaskID = updateTaskList(foldername, resultNames);
  nTasks = length(availableTaskID);
  
  % run available tasks
  attempts = 0;
  while any(availableTaskID) && (attempts < nTasks + 1)
    currentID = find(availableTaskID, 1, 'first');
    availableTaskName = resultNames{currentID};
    taskRunFolder = fullfile(foldername, 'running', availableTaskName(1:end-4));
    [created, ~, messID] = mkdir(taskRunFolder);
    % succesful creation
    if created && ~strcmp(messID, 'MATLAB:MKDIR:DirectoryExists')
      availableSettings = settings{currentID};
      secureEval(availableSettings)
      rmdir(taskRunFolder, 's')
      attempts = 0;
    else
      attempts = attempts + 1;
    end
    
    % update task lists
    availableTaskID = updateTaskList(foldername, resultNames);
  end
  
  fprintf('No other tasks available.\n')
  
  if length(dir(fullfile(foldername, 'running'))) == 2
    rmdir(fullfile(foldername, 'running'))
  end
  
end

function availableTaskID = updateTaskList(foldername, resultNames)
% updates info about finished and running tasks

  finishedTasks = dir(fullfile(foldername, '*.mat'));
  finishedTaskNames = arrayfun(@(x) x.name(1:end-4), finishedTasks, 'UniformOutput', false);
  runningTasks = dir(fullfile(foldername, 'running'));
  if length(runningTasks) > 2
    runningTasks = runningTasks(3:end);
  end
  availableTaskID = cellfun(@(x) ~any(strcmp(x(1:end-4), [{runningTasks.name}'; finishedTaskNames])), resultNames);

end

function secureEval(expression)
% function for secure evaluation of 'expression' without any influence on
% current code
  eval(expression)
end