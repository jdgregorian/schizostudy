% Script for testing main settings of classifiers with dimension reduced by
% highest means to 40, 80, 150, 300, 500, 1000, 2000

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC190sub_B = fullfile('data', 'data_FC_190subjects_B.mat');

% settings
main40 = fullfile(setfolder, 'mainSettings_hmean40.m');
main80 = fullfile(setfolder, 'mainSettings_hmean80.m');
main150 = fullfile(setfolder, 'mainSettings_hmean150.m');
main300 = fullfile(setfolder, 'mainSettings_hmean300.m');
main500 = fullfile(setfolder, 'mainSettings_hmean500.m');
main1000 = fullfile(setfolder, 'mainSettings_hmean1000.m');
main2000 = fullfile(setfolder, 'mainSettings_hmean2000.m');

% summary
settingFiles = {main40, main80, main150, main300, main500, main1000, main2000};
data = {FC190sub_B};
expname = 'exp_main_hmean';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));