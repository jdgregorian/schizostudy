% Script for testing main settings of classifiers

%% initialization
filename = 'exp_all_data_prtools';
expfolder = fullfile('exp', 'experiments');
mkdir(expfolder,filename)

%%
FCdata = fullfile('data', 'data_FC_190subjects.mat');
datamark = '190sub';
prtoolsSettings

%%
FCdata = fullfile('data', 'data_FC_168subjects.mat');
datamark = '168sub';
prtoolsSettings

%%
FCdata = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '180subj_all.mat');
datamark = '180sub_all_abs';
prtoolsSettings

%%
FCdata = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '180subj_all.mat');
datamark = '180sub_all_pos';
prtoolsSettings

%%
FCdata = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '80subj_testing.mat');
datamark = '80sub_test_abs';
prtoolsSettings

%%
FCdata = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '80subj_testing.mat');
datamark = '80sub_test_pos';
prtoolsSettings

%%
FCdata = fullfile('data', 'arbabshirani', 'loo', 'adCorrAbs', '100subj_training.mat');
datamark = '100sub_train_abs';
prtoolsSettings

%%
FCdata = fullfile('data', 'arbabshirani', 'loo', 'adCorrPos', '100subj_training.mat');
datamark = '100sub_train_pos';
prtoolsSettings

%% traintest abs
FCdata = fullfile('data', 'arbabshirani', 'traintest', 'adCorrAbs');
datamark = '180sub_traintest_abs';
prtoolsSettings

%% traintest pos
FCdata = fullfile('data', 'arbabshirani', 'traintest', 'adCorrPos');
datamark = '180sub_traintest_pos';
prtoolsSettings

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile(expfolder, filename));
