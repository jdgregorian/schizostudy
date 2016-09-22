% Script for testing main settings of classifiers on dataset with
% 190 subjects and full conectivity matrices.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
DWI154sub = fullfile('data', 'data_DWI_154subjects.mat');

% main settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% additional settings
ltoSet = ['settings.crossval = ''lto'';',...
          'settings.pairing = [1:77, 1:77];'];

% summary
settingFiles = {mainSettings};
data = {DWI154sub};
additionalSettings = {ltoSet};
expname = 'exp_main_dwi';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));