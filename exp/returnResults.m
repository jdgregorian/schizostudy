function [avgPerformances, settings, method, data, performance, errors, omittedFiles] = returnResults(folders)
% [performances, settings, method, data, errors] 
%     = returnResults('folders') lists results of FC 
% performance testing in 'folders' cellarray to 'performance' and
% apropriate 'settings', 'method', 'data', and 'errors'.
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
%   performance     - N x M cell array of performances of tested
%                     classifiers
%   errors          - N x M matrix of errors occured during testing
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
  errors = cell(1, nFolders);

  % folder loop
  for f = 1:nFolders
    if ~isdir(folders{f})
      warning('Folder %s does not exist! Results cannot be printed!', folders{f})
      return
    end
    
    fileList = dir([folders{f}, filesep, '*.mat']);
    nFiles = length(fileList);

    % initialization of folder properties
    folderSettings = cell(nFiles,1);
    folderMethod = cell(nFiles,1);
    folderData = cell(nFiles,1);
    folderPerformance = cell(nFiles,1);
    folderAvgPerformance = zeros(nFiles,1);
    folderErrors = cell(nFiles,1);
    nEmptyFiles = 0;
    usefulFiles = true(nFiles,1);
    omittedFiles = {};

    fprintf('Loading data...\n')
    neededVariables = {'settings', 'method', 'data', 'performance', 'avgPerformance', 'errors'};
    % loading files
    for fil = 1:nFiles
      filename = [folders{f}, filesep, fileList(fil).name];
      variables = load(filename, neededVariables{:});
      if all(isfield(variables, neededVariables(1:end-1)))
        folderSettings{fil - nEmptyFiles} = variables.settings;
        folderMethod{fil - nEmptyFiles} = variables.method;
        folderData{fil - nEmptyFiles} = variables.data;
        folderPerformance{fil - nEmptyFiles} = variables.performance;
        folderAvgPerformance(fil - nEmptyFiles) = variables.avgPerformance;
        if isfield(variables, 'errors')
          folderErrors{fil - nEmptyFiles} = variables.errors;
        end
      else
        fprintf('Omitting file %s\n', filename)
        omittedFiles{end+1} = filename;
        nEmptyFiles = nEmptyFiles + 1;
        usefulFiles(fil) = false;
      end
    end
    
    % fill performances
    avgPerformances{f} = [];
    performance{f} = {};
    errors{f} = {};
    uniqueSettings = {};
    uniqueSettings_Method = {};
    uniqueData = unique(folderData(1:nFiles - nEmptyFiles));
    % use only files with all information
    useFile = 1:nFiles;
    useFile(~usefulFiles) = [];
    for s = 1 : nFiles - nEmptyFiles
      settingsID = find(cellfun(@(x) isequal(folderSettings{s}, x), uniqueSettings), 1);
      if isempty(settingsID)
        uniqueSettings{end+1} = folderSettings{s};
        uniqueSettings_Method{end+1} = folderMethod{s};
        dataID = find(strcmp(uniqueData, folderData{s}), 1);
        avgPerformances{f}(end+1, dataID) = folderAvgPerformance(s);
        performance{f}{end+1, dataID} = folderPerformance{s};
        errors{f}{end+1, dataID} = folderErrors{s};
      else
        dataID = find(strcmp(uniqueData, folderData{s}), 1);
        avgPerformances{f}(settingsID, dataID) = folderAvgPerformance(s);
        performance{f}{settingsID, dataID} = folderPerformance{s};
        errors{f}{settingsID, dataID} = folderErrors{s};
      end
    end
    
    % save the rest of output
    settings{f} = uniqueSettings;
    method{f} = uniqueSettings_Method;
    data{f} = uniqueData;
  end
end