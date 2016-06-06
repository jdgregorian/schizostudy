% Script for testing main and arbabshirani settings of classifiers on
% moderate and stringent denoised data (from CONN). Arbabshirani settings
% using and not using gridsearch are both tested.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC190sub_moderate = fullfile('data', 'data_FC_190subjects_moderate.mat');
FC190sub_stringent = fullfile('data', 'data_FC_190subjects_stringent.mat');

% settings
mainSet = fullfile(setfolder, 'mainSettings.m');
arbabSet = fullfile(setfolder, 'arbabshiraniSettings.m');
arbabGridSet = fullfile(setfolder, 'arbabshiraniGridSettings.m');

% additional settings

% summary
settingFiles = {mainSet, arbabSet, arbabGridSet};
data = {FC190sub_moderate, FC190sub_stringent};
additionalSettings = {};
expname = 'exp_main_arbab_denois';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));