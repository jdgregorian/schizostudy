% Script for testing Arbabshirani's settings of classifiers 
%
% Variables 'FCdata', 'filename', 'expfolder' and 'datamark' should be 
% defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data','data_FC_190subjects.mat');
end
if ~exist('filename', 'var')
  filename = 'arbabshiraniSettings';
end
if ~exist('expfolder', 'var')
  expfolder = fullfile('exp','experiments');
end 
if ~exist('datamark', 'var')
  datamark = '';
else
  datamark = ['_', datamark];
end
mkdir(expfolder,filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM
% linear
clear settings

settings.svm.kernel_function = 'linear';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear', datamark, '.mat']));

%% linear - autoscale 'off'
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_linear_noauto', datamark, '.mat']));

%% quadratic
clear settings

settings.svm.kernel_function = 'quadratic';

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_quad', datamark, '.mat']));

%% quadratic - autoscale 'off'
clear settings

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_quad_noauto', datamark, '.mat']));

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial'; 

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_poly', datamark, '.mat']));

%% polynomial - autoscale 'off'
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_poly_noauto', datamark, '.mat']));

%% rbf - autoscale 'on'
clear settings

settings.svm.kernel_function = 'rbf';

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_rbf', datamark, '.mat']));

%% rbf - autoscale 'off'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_rbf_noauto', datamark, '.mat']));

%% mlp
clear settings

settings.svm.kernel_function = 'mlp';

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_mlp', datamark, '.mat']));

%% mlp - autoscale 'off'
clear settings

settings.svm.kernel_function = 'mlp';
settings.svm.autoscale = false;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_mlp_noauto', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRTools classification tree - information gain criterion
clear settings

settings.implementation = 'prtools';
settings.tree.crit = 'infcrit';
settings.note = 'Default settings of PRTools decision tree using information gain criterion.';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_inf',datamark,'.mat']));

%% PRTools classification tree - Fisher criterion
clear settings

settings.implementation = 'prtools';
settings.note = 'PRTools decision tree using Fisher criterion.';
settings.tree.crit = 'fishcrit';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_fish',datamark,'.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA (PRTools) - should be from MATLAB but it cannot handle high dimension
clear settings

settings.implementation = 'prtools';
settings.lda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools LDA.';

classifyFC(FCdata, 'lda', settings, fullfile(filename, ['lda_prtools', datamark, '.mat']));

%% QDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.qda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools QDA.';

classifyFC(FCdata, 'qda', settings, fullfile(filename, ['qda_prtools', datamark, '.mat']));


%% Fisher's linear discriminant (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Fisher''s linear discriminant (PRTools) has no settings.';

classifyFC(FCdata,'fisher',settings, fullfile(filename, ['fisher', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.k = 1;
settings.knn.distance = 'euclidean';
settings.note = 'Default settings of KNN classifier.';

classifyFC(FCdata,'knn',settings, fullfile(filename, ['knn_1', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default logistic linear classifier settings in PRTools.';

classifyFC(FCdata,'llc',settings, fullfile(filename,['llc',datamark,'.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default PRTools naive Bayes settings.';

classifyFC(FCdata, 'nb', settings, fullfile(filename,['nb',datamark,'.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Artificial Neural Networks
% linear perceptron
clear settings

settings.note = 'Linear perceptron has no settings.';

classifyFC(FCdata, 'perc', settings, fullfile(filename, ['perc_default', datamark, '.mat']));

%% ANN
clear settings

settings.note = 'ANN default settings.';
settings.iteration = 10;

classifyFC(FCdata, 'ann', settings, fullfile(filename, ['ann_default', datamark, '.mat']));

%% ANN - Arbabshirani's settings
clear settings

settings.note = 'ANN with Arbabshirani''s settings.';
settings.ann.hiddenSizes = [6 6 6]; % [4 4 4] - on reduced
settings.iteration = 10;

classifyFC(FCdata, 'ann', settings, fullfile(filename, ['ann_arbab', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Radial Basis Function Networks
% RBF default
clear settings

settings.note = 'RBF default settings.';

classifyFC(FCdata, 'rbf', settings, fullfile(filename, ['rbf_default', datamark, '.mat']));

%% final results listing

listSettingsResults(fullfile(expfolder, filename));