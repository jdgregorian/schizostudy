function metacentrum_task(taskID, settingFiles, data, expname)
FILESTDOUT = fullfile('exp', 'experiments', expname, ['log_' num2str(taskID) '.txt']);
fout = fopen(FILESTDOUT, 'a');
fprintf(fout, '###########################################\n');
fprintf(fout, 'Something task %d\n', taskID);

for i=1:length(settingFiles)
  fprintf(fout, '%s\n', settingFiles{i});
end

for i=1:length(data)
  fprintf(fout, '%s\n', data{i});
end

fprintf(fout, '###########################################\n');
fclose(fout);
end