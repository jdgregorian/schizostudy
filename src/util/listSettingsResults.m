function listSettingsResults(folder)
% listSettingsResults(FOLDER) lists results of FC performance testing 
% in FOLDER to txt file. 

  if nargin == 0
    help listSettingsResults
    return
  end
  
  resultname = [folder, '.txt'];
  fileList = dir([folder, filesep, '*.mat']);
  nFiles = length(fileList);
  
  % loading data
  settings = cell(nFiles,1);
  method = cell(nFiles,1);
  data = cell(nFiles,1);
  performance = cell(nFiles,1);
  avgPerformance = zeros(nFiles,1);
  
  fprintf('Loading data...\n')
  for f = 1:nFiles
    variables = load([folder filesep fileList(f).name], 'settings', 'method', 'data', 'performance', 'avgPerformance');
    if all(isfield(variables,{'settings', 'method', 'data', 'performance', 'avgPerformance'}))
      settings{f} = variables.settings;
      method{f} = variables.method;
      data{f} = variables.data;
      performance{f} = variables.performance;
      avgPerformance(f) = variables.avgPerformance;
    end
  end

  % printing results to txt file
  fprintf('Printing results to %s...\n', resultname)
  FID = fopen(resultname,'w');
  fprintf(FID,'---------------------------------------------------------------------------------\n');
  fprintf(FID,'------------------------- LIST OF TEST SETTINGS RESULTS -------------------------\n');
  fprintf(FID,'---------------------------------------------------------------------------------\n');
  fprintf(FID,'\n\n');
  fprintf(FID,'      Created %s in folder %s.\n', datestr(now), folder);
  fprintf(FID,'      Number of files: %d\n', nFiles);
  fprintf(FID,'\n');
  
  for f = 1:nFiles
    fprintf(FID,'\n---------------------------------------------------------------------------------\n\n');
    fprintf(FID,'  Method: %s %s Performance: %.2f%%\n', method{f}, ...
      char(ones(1, 48 - length(method{f}))*32) ,avgPerformance(f)*100);
    fprintf(FID,'  File: %s\n', fileList(f).name);
    fprintf(FID,'  Data: %s\n', data{f});
    fprintf(FID,'\n');
    fprintf(FID,'  Settings:\n');
    fprintf(FID,'\n');
    printSettings(FID, settings{f});
    
    nPerf = length(performance{f});
    if nPerf > 1
      fprintf(FID,'\n  Performances per iterations: \n');
      for i = 1:nPerf
        fprintf(FID,'    %.4f', performance{f}(i));
      end
      fprintf(FID,'\n');
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
    if iscell(valueSF)
      fprintf(FID,'{ ');
      for c = 1:length(valueSF) % works only for 1D cell array
        printVal(FID, valueSF{c})
        fprintf(FID,' ');
      end
      fprintf(FID,'}');
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