% Script for testing main settings of classifiers on Arabshirani's
% style-prepared data using training dataset with positive correlations 
% in loo.

%% initialization
FCdata = fullfile('data','arbabshirani','loo','adCorrPos','100subj_training.mat');
filename = 'exp_arbab_training_loo_pos';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%% test settings on Arbabshirani style data
arbabshiraniSettings