% Script for testing arbabshirani settings of classifiers on regular, 
% moderate and stringent denoised data (from CONN) without linear effect of
% age and sex. Arbabshirani settings using and not using gridsearch are 
% both tested.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC190sub_moderate_res  = fullfile('data', 'data_FC_190subjects_moderate_res_age_sex.mat');
FC190sub_stringent_res = fullfile('data', 'data_FC_190subjects_stringent_res_age_sex.mat');
FC190sub_B_res = fullfile('data', 'data_FC_190subjects_B_res_age_sex.mat');

% settings
mainSet = fullfile(setfolder, 'mainSettings.m');
arbabSet = fullfile(setfolder, 'arbabshiraniSettings.m');
arbabGridSet = fullfile(setfolder, 'arbabshiraniGridSettings.m');

% additional settings

% summary
settingFiles = {mainSet, arbabSet, arbabGridSet};
data = {FC190sub_moderate_res, FC190sub_stringent_res, FC190sub_B_res};
additionalSettings = {};
expname = 'exp_main_arbab_denois_res';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));