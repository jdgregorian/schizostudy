% Script for testing main settings of classifiers on reduced (PCA 20ft.)
% dataset

%% initialization
FCdata = fullfile('data','data_FC_190subjects.mat');
filename = 'exp_main_pca20';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM + PCA 20
% linear
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'linear';
perf = classifyFC(FCdata,'svm',settings,fullfile(filename,'svm_linear_pca20.mat'));

%% linear - autoscale 'off' + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_linear_noauto_pca20.mat'));

%% quadratic + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'quadratic';
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_quad_pca20.mat'));

%% quadratic - autoscale 'off' + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_quad_noauto_pca20.mat'));

%% polynomial + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'polynomial'; 
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_poly_pca20.mat'));

%% polynomial - autoscale 'off' + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_poly_noauto_pca20.mat'));

%% rbf - autoscale 'on' + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 42; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_rbf_pca20.mat'));

%% rbf - autoscale 'off' + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.svm.rbf_sigma = 7; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_rbf_noauto_pca20.mat'));

%% mlp + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'mlp';

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_mlp_pca20.mat'));

%% mlp - autoscale 'off' + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.svm.kernel_function = 'mlp';
settings.svm.autoscale = false;

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_mlp_noauto_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Random forest
% MATLAB classification forest - 11 trees + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.forest.nTrees = 11;
settings.iteration = 10;
settings.note = 'Default settings of MATLAB classification forest with 11 trees + PCA 20.';

perf = classifyFC(FCdata,'mrf',settings, fullfile(filename,'mrf_11t_pca20.mat'));

%% RF - 11 linear trees + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_pca20.mat'));

%% RF - 11 linear trees - distance mahal + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = 'mahal';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_mahal_pca20.mat'));

%% RF - 11 linear trees - distance Inf + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = Inf;
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_distInf_pca20.mat'));

%% RF - 11 linear trees - distance 1 + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.forest.distance = 1;
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_dist1_pca20.mat'));

%% RF - 11 linear trees - boosting, maxSplit = 10 + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'boosting';
settings.forest.maxSplit = 10;
settings.forest.distance = 2;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_boost_10split_pca20.mat'));

%% RF - 11 svm trees + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.forest.nTrees = 11;
settings.forest.TreeType = 'svm';
settings.forest.learning = 'bagging';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_svm_11t_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree_pca20.mat'));

%% linear tree mahal + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.tree.distance = 'mahal';

perf = classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree_mahal_pca20.mat'));

%% SVM tree + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.note = 'Default settings of SVMTree + PCA 20ft.';

perf = classifyFC(FCdata,'svmtree', settings, fullfile(filename,'svmTree_pca20.mat'));

%% MATLAB classification tree + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.note = 'Default MATLAB classification tree settings + PCA 20ft.';

perf = classifyFC(FCdata,'mtltree',settings, fullfile(filename,'mtlTree_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.lda.type = 'diaglinear';
settings.note = 'Default LDA settings + PCA 20ft.';

perf = classifyFC(FCdata,'lda',settings, fullfile(filename,'LDA_linear_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.knn.k = 1;
settings.knn.distance = 'euclidean';
settings.note = 'Default settings of KNN classifier + PCA 20ft.';

perf = classifyFC(FCdata,'knn',settings, fullfile(filename,'KNN_1_pca20.mat'));

%% KNN - k=3 + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.knn.k = 3;
settings.knn.distance = 'euclidean';

perf = classifyFC(FCdata,'knn',settings, fullfile(filename,'KNN_3_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'llc',settings, fullfile(filename,'LLC_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.nb.distribution = 'normal';
settings.note = 'Default naive Bayes settings + PCA 20ft.';

perf = classifyFC(FCdata, 'nb', settings, fullfile(filename,'NB_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Artificial Neural Networks
% linear perceptron + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

settings.note = 'Linear perceptron has no settings + PCA 20ft.';

perf = classifyFC(FCdata, 'perceptron', settings, fullfile(filename,'perceptron_pca20.mat'));

%% ANN + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.iteration = 10;

settings.note = 'ANN default settings + PCA 20ft.';

perf = classifyFC(FCdata, 'ann', settings, fullfile(filename,'ann_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile('results',filename));
