% Script for testing main settings of classifiers on Arabshirani's
% style-prepared data using training and testing dataset with absolute
% values of correlations in loo.

%% initialization
FCdata = fullfile('data','arbabshirani','loo','adCorrAbs','180subj_all.mat');
filename = 'exp_arbab_all_loo_abs';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%% test settings on Arbabshirani style data
arbabshiraniSettings