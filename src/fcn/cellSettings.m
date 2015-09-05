function cellset = cellSettings(settings, remove)
% CELLSET = cellSettings(SETTINGS, REMOVE) removes fields in REMOVE from SETTINGS and transforms the rest to cell
% array CELLSET for matlab algorithms.
  
  if nargin < 2
    remove = {};
  end
  
  % remove settings from stucture
  for i = 1:length(remove)
    if isfield(settings,remove{i})
      settings = rmfield(settings,remove{i});
    end
  end

  if isempty(settings)
    cellset = {};
  else
    % parse settings to cell array
    settingsNames = fieldnames(settings);
    settingsValues = struct2cell(settings);
    cellset = cell(1,2*length(settingsNames));
    for s = 1 : length(settingsNames)
      cellset{2*s-1} = settingsNames{s};
      cellset{2*s} = settingsValues{s};
    end
  end
end