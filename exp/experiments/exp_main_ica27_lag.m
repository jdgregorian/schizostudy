% Script for testing main settings of classifiers on dataset with 180 
% subjects. The dataset uses lagged (absolute and positive) 27 ICA 
% components. The subjects are the same as in data_FC_180subjects.mat.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC180sub_abs = fullfile('data', 'data_FC_ica27_lag_abs_180sub.mat');
FC180sub_pos = fullfile('data', 'data_FC_ica27_lag_pos_180sub.mat');

% settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% summary
settingFiles = {mainSettings};
data = {FC180sub_abs, FC180sub_pos};
expname = 'exp_main_ica27_lag';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));