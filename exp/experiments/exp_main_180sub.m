% Script for testing main settings of classifiers on dataset with 180 
% subjects. The dataset was gained through reduction of 
% data_FC_190subjects_B.mat by excluding randomly chosen patients to gain 
% balanced dataset (90 patients : 90 controls). The groups are matched on
% age and sex.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC180sub = fullfile('data', 'data_FC_180subjects.mat');

% settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% summary
settingFiles = {mainSettings};
data = {FC180sub};
expname = 'exp_main_180sub';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));