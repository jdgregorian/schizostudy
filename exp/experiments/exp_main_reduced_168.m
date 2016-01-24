% Script for testing some of main settings of classifiers on dataset with
% 168 subjects (reduced from data_FC_190subjects.mat by excluding
% individuals with motion index > 0.004).

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC168sub = fullfile('data', 'data_FC_168subjects.mat');

% settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% summary
settingFiles = {mainSettings};
data = {FC168sub};
expname = 'exp_main_reduced_168';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));