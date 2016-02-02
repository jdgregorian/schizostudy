function [settings, resultNames] = loadSettings(settingFiles)
% Loads settings in cell array 'settinsFiles' and returns apropriate
% 'settings' and names of results in 'resultNames'.
%
% See Also:
%   createExperiment
  
  nFiles = length(settingFiles);
  settings = {};
  for f = 1:nFiles
    str = fileread(settingFiles{f}); % read the whole file
    splits = strsplit(str, '%%'); % split according to %% marks
    % find parts with settings in file
    usefulParts = cell2mat(cellfun(@(x) ~isempty(strfind(x, 'classifyFC')), splits, 'UniformOutput', false));
    settings(end+1:end+sum(usefulParts)) = splits(usefulParts);
  end
  % return % back to each setting
  settings = cellfun(@(x) ['%', x], settings, 'UniformOutput', false);
  
  % extract row with classifyFC function call
  classFCrow = cellfun(@(x) x(strfind(x, 'classifyFC'):end), settings, 'UniformOutput', false);
  % extract names of results of settings
  resultNames = cellfun(@(x) x(strfind(x, 'filename,')+9 : strfind(x, '));')-1 ), classFCrow, 'UniformOutput', false);
  
end