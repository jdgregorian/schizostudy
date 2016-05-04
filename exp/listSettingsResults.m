function listSettingsResults(folder)
% listSettingsResults(FOLDER) lists results of FC performance testing 
% in FOLDER to txt file. 
%
% Input:
%   folder - directory containing results | string
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
  
  folderPos = strfind(folder, filesep);
  foldername = folder(folderPos(end) + 1 : end);
  resultname = [folder, filesep, foldername, '.txt'];
  
  % loading data
  [avgPerformance, settingArray, method, data, results, returnedFiles, omittedFiles] = returnResults(folder);
  
  performance = results.performance;
  elapsedTime = results.elapsedTime;
  errors = results.errors;
  classPred = results.class;
  actualPerf = results.actualPerformance;
  
  nFiles = length(returnedFiles);
  nOmitted = length(omittedFiles);
  [nSettings, nData] = size(avgPerformance);

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
        printStructure(settings, FID);

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