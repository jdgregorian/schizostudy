% Script for testing main settings of classifiers on dataset with 180 
% subjects. The dataset uses 27 ICA components. The subjects 
% are the same as in data_FC_180subjects.mat.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC180sub = fullfile('data', 'data_FC_ica27_180subjects.mat');

% settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% summary
settingFiles = {mainSettings};
data = {FC180sub};
expname = 'exp_main_ica27';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));