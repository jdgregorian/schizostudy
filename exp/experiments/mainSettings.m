% Script for testing main settings of classifiers

%% initialization
FCdata = fullfile('data','data_FC_190subjects.mat');
filename = 'mainSettings';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM
% linear
clear settings

settings.svm.kernel_function = 'linear';
perf = classifyFC(FCdata,'svm',settings,fullfile(filename,'svm_linear.mat'));

%% linear - autoscale 'off'
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_linear_noauto.mat'));

%% quadratic
clear settings

settings.svm.kernel_function = 'quadratic';
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_quad.mat'));

%% quadratic - autoscale 'off'
clear settings

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_quad_noauto.mat'));

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial'; 
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_poly.mat'));

%% polynomial - autoscale 'off'
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 
perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_poly_noauto.mat'));

%% rbf - autoscale 'on'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 42; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_rbf.mat'));

%% rbf - autoscale 'off'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.svm.rbf_sigma = 7; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_rbf_noauto.mat'));

%% mlp
clear settings

settings.svm.kernel_function = 'mlp';

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_mlp.mat'));

%% mlp - autoscale 'off'
clear settings

settings.svm.kernel_function = 'mlp';
settings.svm.autoscale = false;

perf = classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_mlp_noauto.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Random forest
% MATLAB classification forest - 11 trees
clear settings

settings.forest.nTrees = 11;
settings.iteration = 10;
settings.note = 'Default settings of MATLAB classification forest with 11 trees.';

perf = classifyFC(FCdata,'mrf',settings, fullfile(filename,'mrf_11t.mat'));

%% RF - 11 linear trees
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.iteration = 10;

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t.mat'));

%% RF - 11 linear trees + pca(20)
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_pca20.mat'));

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

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_mahal.mat'));

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

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_distInf.mat'));

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

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_dist1.mat'));

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

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_boost_10split.mat'));

%% RF - 11 svm trees
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'svm';
settings.forest.learning = 'bagging';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_svm_11t.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

perf = classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree.mat'));

%% linear tree + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree_pca20.mat'));

%% linear tree mahal
clear settings

settings.tree.distance = 'mahal';

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

perf = classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree_mahal.mat'));

%% linear tree mahal + PCA 20
clear settings

settings.tree.distance = 'mahal';

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree_mahal_pca20.mat'));

%% SVM tree
clear settings

settings.note = 'Default settings of SVMTree.';

perf = classifyFC(FCdata,'svmtree', settings, fullfile(filename,'svmTree.mat'));

%% MATLAB classification tree
clear settings

settings.note = 'Default MATLAB classification tree settings.';

perf = classifyFC(FCdata,'mtltree',settings, fullfile(filename,'mtlTree.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA
clear settings

settings.lda.type = 'diaglinear';
settings.note = 'Default LDA settings.';

perf = classifyFC(FCdata,'lda',settings, fullfile(filename,'LDA_linear.mat'));

%% LDA + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.lda.type = 'diaglinear';

perf = classifyFC(FCdata,'lda',settings, fullfile(filename,'LDA_linear_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.k = 1;
settings.knn.distance = 'euclidean';
settings.note = 'Default settings of KNN classifier.';

perf = classifyFC(FCdata,'knn',settings, fullfile(filename,'KNN_1.mat'));

%% KNN - k=3
clear settings

settings.knn.k = 3;
settings.knn.distance = 'euclidean';

perf = classifyFC(FCdata,'knn',settings, fullfile(filename,'KNN_3.mat'));

%% KNN - k=3, kendall 200
clear settings

settings.knn.k = 3;
settings.knn.distance = 'euclidean';
settings.dimReduction.name = 'kendall';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'knn',settings, fullfile(filename,'KNN_3_kendall_200.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'llc',settings, fullfile(filename,'LLC_pca20.mat'));

%% logistic linear classifier + PCA 50
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 50;

perf = classifyFC(FCdata,'llc',settings, fullfile(filename,'LLC_pca50.mat'));

%% logistic linear classifier + PCA 75
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 75;

perf = classifyFC(FCdata,'llc',settings, fullfile(filename,'LLC_pca75.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.nb.distribution = 'normal';
settings.note = 'Default naive Bayes settings.';

perf = classifyFC(FCdata, 'nb', settings, fullfile(filename,'NB_default.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Artificial Neural Networks
% linear perceptron - ttest 1000
clear settings

settings.note = 'Linear perceptron has no settings. Dimension has to be reduced because of memory limits.';
settings.dimReduction.name = 'ttest';
settings.dimReduction.nDim = 1000;

perf = classifyFC(FCdata, 'perc', settings, fullfile(filename,'perc_ttest1000.mat'));

%% ANN + PCA 200
clear settings

settings.note = 'ANN default settings. PCA (200ft.) used due to ANN memory limitations.';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.iteration = 10;

perf = classifyFC(FCdata, 'ann', settings, fullfile(filename,'ann_pca189.mat'));

%% ANN - Arbabshirani's settings
clear settings

settings.note = 'ANN';
settings.ann.hiddenSizes = [6 6 6]; % [4 4 4] - on reduced
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata, 'ann', settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile('results',filename));
