% Script for testing main settings of classifiers on Arabshirani's
% style-prepared data using training and testing dataset with positive and
% absolute correlations in loo and traintest modes.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FCarbab_loo_all_abs = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '180subj_all.mat');
FCarbab_loo_all_pos = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '180subj_all.mat');
FCarbab_loo_test_abs = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '80subj_testing.mat');
FCarbab_loo_test_pos = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '80subj_testing.mat');
FCarbab_loo_train_abs = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '100subj_training.mat');
FCarbab_loo_train_pos = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '100subj_training.mat');
FCarbab_traintest_abs = fullfile('data', 'arbabshirani', 'traintest', 'adCorrAbs');
FCarbab_traintest_pos = fullfile('data', 'arbabshirani', 'traintest', 'adCorrPos');

% settings
arbabSettings = fullfile(setfolder, 'arbabshiraniSettings.m');

% summary
settingFiles = {arbabSettings};
data = {FCarbab_loo_all_abs, FCarbab_loo_all_pos, FCarbab_loo_test_abs, ...
  FCarbab_loo_test_pos, FCarbab_loo_train_abs, FCarbab_loo_train_pos, FCarbab_traintest_abs, ...
  FCarbab_traintest_pos};
expname = 'exp_arbab_old_data';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));