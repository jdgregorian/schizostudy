function availableTaskID = updateTaskList(foldername, resultNames)
% availableTaskID = updateTaskList(foldername, resultNames) returns logical
% IDs of not finished and not running tasks.

  finishedTasks = dir(fullfile(foldername, '*.mat'));
  finishedTaskNames = arrayfun(@(x) x.name(1:end-4), finishedTasks, 'UniformOutput', false);
  runningTasks = dir(fullfile(foldername, 'running'));
  if length(runningTasks) > 2
    runningTasks = runningTasks(3:end);
  end
  availableTaskID = cellfun(@(x) ~any(strcmp(x(1:end-4), [{runningTasks.name}'; finishedTaskNames])), resultNames);

end