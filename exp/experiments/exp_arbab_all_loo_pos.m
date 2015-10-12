% Script for testing main settings of classifiers on Arabshirani's
% style-prepared data using training and testing dataset with positive
% correlations in loo.

%% initialization
FCdata = fullfile('data','arbabshirani','loo','adCorrPos','180subj_all.mat');
filename = 'exp_arbab_all_loo_pos';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%% test settings on Arbabshirani style data
arbabshiraniSettings