function createExperiment(expfolder, expname, settingFiles, data, addSettings)
% Function creates M-file containing all necessary settings to run the
% experiment.
%
% Input:
%    expfolder    - folder containing experiment | string
%    expname      - name of the experiment | string
%    settingFiles - files containing settings of the experiment | string or
%                   cell array of strings
%    data         - files containing data to test | string or cell array of
%                   strings
%    addSettings  - additional settings for each setting | string or cell
%                   array of strings
%
% See Also:
%   runExperiment, loadSettings, metacentrum_createExperiment

  if nargin < 5 || isempty(addSettings)
    addSettings = {''};
  end
  if ~iscell(addSettings)
    addSettings = {addSettings};
  end

  foldername = fullfile(expfolder, expname);
  if ~isdir(foldername)
    mkdir(foldername)
  end
  
  % load all settings
  [settings, resultNames] = loadSettings(settingFiles);
  % split settings and row containing classifyFC function
  classFCrow = cellfun(@(x) x(strfind(x, 'classifyFC'):end), settings, 'UniformOutput', false);
  settings = cellfun(@(x) x(1:strfind(x, 'classifyFC') - 1), settings, 'UniformOutput', false);

  % print settings with data to .m file
  FID = fopen(fullfile(foldername, [expname, '_runscript.m']), 'w');
  assert(FID ~= -1, 'Cannot open %s !', expname)
  fprintf('Printing settings to %s...\n', expname)

  fprintf(FID, '%% Running script for experiment %s\n', expname);
  fprintf(FID, '%% Created on %s\n', datestr(now));
  fprintf(FID, '\n');

  nData = length(data);
  nSettings = length(settings);
  nAddSettings = length(addSettings);
  
  % data dependent settings printing
  for d = 1:nData
    % datamark creating - needed for new classifyFC row
    dataslash = strfind(data{d}, [filesep, 'data', filesep]);
    if isempty(dataslash)
      dataslash = strfind(data{d}, ['data', filesep]);
    end
    if strcmp(data{d}(1:5), ['data', filesep])
      datamarkPrep = data{d}(5 : end);
    elseif isempty(dataslash)
      datamarkPrep = data{d};
    else
      datamarkPrep = data{d}(dataslash + 5 : end);
    end
    slashes = strfind(datamarkPrep, filesep);
    datamarkPrep(slashes) = '_';
    if ~isdir(data{d})
      datamarkPrep = datamarkPrep(1:end-4); 
    end
    
    % printing settings
    for a = 1:nAddSettings
      if strcmp(addSettings{a}, '')
        datamark = datamarkPrep;
      else
        datamark = [datamarkPrep, '_ad', num2str(a)];
      end
      for s = 1:nSettings
        fprintf(FID, '%%%% %d/%d\n\n', s + (a-1)*nSettings + (d-1)*nSettings*nAddSettings, nData*nSettings*nAddSettings);
        fprintf(FID, 'FCdata = ''%s'';\n', data{d});
        fprintf(FID, 'filename = ''%s'';\n', expname);
        fprintf(FID, '\n');
        % create new classifyFC row
        actualClassFCrow = [classFCrow{s}(1:strfind(classFCrow{s}, 'filename,') + 8) , ' ''', eval(resultNames{s}), '''));'];
        fprintf(FID, '%s', settings{s});
        % additional settings
        if ~strcmp(addSettings{a}, '')
          fprintf(FID, '%s\n\n', strrep(addSettings{a}, ';', [';', char(13)]));
        end
        fprintf(FID, '%s\n\n', actualClassFCrow);
      end
    end
  end

  fclose(FID);  
  
  % create directory for marking running tasks
  if ~isdir(fullfile(foldername, 'running'))
    mkdir(foldername, 'running')
  end
  
end
