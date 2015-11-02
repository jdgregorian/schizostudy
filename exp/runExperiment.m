function runExperiment(settingFiles, data, expname)
% Tests settings in 'settingFiles' od 'data' and names the experiment as 
% 'expname'.
%
% Input:
%    settingFiles - m-file or cell array of m-files with settings of
%                   classifiers
%    data         - char or cell array of char containing path(s) to data
%                   that should be tested
%    expname      - name of the experiment

  % initialization
  if nargin < 1
    help runExperiment
    return
  end
  if nargin < 2
    data = fullfile('data', 'data_FC_190subjects.mat');
    if nargin < 3
      expname = ['exp_', data, '_', char(datetime)];
    end
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

function [settings, resultNames] = loadSettings(settingFiles)
% loads settings in cell array 'settinsFiles'
  
  nFiles = length(settingFiles);
  settings = {};
  for f = 1:nFiles
    str = fileread(settingFiles{f}); % read the whole file
    splits = strsplit(str, '%%'); % split according to %% marks
    % find parts with settings in file
    usefulParts = cell2mat(cellfun(@(x) ~isempty(strfind(x,'classifyFC')), splits, 'UniformOutput', false));
    settings(end+1:end+sum(usefulParts)) = splits(usefulParts);
  end
  % return % back to each setting
  settings = cellfun(@(x) ['%', x], settings, 'UniformOutput', false);
  
  % extract row with classifyFC function call
  classFCrow = cellfun(@(x) x(strfind(x, 'classifyFC'):end), settings, 'UniformOutput', false);
  % extract names of results of settings
  resultNames = cellfun(@(x) x(strfind(x, 'filename,')+9 : strfind(x, '));')-1 ), classFCrow, 'UniformOutput', false);
  
end

function createExperiment(expfolder, expname, settingFiles, data)
% function creates M-file containing all necessary settings to run the
% experiment

  foldername = fullfile(expfolder, expname);
  mkdir(foldername)
  
  % load all settings
  [settings, resultNames] = loadSettings(settingFiles);
  % split settings and row containing classifyFC function
  classFCrow = cellfun(@(x) x(strfind(x, 'classifyFC'):end), settings, 'UniformOutput', false);
  settings = cellfun(@(x) x(1:strfind(x, 'classifyFC')-1), settings, 'UniformOutput', false);

  % print settings with data to .m file
  FID = fopen(fullfile(foldername, [expname, '.m']), 'w');
  assert(FID ~= -1, 'Cannot open %s !', expname)
  fprintf('Printing settings to %s...\n', expname)

  fprintf(FID, '%% Script for experiment %s\n', expname);
  fprintf(FID, '%% Created on %s\n', datestr(now));
  fprintf(FID, '\n');

  nData = length(data);
  nSettings = length(settings);
  % data dependent settings printing
  for d = 1:nData
    slashes = strfind(data{d}, filesep);
    if isdir(data{d})
      datamark = data{d}(5:end);
      datamark(slashes - 4) = '_';
    else
      datamark = ['_', data{d}(slashes(end)+1:end-4)]; % needed for new classifyFC row
    end
    for s = 1:nSettings
      fprintf(FID, '%%%% %d/%d\n\n', s + (d-1)*nSettings, nData*nSettings);
      fprintf(FID, 'FCdata = ''%s'';\n', data{d});
      fprintf(FID, 'filename = ''%s'';\n', expname);
      fprintf(FID, '\n');
      % create new classifyFC row
      actualClassFCrow = [classFCrow{s}(1:strfind(classFCrow{s}, 'filename,') + 8) , ' ''', eval(resultNames{s}), '''));'];
      fprintf(FID, '%s', settings{s});
      fprintf(FID, '%s\n\n', actualClassFCrow);
    end
  end

  fclose(FID);  
  
  % create directory for marking running tasks
  mkdir(foldername, 'running')
  
end

function secureEval(expression)
% function for secure evaluation of 'expression' without any influence on
% current code
  eval(expression)
end