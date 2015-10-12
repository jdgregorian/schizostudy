% Script for testing main settings of classifiers on Arabshirani's
% style-prepared data using training and testing dataset with positive 
% correlations.

%% initialization
FCdata = fullfile('data','arbabshirani');
filename = 'exp_arbab_traintest_pos';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%% test settings on Arbabshirani style data
arbabshiraniSettings