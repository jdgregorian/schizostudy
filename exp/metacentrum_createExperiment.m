function metacentrum_createExperiment(expfile, expfolder, metafolder)
% metacentrum_createExperiment(foldername, expfolder, metafolder) creates
% runscript for experiment 'expfile' in folder 'expfolder' in Metacentrum 
% storage 'metafolder' (containing schizostudy sourcecodes).
%
% Input:
%   expfile  - experiment file | string
%   expfolder  - folder containing experiment | string
%   metafolder - folder containing source codes on Metacentrum | string
%
% See Also:
%   createExperiment, metacentrum_runExperiment

  % initialization
  if nargin < 3
    metafolder = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy')];
    if nargin < 2
      expfolder = fullfile('exp', 'experiments');
      if nargin < 1
        help metacentrum_createExperiment
        return
      end
    end
  end
  
  if ~strcmp(expfile(end-1 : end), '.m')
    expContent = fileread([expfile, '.m']);
  end
  % extract row with runExperiment function call without runExperiment
  % itself
  runExpId = strfind(expContent, 'runExperiment(');
  runExpRow = expContent(runExpId + 14 : end);
  newLineIds = strfind(runExpRow, char(10));
  if isempty(newLineIds)
    newLineIds = strfind(runExpRow, char(13));
  end
  runExpRow = runExpRow(1: newLineIds(1));
  % delete white spaces, brackets, semicolons
  runExpRow([strfind(runExpRow, ' '), strfind(runExpRow, ')'), strfind(runExpRow, ';')]) = [];
  % check presence of brackets - could cause problems during splitting
  if isempty(runExpRow)|| ~(isempty(strfind(runExpRow, '[')) && isempty(strfind(runExpRow, '{')))
    warning('Rewrite (or add) runExperiment function call in experiment file not to include ''['' or ''{''')
    fprintf('Aborting metacentrum_createExperiment')
    return
  end
  % split to variables
  expVarNames = strsplit(runExpRow, ',');
  % evaluate experiment settings
  expSet = secureEval(expContent(1:runExpId - 1), expVarNames);
  data = expSet.data;

  % data check
  missing = ~((cellfun(@(x) exist(x, 'file'), data)) | (cellfun(@isdir, data)));

  % omit missing data
  if all(missing)
    error('There is no data for computing. Check if all data files and folders are correctly specified.')
  elseif any(missing)
    fprintf('missing: %d\n', length(missing))
    fprintf('Omitting missing data files:\n')
    cellfun(@(x) fprintf('%s\n', x), data(missing))
    fprintf('\n')
    data = data(~missing);
  end 

  data = cellfun(@(x) fullfile(metafolder, x), data, 'UniformOutput', false);
  createExperiment(expfolder, expSet.expname, expSet.settingFiles, data, expSet.addSettings)
  
end

function var = secureEval(expression, variables)
% function for secure evaluation
% if cell array 'variables' is not empty, return their values in structure
% var (for experiment settings use only)

  var = [];

  eval(expression)
  
  if nargin > 1
    % assign variable values to appropriate variables
    eval(['var.settingFiles = ', variables{1}, ';'])
    if ~iscell(var.settingFiles)
      var.settingFiles = {var.settingFiles};
    end
    eval(['var.data = ', variables{2}, ';'])
    if ~iscell(var.data)
      var.data = {var.data};
    end
    eval(['var.expname = ', variables{3}, ';'])
    if length(variables) > 3
      eval(['var.addSettings = ', variables{4}, ';'])
    else
      var.addSettings = '';
    end
  end

end
