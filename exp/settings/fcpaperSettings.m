% Script for testing settings of classifiers used in FC paper (2017)
%
% Variables 'FCdata', 'filename', 'expfolder' and 'datamark' should be 
% defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data', 'data_FC_190subjects_B.mat');
end
if ~exist('filename', 'var')
  filename = 'fcpaperSettings';
end
if ~exist('expfolder', 'var')
  expfolder = fullfile('exp', 'experiments');
end 
if ~exist('datamark', 'var')
  datamark = '';
else
  datamark = ['_', datamark];
end
mkdir(expfolder, filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM
% linear - iter 100000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.options = statset('MaxIter', 100000);
settings.note = 'Linear SVM. Maximum iterations 100000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_iter100', datamark, '.mat']));

%% linear - autoscale 'off', iter 200000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 200000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 200000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter200', datamark, '.mat']));

%% quadratic
clear settings

settings.svm.kernel_function = 'quadratic';
settings.note = 'Quadratic SVM.';

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_quad', datamark, '.mat']));

%% quadratic - autoscale 'off'
clear settings

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;
settings.note = 'Quadratic SVM. Autoscale ''off''.';

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_quad_noauto', datamark, '.mat']));

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial'; 
settings.note = 'Polynomial(3) SVM.';

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_poly', datamark, '.mat']));

%% polynomial - autoscale 'off'
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 
settings.note = 'Polynomial(3) SVM. Autoscale ''off''.';

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_poly_noauto', datamark, '.mat']));

%% rbf - autoscale 'on', gridsearch 'rbf_sigma'
clear settings

settings.svm.kernel_function = 'rbf';
settings.saveClassifier = true;
settings.note = 'RBF SVM using gridsearch on sigma.';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'rbf_sigma'};
settings.gridsearch.levels = 2;
settings.gridsearch.bounds = {[10^-3, 10^3]};
settings.gridsearch.npoints = 11;
settings.gridsearch.scaling = {{'log', 'lin'}};

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_rbf_grid_1', datamark, '.mat']));

%% rbf - autoscale 'off', gridsearch 'rbf_sigma'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.saveClassifier = true;
settings.note = 'RBF SVM using gridsearch on sigma. Autoscale ''off''.';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'rbf_sigma'};
settings.gridsearch.levels = 2;
settings.gridsearch.bounds = {[10^-3, 10^3]};
settings.gridsearch.npoints = 11;
settings.gridsearch.scaling = {{'log', 'lin'}};

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_rbf_grid_1_noauto', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Random forest
% MATLAB classification forest - 11 trees
clear settings

settings.rf.nTrees = 11;
settings.iteration = 10;
settings.rf.type = 'matlab';
settings.note = 'Default settings of MATLAB classification forest with 11 trees.';

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_11t', datamark, '.mat']));

%% RF - 11 linear trees
clear settings

settings.rf.nTrees = 11;
settings.rf.type = 'classic';
settings.rf.TreeType = 'linear';
settings.rf.learning = 'bagging';
settings.iteration = 10;
settings.note = 'Random forest with linear trees. Learning by bagging.';

classifyFC(FCdata, 'rf', settings, fullfile(filename, ['rf_lin_11t', datamark, '.mat']));

%% RF - 11 linear trees - boosting, maxSplit = 10
clear settings

settings.rf.nTrees = 11;
settings.rf.type = 'classic';
settings.rf.TreeType = 'linear';
settings.rf.learning = 'boosting';
settings.rf.maxSplit = 10;
settings.rf.distance = 2;
settings.note = 'Random forest with linear trees. Learning by boosting.';

classifyFC(FCdata, 'rf', settings, fullfile(filename, ['rf_lin_11t_boost_10split', datamark, '.mat']));

%% RF - 11 linear trees - AdaBoost, maxSplit = 10
clear settings

