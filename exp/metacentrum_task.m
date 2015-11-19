function metacentrum_task(expname, taskID)
% Individual task running during one job

  cd('..')
  startup
  EXPPATH = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), ...
    'prg', 'schizostudy', 'exp', 'experiments', expname)];
  
  % create logfile 
  mkdir(fullfile(EXPPATH, 'log'))
  FILESTDOUT = fullfile(EXPPATH, 'log', ['log_' num2str(taskID) '.txt']);
  fout = fopen(FILESTDOUT, 'w');
  if fout ==-1
    warning('Cannot open log file!')
    fout = 1;
  end
  
  fprintf(fout, '###########################################\n');
  fprintf(fout, 'TaskID: %d\n', taskID);
  fprintf(fout, 'Date: %s\n', char(datetime));

  % running experiment
  try
    runExperiment(expname)
  catch err
    fprintf(fout, 'Error: %s\n', err.message);
  end

  fprintf(fout, '###########################################\n');
  fclose(fout);
end
