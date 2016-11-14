function listSettingsResults(folder, varargin)
% listSettingsResults(FOLDER, settings) lists results of FC performance 
% testing in FOLDER to file 'FOLDER/pproc/FOLDER_report.txt'. 
%
% Input:
%   FOLDER   - directory containing results | string
%   settings - pairs of property (string) and value, or struct with 
%              properties as fields:
%                'SeparateReduction' - consider data with reduced dimension 
%                                      as solo data | boolean
%
% See Also:
%   returnResults

  if nargin == 0
    help listSettingsResults
    return
  end
  if ~isdir(folder)
    warning('Folder %s does not exist! Results cannot be printed!', folder)
    return
  end
  
  % parse function settings
  resultSettings = settings2struct(varargin);
  separRed = defopts(resultSettings, 'SeparateReduction', false);
  
  folderPos = strfind(folder, filesep);
  foldername = folder(folderPos(end) + 1 : end);
  pprocFolder = fullfile(folder, 'pproc');
  resultname = fullfile(pprocFolder, [foldername, '_report.txt']);
  xlsTableName = fullfile(pprocFolder, [foldername, '_table.xls']);
  
  % loading data
  [avgPerformance, overallSettings, method, data, results, returnedFiles, omittedFiles] = returnResults(folder, 'SeparateReduction', separRed);
  
  settingArray = overallSettings.classifiers;
  dimReduction = overallSettings.dimReduction;
  performance = results.performance;
  elapsedTime = results.elapsedTime;
  errors = results.errors;
  classPred = results.class;
  actualPerf = results.actualPerformance;
  
  nFiles = length(returnedFiles);
  nOmitted = length(omittedFiles);
  [nSettings, nData] = size(avgPerformance);
  % names of data
  datanames = createDatanames(data);
  
  % check postprocessing folder
  if ~exist(pprocFolder, 'dir')
    mkdir(pprocFolder);
  end
  
  % print xls table
  fprintf('Saving average performance table to %s...\n', xlsTableName)
  resultTable(avgPerformance, 'FID', xlsTableName, 'Format', 'xls', ...
                              'Method', method, 'Datanames', datanames, ...
                              'Settings', settingArray)

  % printing results to txt file
  FID = fopen(resultname, 'w');
  assert(FID ~= -1, 'Cannot open %s !', resultname)
  fprintf('Printing results to %s...\n', resultname)
  
  % list header printing
  fprintf(FID,'---------------------------------------------------------------------------------\n');
  fprintf(FID,'------------------------- LIST OF TEST SETTINGS RESULTS -------------------------\n');
  fprintf(FID,'---------------------------------------------------------------------------------\n');
  fprintf(FID,'\n\n');
  fprintf(FID,'      Created on %s in folder %s.\n', datestr(now), folder);
  fprintf(FID,'      Number of files in folder: %d\n', nFiles + nOmitted);
  fprintf(FID,'\n');
  
  % print omitted files
  if ~isempty(omittedFiles)
    fprintf(FID,'\n---------------------------------------------------------------------------------\n\n');
    fprintf(FID,'  Omitted files (%d):\n', nOmitted);
    for f = 1:nOmitted
      fprintf(FID,'    %s\n', omittedFiles{f});
    end
    fprintf(FID,'\n');
  end
  
  % print result table
  fprintf(FID,'\n---------------------------------------------------------------------------------\n\n');
  for d = 1:nData
    fprintf(FID, '  %s: %s\n', datanames{d}, data{d});
  end
  fprintf(FID, '\n');
  resultTable(avgPerformance, 'FID', FID, 'Format', 'txt', ...
                              'Method', method, 'Datanames', datanames, ...
                              'Settings', settingArray)
  
  % printing settings results
  f = 0;
  for s = 1 : nSettings
    for d = 1 : nData
      if ~isempty(performance{s, d})
        f = f + 1;
        % file header printing
        fprintf(FID,'\n---------------------------------------------------------------------------------\n\n');
        % find constant predictions
        actualClassPred = classPred{s, d};
        if ~isempty(actualClassPred)
          constID = false(1, length(actualClassPred));
          for l = 1:length(actualClassPred)
            nanLessClassPred = actualClassPred{l};
            nanLessClassPred(isnan(nanLessClassPred)) = [];
            constID(l) = all(nanLessClassPred) || all(~nanLessClassPred);
          end
        end
        % print basic results
        fprintf(FID,'  Method: %s %s Performance: %.2f%%\n', method{s}, ...
          char(ones(1, 48 - length(method{s}))*32), avgPerformance(s, d)*100);
        if abs(actualPerf(s, d) - avgPerformance(s, d)) > 10^(-5)
          fprintf(FID,'%s Actual performance: %.2f%%\n', char(ones(1, 52)*32), actualPerf(s,d)*100);
        end
        if all(constID)
          % all results were constant
          fprintf(FID, '%s (constant prediction)\n', char(ones(1, 57)*32));
        else
          fprintf(FID, '\n');
        end
        fprintf(FID,'  File: %s\n', returnedFiles{f});
        fprintf(FID,'  Data: %s\n', data{d});
        fprintf(FID,'  Elapsed time: %.3f seconds\n', sum(elapsedTime{s, d}));
        fprintf(FID,'\n');

        % settings printing
        fprintf(FID,'  Settings:\n');
        fprintf(FID,'\n');
        settings = settingArray{s};
        printStructure(settings, FID, 'StructName', '    settings');
        if ~isempty(dimReduction) && ~isempty(dimReduction{d})
          printStructure(dimReduction{d}, FID, 'StructName', '    settings.dimReduction');
        end

        % performances printing

        nPerf = length(performance{s, d});
        if nPerf > 1
          fprintf(FID,'\n  Performances per iterations: \n');
          for i = 1:nPerf
            fprintf(FID,'    %.4f', performance{s, d}(i));
          end
          fprintf(FID,'\n');
        end

        % error printing
        printErrors(FID, errors{s, d});
      end
    end
  end
  
  fclose(FID);
  
  fprintf('Report files successfully generated\n')
  
