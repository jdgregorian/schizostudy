function [settings, resultNames] = loadSettings(settingFiles)
% [settings, resultNames] = loadSettings(settingFiles) loads settings in 
% cell array 'settingFiles' and returns apropriate 'settings' as string 
% and names of results in 'resultNames'.
%
% Input:
%   settingFiles - files with classifyFC settings | string or cell-array of
%                  strings
% Output:
%   settings    - strings containing individual settings of experiment |
%                 cell-array of strings
%   resultNames - names of files with results of individual settings |
%                 cell-array of strings
%
% See Also:
%   classifyFC, createExperiment

  settings = {};
  resultNames = {};
  if nargin < 1
    help loadSettings
    return
  end
  
  if ischar(settingFiles)
    settingFiles = {settingFiles};
  end
  
  nFiles = length(settingFiles);
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