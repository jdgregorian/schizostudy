% Script for testing main settings of classifiers
%
% Variables 'FCdata', 'filename', 'expfolder' and 'datamark' should be 
% defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data', 'data_FC_190subjects.mat');
end
if ~exist('filename', 'var')
  filename = 'mainSettings';
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
settings.svm.rbf_sigma = 42; % found through gridsearch

classifyFC(FCdata,'svm',settings, fullfile(filename, ['svm_rbf', datamark, '.mat']));

%% rbf - autoscale 'off'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.svm.rbf_sigma = 7; % found through gridsearch

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

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

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

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_mahal', datamark, '.mat']));

%% RF - 11 linear trees - distance Inf
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = Inf;
settings.iteration = 10;

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_distInf', datamark, '.mat']));

%% RF - 11 linear trees - distance 1
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = 1;
settings.iteration = 10;

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

classifyFC(FCdata,'rf',settings, fullfile(filename, ['rf_lin_11t_dist1', datamark, '.mat']));

%% RF - 11 linear trees - boosting, maxSplit = 10
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'boosting';
settings.forest.maxSplit = 10;
settings.forest.distance = 2;

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

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

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

classifyFC(FCdata,'linTree',settings, fullfile(filename, ['linTree', datamark, '.mat']));

%% linear tree + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

classifyFC(FCdata,'linTree',settings, fullfile(filename, ['linTree_pca20', datamark, '.mat']));

%% linear tree mahal
clear settings

settings.tree.distance = 'mahal';

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

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

%% PRTools classification tree - information gain criterion
clear settings

settings.implementation = 'prtools';
settings.tree.crit = 'infcrit';
settings.note = 'Default settings of PRTools decision tree using information gain criterion.';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_inf', datamark, '.mat']));

%% PRTools classification tree - Fisher criterion
clear settings

settings.implementation = 'prtools';
settings.note = 'PRTools decision tree using Fisher criterion.';
settings.tree.crit = 'fishcrit';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_fish', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA - diaglinear
clear settings

settings.lda.type = 'diaglinear';
settings.note = 'LDA settings with diaglinear.';

classifyFC(FCdata,'lda',settings, fullfile(filename, ['lda_diaglinear', datamark, '.mat']));

%% LDA - linear + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.lda.type = 'linear';

classifyFC(FCdata,'lda',settings, fullfile(filename, ['lda_linear_pca20', datamark, '.mat']));

%% LDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.lda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools LDA.';

classifyFC(FCdata,'lda',settings, fullfile(filename, ['lda_prtools_pca20', datamark, '.mat']));

%% QDA - diagquadratic
clear settings

settings.qda.type = 'diagquadratic';

classifyFC(FCdata,'qda',settings, fullfile(filename, ['qda_diagquadratic', datamark, '.mat']));

%% QDA - quadratic + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.qda.type = 'quadratic';

classifyFC(FCdata,'qda',settings, fullfile(filename, ['qda_quadratic_pca20', datamark, '.mat']));

%% QDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.qda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools QDA.';

classifyFC(FCdata,'qda',settings, fullfile(filename, ['qda_prtools', datamark, '.mat']));

%% RDA (RDA 14)
clear settings

settings.note = 'Default RDA (14).';

classifyFC(FCdata,'rda',settings, fullfile(filename, ['rda_default', datamark, '.mat']));

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

%% KNN - k=3
clear settings

settings.knn.k = 3;
settings.knn.distance = 'euclidean';

classifyFC(FCdata,'knn',settings, fullfile(filename, ['knn_3', datamark, '.mat']));

%% KNN - k=3, kendall 200
clear settings

settings.knn.k = 3;
settings.knn.distance = 'euclidean';
settings.dimReduction.name = 'kendall';
settings.dimReduction.nDim = 200;

classifyFC(FCdata,'knn',settings, fullfile(filename, ['knn_3_kendall_200', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

classifyFC(FCdata,'llc',settings, fullfile(filename, ['llc_pca20', datamark, '.mat']));

%% logistic linear classifier + PCA 50
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 50;

classifyFC(FCdata,'llc',settings, fullfile(filename, ['llc_pca50', datamark, '.mat']));

%% logistic linear classifier + PCA 75
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 75;

classifyFC(FCdata,'llc',settings, fullfile(filename, ['llc_pca75', datamark, '.mat']));

%% logistic linear classifier (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default logistic linear classifier settings in PRTools.';

classifyFC(FCdata,'llc',settings, fullfile(filename, ['llc_prtools', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.nb.distribution = 'normal';
settings.note = 'Default naive Bayes settings.';

classifyFC(FCdata, 'nb', settings, fullfile(filename, ['nb_default', datamark, '.mat']));

%% naive Bayes (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default PRTools naive Bayes settings.';

classifyFC(FCdata, 'nb', settings, fullfile(filename, ['nb_prtools', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Artificial Neural Networks
% linear perceptron - ttest 1000
clear settings

settings.note = 'Linear perceptron has no settings. Dimension has to be reduced because of memory limits.';
settings.dimReduction.name = 'ttest';
settings.dimReduction.nDim = 1000;

classifyFC(FCdata, 'perc', settings, fullfile(filename, ['perc_ttest1000', datamark, '.mat']));

%% ANN + PCA 200
clear settings

settings.note = 'ANN default settings. PCA (200ft.) used due to ANN memory limitations.';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.iteration = 10;

classifyFC(FCdata, 'ann', settings, fullfile(filename, ['ann_pca189', datamark, '.mat']));

%% ANN - Arbabshirani's settings
clear settings

settings.note = 'ANN with Arbabshirani''s settings.';
settings.ann.hiddenSizes = [6 6 6]; % [4 4 4] - on reduced
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

classifyFC(FCdata, 'ann', settings, fullfile(filename, ['ann_arbab', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile(expfolder, filename));
