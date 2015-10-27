function runExperiment(settingFiles, data, expname)
% Runs experiment 'expname'

  % initialization
  if nargin < 1
    help runExperiment
    return
  end
  if nargin < 2
    data = fullfile('data','data_FC_190subjects.mat');
    if nargin < 3
      expname = ['exp_', data, '_', char(datetime)];
    end
  end
  
  if ~iscell(settingFiles)
    settingFiles = {settingFiles};
  end
  if ~iscell(data)
    data = {data};
  end
  expfolder = fullfile('exp','experiments');
  
  scriptname = fullfile(expfolder, expname, [expname, '.m']);
  % if experiment was not created yet
  if ~isdir(fullfile(expfolder, expname)) || ~exist(scriptname, 'file')
    createExperiment(expfolder, expname, settingFiles, data)
  end
  
  % run experiment
  [settings, resultNames] = loadSettings(scriptname);
  
  
end

function [settings, resultNames] = loadSettings(settingFiles)
% loads settings in cell array 'settinsFiles'
  
  nFiles = length(settingFiles);
  settings = {};
  for f = 1:nFiles
    str = fileread(settingFiles{f}); % read the whole file
    splits = strsplit(str, '%%'); % split according to %% marks
    % find parts with settings in file
    usefulParts = cell2mat(cellfun(@(x) ~isempty(strfind(x,'classifyFC')), splits, 'UniformOutput', false));
    settings(end+1:end+sum(usefulParts)) = splits(usefulParts);
  end
  % return % back to each setting
  settings = cellfun(@(x) ['%', x], settings, 'UniformOutput', false);
  
  % extract row with classifyFC function call
  classFCrow = cellfun(@(x) x(strfind(x,'classifyFC'):end), settings, 'UniformOutput', false);
  % extract names of results of settings
  resultNames = cellfun(@(x) x(strfind(x, 'filename,')+9 : strfind(x, '));')-1 ), classFCrow, 'UniformOutput', false);
  
end

function createExperiment(expfolder, expname, settingFiles, data)
% function creates M-file containing all necessary settings to run the
% experiment

  mkdir(fullfile(expfolder, expname))
  % load all settings
  [settings, resultNames] = loadSettings(settingFiles);

  % print settings with data to .m file
  FID = fopen(fullfile(expfolder, expname, [expname, '.m']),'w');
  assert(FID ~= -1, 'Cannot open %s !', expname)
  fprintf('Printing settings to %s...\n', expname)

  fprintf(FID, '%% Script for experiment %s\n', expname);
  fprintf(FID, '%% Created on %s\n', char(datetime));
  fprintf(FID, '\n');

  nData = length(data);
  nSettings = length(settings);
  for d = 1:nData
    slashes = strfind(data{d}, filesep);
    datamark = ['_', data{d}(slashes(end)+1:end-4)];
    for s = 1:nSettings
      fprintf(FID, '%%%% %d/%d\n\n', s + (d-1)*nSettings, nData*nSettings);
      fprintf(FID, 'FCdata = ''%s'';\n', data{d});
      fprintf(FID, 'datamark = ''%s'';\n', datamark);
      fprintf(FID, 'filename = ''%s'';\n', expname);
      fprintf(FID, '\n');
      resName = eval(resultNames{s}); % TODO: write resName instead of ['name',datamark,'.mat'] to classifyFC row 
      fprintf(FID, '%s\n', settings{s});
    end
  end

  fclose(FID);  
  
end