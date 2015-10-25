% Script for testing main settings of classifiers on Arabshirani's
% style-prepared data using training and testing dataset with absolute 
% values of correlations.

%% initialization
FCdata = fullfile('data', 'arbabshirani', 'traintest', 'adCorrAbs');
filename = 'exp_arbab_traintest_abs';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%% test settings on Arbabshirani style data
arbabshiraniSettings