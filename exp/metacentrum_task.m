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
  fprintf(fout, 'Date: %s\n', char(datetime));
  
  try

    % copy necessary files
    fprintf(fout, 'pwd: %s\n', pwd);
    fprintf(fout, 'Copying necessary files...\n');
    FCdataID = strfind(taskSettings, 'FCdata = ');
    aposID = strfind(taskSettings, '''');
    aposID(aposID < FCdataID) = [];
    datapath = taskSettings(aposID(1) + 1 : aposID(2) - 1);
    fprintf(fout, 'datapath: %s\n', datapath);
    filesepsID = strfind(datapath, filesep);
    datafolders = datapath(1:filesepsID(end) - 1);
    dataname    = datapath(filesepsID(end) + 1 : end);
    fprintf(fout, 'datafolders: %s\n', datafolders)
  
    mkdir(LOCALEXPPATH)
    fprintf(fout, 'Directory %s created.\n', LOCALEXPPATH);
    fToCopy = {'src', 'vendor', 'startup.m'};
    cellfun( @(x) copyfile(fullfile(SCHIZOPATH, x), fullfile(OUTPUTDIR, x)), fToCopy)
    mkdir('data')
    newdataname = fullfile('data', dataname);
    copyfile(datapath, newdataname)
    % change taskSettings according to new path
    taskSettings = [taskSettings(1:aposID(1)), newdataname, taskSettings(aposID(2):end)];
  
    % run startup
    fprintf(fout, 'Running startup...\n');
    startup

    % running experiment
    fprintf(fout, 'Running settings...\n');
    fprintf(fout, 'taskSettings: \n%s\n', taskSettings);
  
    settingsEval(taskSettings)
  catch err
    fprintf(fout, 'Error: %s\n', getReport(err));
  end
  
  % saving results
  fprintf(fout, 'Saving results...\n');
  copyfile(fullfile(OUTPUTDIR, LOCALEXPPATH), fullfile(SCHIZOPATH, LOCALEXPPATH))

  fprintf(fout, '###########################################\n');
  fclose(fout);
end

function settingsEval(expression)
  classFCrow = expression(strfind(expression, 'classifyFC'):end);
  restOfExpression = expression(1 : strfind(expression, 'classifyFC')-1);
  settingsID = strrep(restOfExpression, 'settings', 'experimentSettings');
  eval(restOfExpression)
  fullfileID = strfind(classFCrow, 'fullfile(filename, ''');
  if exist('filename', 'var') && ~isempty(fullfileID)
    apostrID = strfind(classFCrow, '''');
    fileAppendix = classFCrow(apostrID(1)+1 : apostrID(2)-1);
    filename = fullfile(filename, fileAppendix);
  else
    error('Could not find fullfile(filename...')
  end
  apostrID = strfind(classFCrow, '''');
  method = classFCrow(apostrID(1) + 1 : apostrID(2) - 1);
  if exist('experimentSettings', 'var')
    classifyFC(FCdata, method, settings, filename)
  else
    error('Could not find variable settings in taskSettings')
  end
end
