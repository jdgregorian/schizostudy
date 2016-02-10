function metacentrum_task2(expname, taskID, settings, resultNames)
% Runs available settings during one task
%
% NOT FUNCTIONAL

  % setting paths
  LOCALEXPPATH = fullfile('exp', 'experiments', expname);
  SCHIZOPATH = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), ...
    'prg', 'schizostudy')];
  EXPPATH = fullfile(SCHIZOPATH, LOCALEXPPATH);
  OUTPUTDIR = getenv('SCRATCHDIR');
  
  % create logfile 
  mkdir(fullfile(EXPPATH, 'log'))
  FILESTDOUT = fullfile(EXPPATH, 'log', ['log_task', num2str(taskID), '.txt']);
  fout = fopen(FILESTDOUT, 'w');
  if fout ==-1
    warning('Cannot open log file!')
    fout = 1;
  end
  
  % copy necessary files for task
  fprintf(fout, 'Copying task files...\n');
  cd(OUTPUTDIR)
  mkdir(LOCALEXPPATH)
  fToCopy = {'src', 'vendor', 'startup.m'};
  cellfun( @(x) copyfile(fullfile(SCHIZOPATH, x), fullfile(OUTPUTDIR, x)), fToCopy)
  mkdir('data')
  
  % run startup
  fprintf(fout, 'Running startup...\n');
  startup
  
  % find available settings
  fprintf(fout, 'Finding available settings...\n');
  resultNames = cellfun(@eval, resultNames, 'UniformOutput', false);
  availableTaskID = updateTaskList(EXPPATH, resultNames);
  nTasks = length(availableTaskID);
  
  % run available settings
  attempts = 0;
  while any(availableTaskID) && (attempts < nTasks + 1)
    currentID = find(availableTaskID, 1, 'first');
    fprintf(fout, 'Running settings with ID: %d\n', currentID);
    availableTaskName = resultNames{currentID};
    fprintf(fout, 'Available task name: %s\n', availableTaskName);
    taskRunFolder = fullfile(EXPPATH, 'running', availableTaskName(1:end-4));
    [created, ~, messID] = mkdir(taskRunFolder);
    % succesful creation
    if created && ~strcmp(messID, 'MATLAB:MKDIR:DirectoryExists')
      fprintf(fout, '###########################################\n');
      fprintf(fout, 'TaskID: %d\n', taskID);
      fprintf(fout, 'SettingsID: %d\n', availableTaskID);
      fprintf(fout, 'Date: %s\n', char(datetime));
      availableSettings = settings{currentID};
      
      try
        % copy necessary files
        fprintf(fout, 'Copying necessary files...\n');
        FCdataID = strfind(availableSettings, 'FCdata = ');
        aposID = strfind(availableSettings, '''');
        aposID(aposID < FCdataID) = [];
        datapath = availableSettings(aposID(1) + 1 : aposID(2) - 1);
        filesepsID = strfind(datapath, filesep);
        dataname    = datapath(filesepsID(end) + 1 : end);

        newdataname = fullfile('data', dataname);
        copyfile(datapath, newdataname)
        % change availableSettings according to new path
        availableSettings = [availableSettings(1:aposID(1)), newdataname, availableSettings(aposID(2):end)];

        % running experiment
        fprintf(fout, 'Running settings:\n%s\n', availableSettings);
        settingsEval(availableSettings)

        % saving results
        fprintf(fout, 'Saving results...\n');
        copyfile(fullfile(OUTPUTDIR, LOCALEXPPATH), EXPPATH)
        
      catch err
        fprintf(fout, 'Error: %s\n', getReport(err));
      end
      
      % remove running directory
      rmdir(taskRunFolder, 's')
      attempts = 0;
      
      fprintf(fout, '###########################################\n');
    else
      attempts = attempts + 1;
    end
    
    % update task lists
    availableTaskID = updateTaskList(EXPPATH, resultNames);
  end
  
  fprintf(fout, 'No other tasks available.\n');
  
  % remove directory running
  if length(dir(fullfile(EXPPATH, 'running'))) == 2
    rmdir(fullfile(EXPPATH, 'running'))
  end

  fclose(fout);
end

function settingsEval(expression)
  classFCrow = expression(strfind(expression, 'classifyFC'):end);
  restOfExpression = expression(1 : strfind(expression, 'classifyFC')-1);
  restOfExpression = strrep(restOfExpression, 'settings', 'experimentSettings');
  eval(restOfExpression)
  fullfileID = strfind(classFCrow, 'fullfile(filename, ''');
  apostrID = strfind(classFCrow, '''');
  if exist('filename', 'var') && ~isempty(fullfileID)
    fileAppendix = classFCrow(apostrID(3)+1 : apostrID(4)-1);
    filename = fullfile(filename, fileAppendix);
  else
    error('Could not find fullfile(filename...')
  end
  method = classFCrow(apostrID(1) + 1 : apostrID(2) - 1);
  if exist('experimentSettings', 'var')
    classifyFC(FCdata, method, experimentSettings, filename)
  else
    error('Could not find variable settings in availableSettings')
  end
end
