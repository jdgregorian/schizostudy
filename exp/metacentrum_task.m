function metacentrum_task(taskID, settingFiles, data, expname)
FILESTDOUT = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy', 'exp', 'experiments', expname, ['log_' num2str(taskID) '.txt'])];
fout = fopen(FILESTDOUT, 'w');
fprintf(fout, '###########################################\n');
fprintf(fout, 'TaskID: %d\n', taskID);
fprintf(fout, 'Date: %s\n', char(datetime));

for i=1:length(settingFiles)
  fprintf(fout, 'Settings(%d): %s\n', i, settingFiles{i});
end

for i=1:length(data)
  fprintf(fout, 'Data(%d): %s\n', i, data{i});
end

try
  runExperiment(settingFiles, data, expname, true)
catch err
  fprintf(fout, 'Error: %s\n', err.message);
end

fprintf(fout, '###########################################\n');
fclose(fout);
end
