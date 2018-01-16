function metacentrum_task(expname, taskID, taskSettings)
% Individual task running during one job

  % setting paths
  LOCALEXPPATH = fullfile('exp', 'experiments', expname);
  SCHIZOPATH = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), ...
    'prg', 'schizostudy')];
  EXPPATH = fullfile(SCHIZOPATH, LOCALEXPPATH);
  OUTPUTDIR = getenv('SCRATCHDIR');
  
  % create logfile 
  mkdir(fullfile(EXPPATH, 'log'))
  FILESTDOUT = fullfile(EXPPATH, 'log', ['log_', num2str(taskID), '.txt']);
  fout = fopen(FILESTDOUT, 'w');
  if fout ==-1
    warning('Cannot open log file!')
    fout = 1;
  end
  
  fprintf(fout, '###########################################\n');
  fprintf(fout, 'TaskID: %d\n', taskID);
  fprintf(fout, 'SettingsID: %d\n', taskID);
  fprintf(fout, 'Date: %s\n', char(datetime));
  
  try
    % prepare necessary files
    fprintf(fout, 'Copying necessary files...\n');
    FCdataID = strfind(taskSettings, 'FCdata = ');
    aposID = strfind(taskSettings, '''');
    aposID(aposID < FCdataID) = [];
    datapath = taskSettings(aposID(1) + 1 : aposID(2) - 1);
    [datafolder, dataname, dataextension] = fileparts(datapath);
    dataname = [dataname, dataextension];
    
    % create running folder on storage
    fprintf(fout, 'Creating running folder...\n');
    aposSplit = strsplit(S, '''');
    [~, resFilename] = fileparts(aposSplit(end-1));
    taskRunFolder = fullfile(EXPPATH, 'running', resFilename);
    [createdRunDir, ~, messID] = mkdir(taskRunFolder);
    if createdRunDir && strcmp(messID, 'MATLAB:MKDIR:DirectoryExists')
      fprintf(fout, 'Setting %d is already running or the running folder %s was not deleted after the previous run.\n', ...
        taskID, taskRunFolder);
    elseif ~createdRunDir
      fprintf(fout, 'Unable to create running folder %s\n', taskRunFolder);
    else
      fprintf(fout, 'Running folder %s created.\n', taskRunFolder);
    end
  
    % move to output directory and copy necessary files
    cd(OUTPUTDIR)
    mkdir(LOCALEXPPATH)
    fToCopy = {'src', 'vendor', 'startup.m'};
    cellfun( @(x) copyfile(fullfile(SCHIZOPATH, x), fullfile(OUTPUTDIR, x)), fToCopy)
    mkdir('data')
    newdataname = fullfile('data', dataname);
    assert(isdir(datafolder), 'Cannot copy %s because %s is not a folder', datapath, datafolder)
    copyfile(datapath, newdataname)
    % change taskSettings according to new path
    taskSettings = [taskSettings(1:aposID(1)), newdataname, taskSettings(aposID(2):end)];
    
    % run startup
    fprintf(fout, 'Running startup...\n');
    startup

    % running experiment
    fprintf(fout, 'Running settings:\n%s\n', taskSettings);
    settingsEval(taskSettings)

  catch err
    fprintf(fout, 'Running error: %s\n', getReport(err));
  end
  
  % saving results
  fprintf(fout, 'Saving results...\n');
  [c_status, c_msg] = copyfile(fullfile(OUTPUTDIR, LOCALEXPPATH), EXPPATH);
  if c_status
    fprintf(fout, 'Files successfully saved to %s\n', EXPPATH);
  else
    fprintf(fout, 'Saving error: %s\n', c_msg);
  end
  
  % delete running folder on storage
  try
    rmdir(taskRunFolder)
    fprintf(fout, 'Running folder %s deleted.\n', taskRunFolder);
  catch
    fprintf(fout, 'Unable to delete running folder %s\n', taskRunFolder);
  end

  fprintf(fout, '###########################################\n');
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
    error('Could not find variable settings in taskSettings')
  end
end
