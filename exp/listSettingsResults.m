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
  fileList = dir([folder, filesep, '*.mat']);
  nFiles = length(fileList);
  
  % loading data
  settings = cell(nFiles,1);
  method = cell(nFiles,1);
  data = cell(nFiles,1);
  performance = cell(nFiles,1);
  avgPerformance = zeros(nFiles,1);
  errors = cell(nFiles,1);
  nEmptyFiles = 0;
  usefulFiles = true(nFiles,1);
  
  fprintf('Loading data...\n')
  neededVariables = {'settings', 'method', 'data', 'performance', 'avgPerformance', 'errors'};
  for f = 1:nFiles
    variables = load([folder filesep fileList(f).name], neededVariables{:});
    if all(isfield(variables, neededVariables(1:end-1)))
      settings{f - nEmptyFiles} = variables.settings;
      method{f - nEmptyFiles} = variables.method;
      data{f - nEmptyFiles} = variables.data;
      performance{f - nEmptyFiles} = variables.performance;
      avgPerformance(f - nEmptyFiles) = variables.avgPerformance;
      if isfield(variables, 'errors')
        errors{f-nEmptyFiles} = variables.errors;
      end
    else
      nEmptyFiles = nEmptyFiles + 1;
      usefulFiles(f) = false;
    end
  end
  
  % use only non-empty fields
  nFiles = nFiles - nEmptyFiles;
  fileList = fileList(usefulFiles);

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
  
  for f = 1:nFiles
    % file header printing
    fprintf(FID,'\n---------------------------------------------------------------------------------\n\n');
    fprintf(FID,'  Method: %s %s Performance: %.2f%%\n', method{f}, ...
      char(ones(1, 48 - length(method{f}))*32) ,avgPerformance(f)*100);
    fprintf(FID,'  File: %s\n', fileList(f).name);
    fprintf(FID,'  Data: %s\n', data{f});
    fprintf(FID,'\n');
    
    % settings printing
    fprintf(FID,'  Settings:\n');
    fprintf(FID,'\n');
    printSettings(FID, settings{f});
    
    % performances printing
    nPerf = length(performance{f});
    if nPerf > 1
      fprintf(FID,'\n  Performances per iterations: \n');
      for i = 1:nPerf
        fprintf(FID,'    %.4f', performance{f}(i));
      end
      fprintf(FID,'\n');
    end
    
    % error printing
    printErrors(FID, errors{f});
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
      % cell array
      if iscell(valueSF)
        fprintf(FID,'{ ');
        % first row
        printVal(FID, valueSF{1,1})
        for c = 2:size(valueSF,2)
          fprintf(FID,', ');
          printVal(FID, valueSF{1,c})
        end
        % rest of rows
        for r = 2:size(valueSF,1)
          fprintf(FID,'; ');
          printVal(FID, valueSF{r,1})
          for c = 2:size(valueSF,2)
            fprintf(FID,', ');
            printVal(FID, valueSF{r,c})
          end
        end
        fprintf(FID,'}');
      % other arrays
      else
        fprintf(FID,'[ ');
        % first row
        printVal(FID, valueSF(1,1))
        for c = 2:size(valueSF,2)
          fprintf(FID,', ');
          printVal(FID, valueSF(1,c))
        end
        % rest of rows
        for r = 2:size(valueSF,1)
          fprintf(FID,'; ');
          printVal(FID, valueSF(r,1))
          for c = 2:size(valueSF,2)
            fprintf(FID,', ');
            printVal(FID, valueSF(r,c))
          end
        end
        fprintf(FID,']');
      end
    % non-array value
    else
      printVal(FID, valueSF);
    end
    fprintf(FID,';\n');
  end
end

function printVal(FID, val)
% function checks the class of value and prints it in appropriate format

  isdecimalnumber = @(x) ~mod(x,1);
  
  if isempty(val)
    fprintf(FID,'[]');
  else
    switch class(val)
      case 'char'
        fprintf(FID,'''%s''', val);
      case 'double'
        if val~= Inf && isdecimalnumber(val)
          fprintf(FID,'%d', val);
        else
          fprintf(FID,'%f', val);
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