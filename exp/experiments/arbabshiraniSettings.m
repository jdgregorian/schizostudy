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
settings.svm.boxconstraint = 1.5;

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear', datamark, '.mat']));

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.boxconstraint = 0.12;
settings.svm.polyorder = 3;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_poly', datamark, '.mat']));

%% rbf
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.boxconstraint = 1.25;
settings.svm.rbf_sigma = 1;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_rbf', datamark, '.mat']));

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
%% LDA
clear settings

settings.lda.type = 'linear';

classifyFC(FCdata, 'lda', settings, fullfile(filename, ['lda', datamark, '.mat']));

%% QDA
clear settings

settings.qda.type = 'quadratic';

classifyFC(FCdata, 'qda', settings, fullfile(filename, ['qda', datamark, '.mat'])); 


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