settings.rf.nTrees = 11;
settings.rf.type = 'classic';
settings.rf.TreeType = 'linear';
settings.rf.learning = 'adaboost';
settings.rf.maxSplit = 10;
settings.rf.distance = 2;
settings.note = 'Random forest with linear trees. Learning by AdaBoost.';

classifyFC(FCdata, 'rf', settings, fullfile(filename, ['rf_lin_11t_adaboost_10split', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree
clear settings

settings.tree.type = 'linear';
settings.note = 'Default linear tree.';

classifyFC(FCdata, 'tree',settings, fullfile(filename, ['tree_lin', datamark, '.mat']));

%% MATLAB classification tree
clear settings

settings.note = 'Default MATLAB classification tree settings.';
settings.tree.type = 'matlab';

classifyFC(FCdata, 'tree', settings, fullfile(filename, ['tree_mtl', datamark, '.mat']));

%% PRTools classification tree - information gain criterion
clear settings

settings.implementation = 'prtools';
settings.tree.crit = 'infcrit';
settings.note = 'Default settings of PRTools decision tree using information gain criterion.';

classifyFC(FCdata, 'tree', settings, fullfile(filename, ['tree_prt_inf', datamark, '.mat']));

%% PRTools classification tree - Fisher criterion
clear settings

settings.implementation = 'prtools';
settings.note = 'PRTools decision tree using Fisher criterion.';
settings.tree.crit = 'fishcrit';

classifyFC(FCdata, 'tree', settings, fullfile(filename, ['tree_prt_fish', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.prior = [0.5, 0.5];
settings.note = 'Default settings of PRTools LDA.';

classifyFC(FCdata, 'lda', settings, fullfile(filename, ['lda_prtools', datamark, '.mat']));

%% LDA (matlab) - pseudoinverse
clear settings

settings.implementation = 'matlab';
settings.lda.type = 'pseudolinear';
settings.prior = [0.5, 0.5];
settings.note = 'Matlab LDA using pseudoinverse of covariance matrix.';

classifyFC(FCdata, 'lda', settings, fullfile(filename, ['lda_pseudo', datamark, '.mat']));

%% QDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.prior = [0.5, 0.5];
settings.note = 'Default settings of PRTools QDA.';

classifyFC(FCdata, 'qda', settings, fullfile(filename, ['qda_prtools', datamark, '.mat']));

%% QDA (matlab) - pseudoinverse
clear settings

settings.implementation = 'matlab';
settings.qda.type = 'pseudoquadratic';
settings.prior = [0.5, 0.5];
settings.note = 'Matlab QDA using pseudoinverse of covariance matrix.';

classifyFC(FCdata, 'qda', settings, fullfile(filename, ['qda_pseudo', datamark, '.mat']));

%% Fisher's linear discriminant (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Fisher''s linear discriminant (PRTools) has no settings.';

classifyFC(FCdata, 'fisher', settings, fullfile(filename, ['fisher', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.distance = 'euclidean';
settings.saveClassifier = true;
settings.note = 'KNN classifier using gridsearch on k.';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'k'};
settings.gridsearch.levels = 1;
settings.gridsearch.bounds = {[1, 10]};
settings.gridsearch.npoints = 10;
settings.gridsearch.scaling = {{'lin'}};

classifyFC(FCdata, 'knn', settings, fullfile(filename, ['knn_grid', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default logistic linear classifier settings in PRTools.';

classifyFC(FCdata, 'llc', settings, fullfile(filename, ['llc_prt', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.nb.distribution = 'normal';
settings.note = 'Default naive Bayes settings.';

classifyFC(FCdata, 'nb', settings, fullfile(filename, ['nb', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Artificial Neural Networks
%% ANN
clear settings

settings.note = 'ANN default settings.';
settings.iteration = 10;

classifyFC(FCdata, 'ann', settings, fullfile(filename, ['ann', datamark, '.mat']));

%% RBF
clear settings

settings.note = 'Default RBF';

classifyFC(FCdata, 'rbf', settings, fullfile(filename, ['rbf', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile(expfolder, filename));
