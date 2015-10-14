% Script for testing some of main settings of classifiers on dataset with
% 168 subjects (reduced from data_FC_190subjects.mat by excluding
% individuals with motion index > 0.004).

%% initialization
FCdata = fullfile('data','data_FC_168subjects.mat');
filename = 'exp_main_reduced_168';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM
% linear
clear settings

settings.svm.kernel_function = 'linear';

classifyFC(FCdata,'svm',settings,fullfile(filename,'svm_linear.mat'));

%% linear - autoscale 'off'
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_linear_noauto.mat'));

%% quadratic
clear settings

settings.svm.kernel_function = 'quadratic';

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_quad.mat'));

%% quadratic - autoscale 'off'
clear settings

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_quad_noauto.mat'));

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial'; 

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_poly.mat'));

%% polynomial - autoscale 'off'
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_poly_noauto.mat'));

%% rbf - autoscale 'on'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 42; % found through gridsearch

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_rbf.mat'));

%% rbf - autoscale 'off'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.svm.rbf_sigma = 7; % found through gridsearch

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_rbf_noauto.mat'));

%% mlp
clear settings

settings.svm.kernel_function = 'mlp';

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_mlp.mat'));

%% mlp - autoscale 'off'
clear settings

settings.svm.kernel_function = 'mlp';
settings.svm.autoscale = false;

classifyFC(FCdata,'svm',settings, fullfile(filename,'svm_mlp_noauto.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Random forest
% MATLAB classification forest - 11 trees
clear settings

settings.forest.nTrees = 11;
settings.iteration = 10;
settings.note = 'Default settings of MATLAB classification forest with 11 trees.';

classifyFC(FCdata,'mrf',settings, fullfile(filename,'mrf_11t.mat'));

%% RF - 11 linear trees
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.forest.learning = 'bagging';
settings.iteration = 10;

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t.mat'));

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

classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_mahal.mat'));

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

classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_lin_11t_boost_10split.mat'));

%% RF - 11 svm trees
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'svm';
settings.forest.learning = 'bagging';
settings.iteration = 10;

classifyFC(FCdata,'rf',settings, fullfile(filename,'rf_svm_11t.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree.mat'));

%% linear tree mahal
clear settings

settings.tree.distance = 'mahal';

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.note = 'PCA(200ft.) does not affect tree learning. Added to speed up testing.';

classifyFC(FCdata,'linTree',settings, fullfile(filename,'linTree_mahal.mat'));

%% SVM tree
clear settings

settings.note = 'Default settings of SVMTree.';

classifyFC(FCdata,'svmtree', settings, fullfile(filename,'svmTree.mat'));

%% MATLAB classification tree
clear settings

settings.note = 'Default MATLAB classification tree settings.';

classifyFC(FCdata,'mtltree',settings, fullfile(filename,'mtlTree.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA - diaglinear
clear settings

settings.lda.type = 'diaglinear';
settings.note = 'LDA settings with diaglinear.';

classifyFC(FCdata,'lda',settings, fullfile(filename,'lda_diaglinear.mat'));

%% LDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.lda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools LDA.';

classifyFC(FCdata,'lda',settings, fullfile(filename, 'lda_prtools_pca20.mat'));

%% QDA - diagquadratic
clear settings

settings.qda.type = 'diagquadratic';

classifyFC(FCdata,'qda',settings, fullfile(filename, 'qda_diagquadratic.mat'));

%% QDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.qda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools QDA.';

classifyFC(FCdata,'qda',settings, fullfile(filename, 'qda_prtools.mat'));

%% RDA (RDA 14)
clear settings

settings.note = 'Default RDA (14).';

classifyFC(FCdata,'rda',settings, fullfile(filename, 'rda_default.mat'));

%% Fisher's linear discriminant (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Fisher''s linear discriminant (PRTools) has no settings.';

classifyFC(FCdata,'fisher',settings, fullfile(filename, 'fisher.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.k = 1;
settings.knn.distance = 'euclidean';
settings.note = 'Default settings of KNN classifier.';

classifyFC(FCdata,'knn',settings, fullfile(filename,'knn_1.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier + PCA 20
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

classifyFC(FCdata,'llc',settings, fullfile(filename,'llc_pca20.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.nb.distribution = 'normal';
settings.note = 'Default naive Bayes settings.';

classifyFC(FCdata, 'nb', settings, fullfile(filename,'nb_default.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Artificial Neural Networks
% ANN + PCA 167
clear settings

settings.note = 'ANN default settings. PCA (167ft.) used due to ANN memory limitations.';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 167;
settings.iteration = 10;

classifyFC(FCdata, 'ann', settings, fullfile(filename,'ann_pca167.mat'));

%% linear perceptron - ttest 1000
clear settings

settings.note = 'Linear perceptron has no settings. Dimension has to be reduced because of memory limits.';
settings.dimReduction.name = 'ttest';
settings.dimReduction.nDim = 1000;

classifyFC(FCdata, 'perc', settings, fullfile(filename,'perc_ttest1000.mat'));

%% RBF
clear settings

settings.note = 'Default RBF';

perf = classifyFC(FCdata, 'rbf', settings, fullfile(filename, 'rbf_default.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile(expfolder, filename));
