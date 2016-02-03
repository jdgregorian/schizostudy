% Script for testing main settings of classifiers on dataset with
% 190 subjects and full conectivity matrices.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC190sub = fullfile('data', 'data_FC_190subjects_B.mat');

% settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% summary
settingFiles = {mainSettings};
data = {FC190sub};
expname = 'exp_main';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));