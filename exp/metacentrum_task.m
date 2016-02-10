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
    filesepsID = strfind(datapath, filesep);
    dataname    = datapath(filesepsID(end) + 1 : end);
  
    % move to output directory and copy necessary files
    cd(OUTPUTDIR)
    mkdir(LOCALEXPPATH)
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
    fprintf(fout, 'Running settings:\n%s\n', taskSettings);
    settingsEval(taskSettings)

  catch err
    fprintf(fout, 'Error: %s\n', getReport(err));
  end
  
  % saving results
  fprintf(fout, 'Saving results...\n');
  copyfile(fullfile(OUTPUTDIR, LOCALEXPPATH), EXPPATH)

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
