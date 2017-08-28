% Script for testing main settings of classifiers on dataset with 180 
% subjects. The dataset uses 193 regions from Craddock atlas. The subjects 
% are the same as in data_FC_180subjects.mat. The regions were reduced from
% data_FC_craddock200_180subjects.mat because of NaN values in some
% regions.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC180sub = fullfile('data', 'data_FC_craddock193_180subjects.mat');

% settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% summary
settingFiles = {mainSettings};
data = {FC180sub};
expname = 'exp_main_craddock193';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));