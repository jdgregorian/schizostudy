% Script for testing main settings of classifiers on dataset with 180 
% subjects using AAL atlas with 90 regions. The dataset uses lagged 
% FC matrices. The subjects are the same as in data_FC_180subjects.mat.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC180sub_abs = fullfile('data', 'data_FC_aal90_lag_abs_180sub.mat');

% settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% summary
settingFiles = {mainSettings};
data = {FC180sub_abs};
expname = 'exp_main_aal90_lag_abs';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));