end

function printErrors(FID, errors)
% Function prints errors of classifiers in all iterations if there were
% any.
  
  if isempty(errors)
    return
  end
  
  nIter = length(errors);
  errMatrix = cell(length(errors{1}), nIter);
  for i = 1:nIter
    errMatrix(:, i) = errors{i}';
  end
  errId = ~cellfun( @(x) isempty(x), errMatrix);
  if any(any(errId)) % if there was an error
    [rId, cId] = find(errId);
    errList(1) = errors{cId(1)}{rId(1)};
    errList = errList(1);
    errCounter = 1;
    for err = 2:length(rId)
      actualErr = errors{cId(err)}{rId(err)};
      inList = arrayfun(@(x) x == actualErr, errList);
      if any(inList)
        errCounter(inList) = errCounter(inList) + 1;
      else
        errList(end+1) = actualErr;
        errCounter(end+1) = 1;
      end
    end
    
    % printing
    if nIter > 1
      fprintf(FID,'\n  Errors (in %d iterations):\n', nIter);
    else
      fprintf(FID,'\n  Errors:\n');
    end
    for err = 1:length(errList)
      fprintf(FID,'    (%d): %s\n', errCounter(err), errList(err).message);
    end
  end
  
end

function datanames = createDatanames(data)
% creates shorter names for data

  nData = length(data);
  if nData < 2
    datanames = data;
    return
  end
  dataNameBase = cell(1, nData);
  
  % find unique parts of names
  for d = 1:nData
    nameBase = unique(strsplit(data{d}, {'/', '_'}));
    nameBase = nameBase(~strcmp(nameBase, 'data'));
    dataNameBase{d} = [cellfun(@(x) x(1:min(length(x), 3)), nameBase(1:end-1), 'UniformOutput', false), ...
                       nameBase{end}(1:min(length(nameBase{end}), 3))];
  end
  uniqueBase = unique([dataNameBase{:}]);
  % turn around to begin with last sorted
  uniqueBase = uniqueBase(end:-1:1);
  IDs = cell2mat(cellfun(@(x) ismember(uniqueBase, x), dataNameBase, 'UniformOutput', false)');
  notInAllID = ~all(IDs);
  datanames = arrayfun(@(x) [uniqueBase{IDs(x, :) & notInAllID}], 1:nData, 'UniformOutput', false);
  
  % ensure names - default names
  emptyNamesID = cellfun(@isempty, datanames);
  datanames(emptyNamesID) = arrayfun(@(x) ['data_', num2str(x)], 1:sum(emptyNamesID), 'UniformOutput', false);
  % ensure name if the first character is not a number
  numFirstNamesID = cellfun(@(x) isstrprop(x(1), 'digit'), datanames);
  datanames(numFirstNamesID) = cellfun(@(x) ['data_', x], datanames(numFirstNamesID), 'UniformOutput', false);
  % create different names for so far same datanames
  [C, ia, ic] = unique(datanames);
  if length(C) < nData
    for i = 1:length(ia)
      if length(datanames(ia(i) == ic)) > 1
        id = find(ia(i) == ic);
        for j = 1:length(datanames(ia(i) == ic))
          datanames{id(j)} = [datanames{id(j)}, '_', num2str(j)];
        end
      end
    end
  end
  
  %TODO: if name is still too long, make it data_1, data_2, etc.
end