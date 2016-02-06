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
  
  % copy necessary files
  fprintf(fout, 'Copying necessary files...\n');
  datapath = taskSettings(strfind(taskSettings, 'FCdata = ') + 10, end);
  datapath = datapath(1:strfind(taskSettings, '''') - 1);
  filesepsID = strfind(datapath, filesep);
  datafolders = datapath(1:filesepsID(end) - 1);
  
  mkdir(LOCALEXPPATH)
  mkdir(datafolders)
  fToCopy = {'src', 'vendor', 'startup.m', datapath};
  cellfun( @(x) copyfile(fullfile(SCHIZOPATH, x), fullfile(OUTPUTDIR, x)), fToCopy)
  
  % run startup
  fprintf(fout, 'Running startup...');
  startup

  % running experiment
  fprintf(fout, 'Running settings...');
  try
    eval(taskSettings)
  catch err
    fprintf(fout, 'Error: %s\n', err.message);
  end
  
  % saving results
  fprintf(fout, 'Saving results...');
  copyfile(fullfile(OUTPUTDIR, LOCALEXPPATH), fullfile(SCHIZOPATH, LOCALEXPPATH))

  fprintf(fout, '###########################################\n');
  fclose(fout);
end
