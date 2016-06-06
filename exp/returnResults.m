function [avgPerformances, settings, method, data, results, ...
  returnedFiles, omittedFiles] = returnResults(folders)
% [avgPerformances, settings, method, data, results, returnedFiles, 
%  omittedFiles] = returnResults(folders) 
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
%   results         - N x M structure of results with following fields:
%
%     performance        - cell array of performances of individual
%                          iterations
%     actualPerformance  - vector of average performance omitting
%                          non-classified points
%     elapsedTime        - cell array of elapsed times of individual
%                          iterations
%     errors             - matrix of errors occured during testing
%     class              - class predictions of tested classifier
%     correctPredictions - vector of correct predictions of classifier
%
%   returnedFiles  - list of returned files
%   omittedFiles   - list of omitted files
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
  actualPerformance = cell(1, nFolders);
  elapsedTime = cell(1, nFolders);
  errors = cell(1, nFolders);
  returnedFiles = cell(1, nFolders);
  omittedFiles = cell(1, nFolders);
  class = cell(1, nFolders);
  correctPredictions = cell(1, nFolders);

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
      folderClass = cell(nFiles, 1);
      folderCorrectPredictions = cell(nFiles, 1);
      nEmptyFiles = 0;
      usefulFiles = true(nFiles, 1);

      fprintf('Loading data...\n')
      necessaryVariables = {'settings', 'method', 'data', 'performance', 'avgPerformance'};
      possibleVariables = [necessaryVariables, 'errors', 'elapsedTime', 'class', 'correctPredictions'];
      % loading files
      for fil = 1:nFiles
        filename = [folders{f}, filesep, fileList(fil).name];
        try
          variables = load(filename, possibleVariables{:});
          if all(isfield(variables, necessaryVariables(1:end-1)))
            % compulsory variables
            folderSettings{fil - nEmptyFiles} = variables.settings;
            folderMethod{fil - nEmptyFiles} = variables.method;
            folderData{fil - nEmptyFiles} = variables.data;
            folderPerformance{fil - nEmptyFiles} = variables.performance;
            folderAvgPerformance(fil - nEmptyFiles) = variables.avgPerformance;
            % optional variables
            if isfield(variables, 'errors')
              folderErrors{fil - nEmptyFiles} = variables.errors;
            end
            if isfield(variables, 'elapsedTime')
              folderElapsedTime{fil - nEmptyFiles} = variables.elapsedTime;
            end
            if isfield(variables, 'class')
              folderClass{fil - nEmptyFiles} = variables.class;
            end
            if isfield(variables, 'correctPredictions')
              folderCorrectPredictions{fil - nEmptyFiles} = variables.correctPredictions;
            end
          else
            fprintf('Omitting file (lack of result variables): %s\n', filename)
            nEmptyFiles = nEmptyFiles + 1;
            usefulFiles(fil) = false;
          end
        catch
          fprintf('Omitting file (unable to read): %s\n', filename)
          nEmptyFiles = nEmptyFiles + 1;
          usefulFiles(fil) = false;
        end
      end
      
      % fill performances
      avgPerformances{f} = [];
      performance{f} = {};
      actualPerformance{f} = [];
      errors{f} = {};
      elapsedTime{f} = {};
      class{f} = {};
      correctPredictions{f} = {};
      uniqueSettings = {};
      uSettings = {};
      uniqueSettings_Method = {};
      uniqueData = unique(folderData(1:nFiles - nEmptyFiles));

      for s = 1 : nFiles - nEmptyFiles
        % compare uniqueness of settings omitting field 'note'
        fSettings = folderSettings{s};
        fMethod = folderMethod{s};
        if isfield(fSettings, 'note')
          fSettings = rmfield(fSettings, 'note');
        end
        settingsID = find(cellfun(@(x) myisequal(fSettings, x), uSettings));
        if ~isempty(settingsID)
          settingsID = settingsID(strcmp(fMethod, uniqueSettings_Method(settingsID)));
        end
        % count actual performance
        actualPerf = zeros(1, length(folderCorrectPredictions{s}));
        for iter = 1:length(folderCorrectPredictions{s})
          if length(folderCorrectPredictions{s}{iter}) == length(folderClass{s}{iter})
            actualPerf(iter) = sum(folderCorrectPredictions{s}{iter}(~isnan(folderClass{s}{iter})))/sum(~isnan(folderClass{s}{iter}));
          else
            warning('Number of predictions and number of classified subjects differs (in useful file %d)', s)
            actualPerf(iter) = NaN;
          end
        end
        % new settings
        if isempty(settingsID)
          uniqueSettings{end+1} = folderSettings{s};
          uSettings{end+1} = fSettings; % for settings comparison
          uniqueSettings_Method{end+1} = folderMethod{s};
          dataID = find(strcmp(uniqueData, folderData{s}), 1);
          avgPerformances{f}(end+1, dataID) = folderAvgPerformance(s);
          performance{f}{end+1, dataID} = folderPerformance{s};
          actualPerformance{f}(end+1, dataID) = mean(actualPerf);
          errors{f}{end+1, dataID} = folderErrors{s};
          elapsedTime{f}{end+1, dataID} = folderElapsedTime{s};
          class{f}{end+1, dataID} = folderClass{s};
          correctPredictions{f}{end+1, dataID} = folderCorrectPredictions{s};
        % existing settings
        else
          dataID = find(strcmp(uniqueData, folderData{s}), 1);
          if (dataID <= size(avgPerformances{f},2)) && (~isempty(performance{f}{settingsID, dataID}))
            fprintf('Omitting file (result redundancy): %s\n', filename)
            usefulFiles(s) = false;
          end
          avgPerformances{f}(settingsID, dataID) = folderAvgPerformance(s);
          performance{f}{settingsID, dataID} = folderPerformance{s};
          actualPerformance{f}(settingsID, dataID) = mean(actualPerf);
          errors{f}{settingsID, dataID} = folderErrors{s};
          elapsedTime{f}{settingsID, dataID} = folderElapsedTime{s};
          class{f}{settingsID, dataID} = folderClass{s};
          correctPredictions{f}{settingsID, dataID} = folderCorrectPredictions{s};
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
  
  % save the rest of variables to appropriate output
  if nFolders == 1
    % simple output for one input
    avgPerformances = avgPerformances{1};
    settings = settings{1};
    method = method{1};
    data = data{1};
    results.performance = performance{1};
    results.elapsedTime = elapsedTime{1};
    results.errors = errors{1};
    returnedFiles = returnedFiles{1};
    omittedFiles = omittedFiles{1};
    results.class = class{1};
    results.correctPredictions = correctPredictions{1};
    results.actualPerformance = actualPerformance{1};
  else
    results.performance = performance;
    results.elapsedTime = elapsedTime;
    results.errors = errors;
    results.class = class;
    results.correctPredictions = correctPredictions;
    results.actualPerformance = actualPerformance;
  end
end