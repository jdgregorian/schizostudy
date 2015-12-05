function [avgPerformances, settings, method, data, performance, elapsedTime, errors, returnedFiles, omittedFiles] = returnResults(folders)
% [avgPerformances, settings, method, data, performance, elapsedTime, 
%    errors, returnedFiles, omittedFiles] = returnResults('folders') 
% lists results of FC performance testing in 'folders' cellarray.
%
% Input:
%   folders - list of folders to process | string or cell array of 
%             strings
%
% Output:
%   avgPerformances - N x M matrix of average performances of unique 
%                     settings, N is number of settings, M is number of 
%                     data sources
%   settings        - N settings of tested classifiers
%   method          - N methods of tested classifier
%   data            - M data sources
%   performance     - N x M cell array of performances of individual
%                     iterations
%   elapsedTime     - N x M cell array of elapsed times of individual
%                     iterations
%   errors          - N x M matrix of errors occured during testing
%   returnedFiles   - list of returned files
%   omittedFiles    - list of omitted files
%
% See Also:
%   listSettingsResults

  if nargin == 0 || isempty(folders)
    help returnResults
    return
  end
  
  if ~iscell(folders)
    folders = {folders};
  end
  
  nFolders = length(folders);

  % initialize output
  avgPerformances = cell(1, nFolders);
  settings = cell(1, nFolders);
  method = cell(1, nFolders);
  data = cell(1, nFolders);
  performance = cell(1, nFolders);
  elapsedTime = cell(1, nFolders);
  errors = cell(1, nFolders);
  returnedFiles = cell(1, nFolders);
  omittedFiles = cell(1, nFolders);

  % folder loop
  for f = 1:nFolders
    if ~isdir(folders{f})
      warning('Folder %s does not exist! Results cannot be returned!', folders{f})
      
    else
      fileList = dir([folders{f}, filesep, '*.mat']);
      nFiles = length(fileList);

      % initialization of folder properties
      folderSettings = cell(nFiles,1);
      folderMethod = cell(nFiles,1);
      folderData = cell(nFiles,1);
      folderPerformance = cell(nFiles,1);
      folderAvgPerformance = zeros(nFiles,1);
      folderErrors = cell(nFiles,1);
      folderElapsedTime = cell(nFiles,1);
      nEmptyFiles = 0;
      usefulFiles = true(nFiles,1);

      fprintf('Loading data...\n')
      necessaryVariables = {'settings', 'method', 'data', 'performance', 'avgPerformance'};
      possibleVariables = [necessaryVariables, 'errors', 'elapsedTime'];
      % loading files
      for fil = 1:nFiles
        filename = [folders{f}, filesep, fileList(fil).name];
        variables = load(filename, possibleVariables{:});
        if all(isfield(variables, necessaryVariables(1:end-1)))
          folderSettings{fil - nEmptyFiles} = variables.settings;
          folderMethod{fil - nEmptyFiles} = variables.method;
          folderData{fil - nEmptyFiles} = variables.data;
          folderPerformance{fil - nEmptyFiles} = variables.performance;
          folderAvgPerformance(fil - nEmptyFiles) = variables.avgPerformance;
          if isfield(variables, 'errors')
            folderErrors{fil - nEmptyFiles} = variables.errors;
          end
          if isfield(variables, 'elapsedTime')
            folderElapsedTime{fil - nEmptyFiles} = variables.elapsedTime;
          end
        else
          fprintf('Omitting file %s\n', filename)
          nEmptyFiles = nEmptyFiles + 1;
          usefulFiles(fil) = false;
        end
      end

      % fill performances
      avgPerformances{f} = [];
      performance{f} = {};
      errors{f} = {};
      elapsedTime{f} = {};
      uniqueSettings = {};
      uniqueSettings_Method = {};
      uniqueData = unique(folderData(1:nFiles - nEmptyFiles));

      for s = 1 : nFiles - nEmptyFiles
        settingsID = find(cellfun(@(x) isequal(folderSettings{s}, x), uniqueSettings), 1);
        if isempty(settingsID)
          uniqueSettings{end+1} = folderSettings{s};
          uniqueSettings_Method{end+1} = folderMethod{s};
          dataID = find(strcmp(uniqueData, folderData{s}), 1);
          avgPerformances{f}(end+1, dataID) = folderAvgPerformance(s);
          performance{f}{end+1, dataID} = folderPerformance{s};
          errors{f}{end+1, dataID} = folderErrors{s};
          elapsedTime{f}{end+1, dataID} = folderElapsedTime{s};
        else
          dataID = find(strcmp(uniqueData, folderData{s}), 1);
          avgPerformances{f}(settingsID, dataID) = folderAvgPerformance(s);
          performance{f}{settingsID, dataID} = folderPerformance{s};
          errors{f}{settingsID, dataID} = folderErrors{s};
          elapsedTime{f}{settingsID, dataID} = folderElapsedTime{s};
        end
      end

      % save the rest of output
      settings{f} = uniqueSettings;
      method{f} = uniqueSettings_Method;
      data{f} = uniqueData;
      returnedFiles{f} = {fileList(usefulFiles).name};
      omittedFiles{f} = {fileList(~usefulFiles).name};
    end
  end
  
  % simple output for one input
  if nFolders == 1
    avgPerformances = avgPerformances{1};
    settings = settings{1};
    method = method{1};
    data = data{1};
    performance = performance{1};
    elapsedTime = elapsedTime{1};
    errors = errors{1};
    returnedFiles = returnedFiles{1};
    omittedFiles = omittedFiles{1};
  end
end