% Script for testing settings of classifiers on Arabshirani's
% style-prepared data.
%
% Needs variables 'FCdata', 'filename' and 'expfolder' defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data','data_FC_190subjects', datamark, '.mat');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM
% linear
clear settings

settings.svm.kernel_function = 'linear';

classifyFC(FCdata,'svm',settings,fullfile(filename, ['svm_linear', datamark, '.mat']));

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
%% Random forest
% MATLAB classification forest - 11 trees
clear settings

settings.forest.nTrees = 11;
settings.iteration = 10;
settings.note = 'Default settings of MATLAB classification forest with 11 trees.';

classifyFC(FCdata,'mrf',settings, fullfile(filename, ['mrf_11t', datamark, '.mat']));

%% RF - 11 linear trees
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.iteration = 10;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t', datamark, '.mat']));

%% RF - 11 linear trees + pca(20)
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.iteration = 10;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_pca20', datamark, '.mat']));

%% RF - 11 linear trees - distance mahal
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = 'mahal';
settings.iteration = 10;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_mahal', datamark, '.mat']));

%% RF - 11 linear trees - distance Inf
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = Inf;
settings.iteration = 10;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_distInf', datamark, '.mat']));

%% RF - 11 linear trees - distance 1
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = 1;
settings.iteration = 10;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_dist1', datamark, '.mat']));

%% RF - 11 linear trees - boosting, maxSplit = 10
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'boosting';
settings.forest.maxSplit = 10;
settings.forest.distance = 2;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_boost_10split', datamark, '.mat']));

%% RF - 11 svm trees
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'svm';
settings.forest.learning = 'bagging';
settings.iteration = 10;

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_svm_11t', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree
clear settings

settings.note = 'Default lineartree settings.';

classifyFC(FCdata,'linTree',settings, fullfile(filename, ['linTree', datamark, '.mat']));

%% linear tree + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

classifyFC(FCdata,'linTree',settings, fullfile(filename, ['linTree_pca20', datamark, '.mat']));

%% linear tree mahal
clear settings

settings.tree.distance = 'mahal';

classifyFC(FCdata,'linTree',settings, fullfile(filename, ['linTree_mahal', datamark, '.mat']));

%% linear tree mahal + PCA 20
clear settings

settings.tree.distance = 'mahal';

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

classifyFC(FCdata,'linTree',settings, fullfile(filename, ['linTree_mahal_pca20', datamark, '.mat']));

%% SVM tree
clear settings

settings.note = 'Default settings of SVMTree.';

classifyFC(FCdata,'svmtree', settings, fullfile(filename, ['svmTree', datamark, '.mat']));

%% MATLAB classification tree
clear settings

settings.note = 'Default MATLAB classification tree settings.';

classifyFC(FCdata,'mtltree',settings, fullfile(filename, ['mtlTree', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA - diaglinear
clear settings

settings.lda.type = 'diaglinear';
settings.note = 'LDA settings with diaglinear.';

classifyFC(FCdata,'lda',settings, fullfile(filename, ['lda_diaglinear', datamark, '.mat']));

%% LDA - linear
clear settings

settings.lda.type = 'linear';

classifyFC(FCdata,'lda',settings, fullfile(filename, ['lda_linear', datamark, '.mat']));

%% LDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.lda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools LDA.';

classifyFC(FCdata,'lda',settings, fullfile(filename, [ 'lda_prtools', datamark, '.mat']));

%% QDA - diagquadratic
clear settings

settings.qda.type = 'diagquadratic';

classifyFC(FCdata,'qda',settings, fullfile(filename, [ 'qda_diagquadratic', datamark, '.mat']));

%% QDA - quadratic
clear settings

settings.qda.type = 'quadratic';

classifyFC(FCdata,'qda',settings, fullfile(filename, ['qda_quadratic', datamark, '.mat']));

%% QDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.qda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools QDA.';

classifyFC(FCdata,'qda',settings, fullfile(filename, [ 'qda_prtools', datamark, '.mat']));

%% RDA (RDA 14)
clear settings

settings.note = 'Default RDA (14).';

classifyFC(FCdata,'rda',settings, fullfile(filename, [ 'rda_default', datamark, '.mat']));

%% Fisher's linear discriminant (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Fisher''s linear discriminant (PRTools) has no settings.';

classifyFC(FCdata,'fisher',settings, fullfile(filename, [ 'fisher', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.k = 1;
settings.knn.distance = 'euclidean';
settings.note = 'Default settings of KNN classifier.';

classifyFC(FCdata,'knn',settings, fullfile(filename, ['knn_1', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

classifyFC(FCdata,'llc',settings, fullfile(filename, ['llc_pca20', datamark, '.mat']));

%% logistic linear classifier
clear settings

settings.note = 'Default settings of logistic linear classifier.';

classifyFC(FCdata,'llc',settings, fullfile(filename, ['llc_default', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.nb.distribution = 'normal';
settings.note = 'Default naive Bayes settings.';

classifyFC(FCdata, 'nb', settings, fullfile(filename, ['nb_default', datamark, '.mat']));

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

listSettingsResults(fullfile(expfolder, filename]));