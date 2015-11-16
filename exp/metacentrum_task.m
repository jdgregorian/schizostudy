function metacentrum_task(expname, taskID)
cd('..')
startup
FILESTDOUT = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), ...
  'prg', 'schizostudy', 'exp', 'experiments', expname, ['log_' num2str(taskID) '.txt'])];
fout = fopen(FILESTDOUT, 'w');
fprintf(fout, '###########################################\n');
fprintf(fout, 'TaskID: %d\n', taskID);
fprintf(fout, 'Date: %s\n', char(datetime));

try
  runExperiment(expname)
catch err
  fprintf(fout, 'Error: %s\n', err.message);
end

fprintf(fout, '###########################################\n');
fclose(fout);
end
