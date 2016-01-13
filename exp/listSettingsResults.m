function listSettingsResults(folder)
% listSettingsResults(FOLDER) lists results of FC performance testing 
% in FOLDER to txt file. 
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
  [avgPerformance, settings, method, data, performance, elapsedTime, errors, returnedFiles, omittedFiles] = returnResults(folder);
  
  nFiles = length(returnedFiles);
  [nSettings, nData] = size(avgPerformance);

  % printing results to txt file
  FID = fopen(resultname,'w');
  assert(FID ~= -1, 'Cannot open %s !', resultname)
  fprintf('Printing results to %s...\n', resultname)
  
  % list header printing
  fprintf(FID,'---------------------------------------------------------------------------------\n');
  fprintf(FID,'------------------------- LIST OF TEST SETTINGS RESULTS -------------------------\n');
  fprintf(FID,'---------------------------------------------------------------------------------\n');
  fprintf(FID,'\n\n');
  fprintf(FID,'      Created on %s in folder %s.\n', datestr(now), folder);
  fprintf(FID,'      Number of files: %d\n', nFiles);
  fprintf(FID,'\n');
  
  % print omitted files
  if ~isempty(omittedFiles)
    fprintf(FID,'\n---------------------------------------------------------------------------------\n\n');
    fprintf(FID,'  Omitted files:\n');
    for f = 1:length(omittedFiles)
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
        fprintf(FID,'  Method: %s %s Performance: %.2f%%\n\n', method{s}, ...
          char(ones(1, 48 - length(method{s}))*32) ,avgPerformance(s, d)*100);
        fprintf(FID,'  File: %s\n', returnedFiles{f});
        fprintf(FID,'  Data: %s\n', data{d});
        fprintf(FID,'  Elapsed time: %.3f seconds\n', sum(elapsedTime{s, d}));
        fprintf(FID,'\n');

        % settings printing
        fprintf(FID,'  Settings:\n');
        fprintf(FID,'\n');
        printSettings(FID, settings{s});

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

function printSettings(FID, settings)
% Prints settings to file FID

  settingsSF = subfields(settings);
  for sf = 1:length(settingsSF)
    valueSF = eval(['settings.', settingsSF{sf}]);
    fprintf(FID,'    settings.%s = ', settingsSF{sf});
    % array settings
    if numel(valueSF) > 1 && ~ischar(valueSF)
      printArray(FID, valueSF);
    % non-array value
    else
      printVal(FID, valueSF);
    end
    fprintf(FID,';\n');
  end
end

function printVal(FID, val)
% function checks the class of value and prints it in appropriate format
  
  if isempty(val)
    if iscell(val)
      fprintf(FID,'{}');
    else
      fprintf(FID,'[]');
    end
  elseif iscell(val) || (numel(val) > 1 && ~ischar(val))
  % cell or any kind of array (except char)
    printArray(FID, val);
  else
    switch class(val)
      case 'char'
        fprintf(FID,'''%s''', val);
      case 'double'
        if (isnan(val) || val == Inf || mod(val,1))
          fprintf(FID,'%f', val);
        else
          fprintf(FID,'%d', val);
        end
      case 'logical'
        if val
          fprintf(FID,'true');
        else
          fprintf(FID,'false');
        end
      case 'function_handle'
        fprintf(FID,'@%s', func2str(val));
      otherwise
        fprintf(FID,'%s %dx%d', class(val), size(val,1), size(val,2));
    end
  end
end

function printArray(FID, val)
% function prints array

  % cell array
  if iscell(val)
    fprintf(FID,'{');
    % first row
    printVal(FID, val{1,1})
    for c = 2:size(val,2)
      fprintf(FID,', ');
      printVal(FID, val{1,c})
    end
    % rest of rows
    for r = 2:size(val,1)
      fprintf(FID,'; ');
      printVal(FID, val{r,1})
      for c = 2:size(val,2)
        fprintf(FID,', ');
        printVal(FID, val{r,c})
      end
    end
    fprintf(FID,'}');
  % other arrays
  else
    fprintf(FID,'[');
    % first row
    printVal(FID, val(1,1))
    for c = 2:size(val,2)
      fprintf(FID,', ');
      printVal(FID, val(1,c))
    end
    % rest of rows
    for r = 2:size(val,1)
      fprintf(FID,'; ');
      printVal(FID, val(r,1))
      for c = 2:size(val,2)
        fprintf(FID,', ');
        printVal(FID, val(r,c))
      end
    end
    fprintf(FID,']');
  end
end

function sf = subfields(ThisStruct)
% sf = subfields(ThisStruct) returns cell array of all fields of structure 
% ThisStruct except structure names.

   sf = fieldnames(ThisStruct);
   Nsf = length(sf);
   deletesf = false(1,Nsf);
   for fnum = 1:Nsf
     if isstruct(ThisStruct.(sf{fnum}))
       cn = subfields(ThisStruct.(sf{fnum}));
       sf = cat(1, sf, strcat(sf(fnum), '.', cn));
       deletesf(fnum) = true;
     end
   end
   sf(deletesf) = []; % delete structure names

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