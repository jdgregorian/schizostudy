% Script for testing prtools settings of classifiers

% initialization
expfolder = fullfile('exp', 'experiments');

% datafiles
FC190sub = fullfile('data', 'data_FC_190subjects.mat');
FC168sub = fullfile('data', 'data_FC_168subjects.mat');
FCarbab_loo_all_abs = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '180subj_all.mat');
FCarbab_loo_all_pos = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '180subj_all.mat');
FCarbab_loo_test_abs = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '80subj_testing.mat');
FCarbab_loo_test_pos = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '80subj_testing.mat');
FCarbab_loo_train_abs = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '100subj_training.mat');
FCarbab_loo_train_pos = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '100subj_training.mat');
FCarbab_traintest_abs = fullfile('data', 'arbabshirani', 'traintest', 'adCorrAbs');
FCarbab_traintest_pos = fullfile('data', 'arbabshirani', 'traintest', 'adCorrPos');

% settings
prSettings = fullfile(expfolder, 'prtoolsSettings.m');

% summary
settingFiles = {prSettings};
data = {FC190sub, FC168sub, FCarbab_loo_all_abs, FCarbab_loo_all_pos, FCarbab_loo_test_abs, ...
  FCarbab_loo_test_pos, FCarbab_loo_train_abs, FCarbab_loo_train_pos, FCarbab_traintest_abs, ...
  FCarbab_traintest_pos};
expname = 'exp_all_data_prtools';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));