function createExperiment(expfolder, expname, settingFiles, data)
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

  foldername = fullfile(expfolder, expname);
  mkdir(foldername)
  
  % load all settings
  [settings, resultNames] = loadSettings(settingFiles);
  % split settings and row containing classifyFC function
  classFCrow = cellfun(@(x) x(strfind(x, 'classifyFC'):end), settings, 'UniformOutput', false);
  settings = cellfun(@(x) x(1:strfind(x, 'classifyFC')-1), settings, 'UniformOutput', false);

  % print settings with data to .m file
  FID = fopen(fullfile(foldername, [expname, '.m']), 'w');
  assert(FID ~= -1, 'Cannot open %s !', expname)
  fprintf('Printing settings to %s...\n', expname)

  fprintf(FID, '%% Script for experiment %s\n', expname);
  fprintf(FID, '%% Created on %s\n', datestr(now));
  fprintf(FID, '\n');

  nData = length(data);
  nSettings = length(settings);
  % data dependent settings printing
  for d = 1:nData
    slashes = strfind(data{d}, filesep);
    if isdir(data{d})
      datamark = data{d}(5:end);
      datamark(slashes - 4) = '_';
    else
      datamark = ['_', data{d}(slashes(end)+1:end-4)]; % needed for new classifyFC row
    end
    for s = 1:nSettings
      fprintf(FID, '%%%% %d/%d\n\n', s + (d-1)*nSettings, nData*nSettings);
      fprintf(FID, 'FCdata = ''%s'';\n', data{d});
      fprintf(FID, 'filename = ''%s'';\n', expname);
      fprintf(FID, '\n');
      % create new classifyFC row
      actualClassFCrow = [classFCrow{s}(1:strfind(classFCrow{s}, 'filename,') + 8) , ' ''', eval(resultNames{s}), '''));'];
      fprintf(FID, '%s', settings{s});
      fprintf(FID, '%s\n\n', actualClassFCrow);
    end
  end

  fclose(FID);  
  
  % create directory for marking running tasks
  mkdir(foldername, 'running')
  
end