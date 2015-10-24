% Script for testing main settings of classifiers

%% initialization
filename = 'mainSettings';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%%
FCdata = fullfile('data','data_FC_190subjects.mat');
prtoolsSettings

%%
FCdata = fullfile('data','data_FC_168subjects.mat');
prtoolsSettings

%%
FCdata = fullfile('data','arbabshirani','loo','adCorrAbs','180subj_all.mat');
prtoolsSettings

%%
FCdata = fullfile('data','arbabshirani','loo','adCorrPos','180subj_all.mat');
prtoolsSettings

%%
FCdata = fullfile('data','arbabshirani','loo','adCorrAbs','80subj_testing.mat');
prtoolsSettings

%%
FCdata = fullfile('data','arbabshirani','loo','adCorrPos','80subj_testing.mat');
prtoolsSettings

%%
FCdata = fullfile('data','arbabshirani','loo','adCorrAbs','100subj_training.mat');
prtoolsSettings

%%
FCdata = fullfile('data','arbabshirani','loo','adCorrPos','100subj_training.mat');
prtoolsSettings

%% traintest abs
FCdata = fullfile('data','arbabshirani');
prtoolsSettings

%% final results listing

listSettingsResults(fullfile(expfolder, filename));
