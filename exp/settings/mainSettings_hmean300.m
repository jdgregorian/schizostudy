% Script for testing main settings of classifiers with dimension reduction
% by highest means to 300.
%
% Variables 'FCdata', 'filename', 'expfolder' and 'datamark' should be 
% defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data', 'data_FC_190subjects_B.mat');
end
if ~exist('filename', 'var')
  filename = 'mainSettings_hmean300';
end
if ~exist('expfolder', 'var')
  expfolder = fullfile('exp', 'experiments');
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
settings.note = 'Linear SVM. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_hmean300', datamark, '.mat']));

%% linear - autoscale 'off'
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.note = 'Linear SVM. Autoscale ''off''. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_linear_noauto_hmean300', datamark, '.mat']));

%% quadratic
clear settings

settings.svm.kernel_function = 'quadratic';
settings.note = 'Quadratic SVM. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_quad_hmean300', datamark, '.mat']));

%% quadratic - autoscale 'off'
clear settings

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;
settings.note = 'Quadratic SVM. Autoscale ''off''. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_quad_noauto_hmean300', datamark, '.mat']));

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial'; 
settings.note = 'Polynomial(3) SVM. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_poly_hmean300', datamark, '.mat']));

%% polynomial - autoscale 'off'
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 
settings.note = 'Polynomial(3) SVM. Autoscale ''off''. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_poly_noauto_hmean300', datamark, '.mat']));

%% rbf - autoscale 'on', gridsearch 'rbf_sigma'
clear settings

settings.svm.kernel_function = 'rbf';
settings.note = 'RBF SVM using gridsearch on sigma. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'rbf_sigma'};
settings.gridsearch.levels = 2;
settings.gridsearch.bounds = {[10^-3, 10^3]};
settings.gridsearch.npoints = 11;
settings.gridsearch.scaling = {{'log', 'lin'}};

perf = classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_rbf_grid_hmean300', datamark, '.mat']));

%% rbf - autoscale 'off', gridsearch 'rbf_sigma'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.note = 'RBF SVM using gridsearch on sigma. Autoscale ''off''. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'rbf_sigma'};
settings.gridsearch.levels = 2;
settings.gridsearch.bounds = {[10^-3, 10^3]};
settings.gridsearch.npoints = 11;
settings.gridsearch.scaling = {{'log', 'lin'}};

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_rbf_grid_noauto_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Random forest
% MATLAB classification forest - 11 trees
clear settings

settings.rf.nTrees = 11;
settings.iteration = 10;
settings.rf.type = 'matlab';
settings.note = 'Default settings of MATLAB classification forest with 11 trees. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_11t_hmean300', datamark, '.mat']));

%% RF - 11 linear trees
clear settings

settings.rf.nTrees = 11;
settings.rf.type = 'classic';
settings.rf.TreeType = 'linear';
settings.rf.learning = 'bagging';
settings.iteration = 10;
settings.note = 'Random forest with linear trees. Learning by bagging. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'rf', settings, fullfile(filename, ['rf_lin_11t_hmean300', datamark, '.mat']));

%% RF - 11 linear trees - boosting, maxSplit = 10
clear settings

settings.rf.nTrees = 11;
settings.rf.type = 'classic';
settings.rf.TreeType = 'linear';
settings.rf.learning = 'boosting';
settings.rf.maxSplit = 10;
settings.rf.distance = 2;
settings.note = 'Random forest with linear trees. Learning by boosting. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'rf', settings, fullfile(filename, ['rf_lin_11t_boost_10split_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree
clear settings

settings.tree.type = 'linear';
settings.note = 'Default linear tree. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'tree',settings, fullfile(filename, ['tree_lin_hmean300', datamark, '.mat']));

%% MATLAB classification tree
clear settings

settings.tree.type = 'matlab';
settings.note = 'Default MATLAB classification tree settings. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'tree', settings, fullfile(filename, ['tree_mtl_hmean300', datamark, '.mat']));

%% PRTools classification tree - information gain criterion
clear settings

settings.implementation = 'prtools';
settings.tree.crit = 'infcrit';
settings.note = 'Default settings of PRTools decision tree using information gain criterion. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'tree', settings, fullfile(filename, ['tree_prt_inf_hmean300', datamark, '.mat']));

%% PRTools classification tree - Fisher criterion
clear settings

settings.implementation = 'prtools';
settings.note = 'PRTools decision tree using Fisher criterion. Dimension reduced by highest means to 300.';
settings.tree.crit = 'fishcrit';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'tree', settings, fullfile(filename, ['tree_prt_fish_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.prior = [0.5, 0.5];
settings.note = 'Default settings of PRTools LDA. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'lda', settings, fullfile(filename, ['lda_prtools_hmean300', datamark, '.mat']));

%% QDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.prior = [0.5, 0.5];
settings.note = 'Default settings of PRTools QDA. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'qda', settings, fullfile(filename, ['qda_prtools_hmean300', datamark, '.mat']));

%% Fisher's linear discriminant (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Fisher''s linear discriminant (PRTools) has no settings. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'fisher', settings, fullfile(filename, ['fisher_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.distance = 'euclidean';
settings.note = 'KNN classifier using gridsearch on k. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'k'};
settings.gridsearch.levels = 1;
settings.gridsearch.bounds = {[1, 10]};
settings.gridsearch.npoints = 10;
settings.gridsearch.scaling = {{'lin'}};

classifyFC(FCdata, 'knn', settings, fullfile(filename, ['knn_grid_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default logistic linear classifier settings in PRTools. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'llc', settings, fullfile(filename, ['llc_prtools_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.nb.distribution = 'normal';
settings.note = 'Default naive Bayes settings. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'nb', settings, fullfile(filename, ['nb_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Artificial Neural Networks
% ANN
clear settings

settings.iteration = 10;
settings.note = 'ANN default settings. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

classifyFC(FCdata, 'ann', settings, fullfile(filename, ['ann_hmean300', datamark, '.mat']));

%% RBF
clear settings

settings.note = 'Default RBF. Dimension reduced by highest means to 300.';

settings.dimReduction.name = 'hmean';
settings.dimReduction.nDim = 300;

perf = classifyFC(FCdata, 'rbf', settings, fullfile(filename, ['rbf_hmean300', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile(expfolder, filename));