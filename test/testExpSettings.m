% Script for testing main settings of classifiers

%% initialization
FCdata = fullfile('data', 'data_FC_190subjects.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM
% linear
clear settings

settings.svm.kernel_function = 'linear';

perf = classifyFC(FCdata,'svm',settings);

%% linear - autoscale 'off'
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;

perf = classifyFC(FCdata,'svm',settings);

%% quadratic
clear settings

settings.svm.kernel_function = 'quadratic';

perf = classifyFC(FCdata,'svm',settings);

%% quadratic - autoscale 'off'
clear settings

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;

perf = classifyFC(FCdata,'svm',settings);

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial'; 
settings.svm.polyorder = 3;

perf = classifyFC(FCdata,'svm',settings);

%% polynomial - autoscale 'off'
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 

perf = classifyFC(FCdata,'svm',settings);

%% polynomial - gridsearch
clear settings

settings.svm.kernel_function = 'polynomial'; 

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'boxconstraint', 'polyorder'};
settings.gridsearch.levels = [3, 1];
settings.gridsearch.bounds = {[1.1 * 10^-3, 10^5], [3, 5]};
settings.gridsearch.npoints = [11, 3];
settings.gridsearch.scaling = {{'log', 'lin', 'lin'}, {'lin'}};

perf = classifyFC(FCdata, 'svm', settings);

%% rbf - autoscale 'on'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 42; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings);

%% rbf - autoscale 'off'
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.svm.rbf_sigma = 7; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings);

%% rbf - autoscale 'on'
clear settings

settings.svm.kernel_function = 'rbf';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'boxconstraint', 'rbf_sigma'};
settings.gridsearch.levels = [1, 1];
settings.gridsearch.bounds = {[1.1 * 10^-3, 10^5], [10^-5, 10^5]};
settings.gridsearch.npoints = [3, 3];
settings.gridsearch.scaling = {{'log', 'lin', 'lin'}, {'log', 'lin', 'lin'}};

perf = classifyFC(FCdata,'svm',settings);

%% mlp
clear settings

settings.svm.kernel_function = 'mlp';

perf = classifyFC(FCdata,'svm',settings);

%% mlp - autoscale 'off'
clear settings

settings.svm.kernel_function = 'mlp';
settings.svm.autoscale = false;

perf = classifyFC(FCdata,'svm',settings);

%% rbf - experimental
clear settings

arbabfolder = fullfile('data', 'arbabshirani');
traintestData = fullfile(arbabfolder, 'traintest', 'adCorrAbs_27_11_15');

settings.svm.kernel_function = 'rbf';
settings.gridsearch.mode = 'grid';
settings.gridsearch.properties = {'boxconstraint', 'rbf_sigma'};
settings.gridsearch.bounds = {[2*10^-3, 10^5], [10^-5, 10^5]};
settings.gridsearch.npoints = [11,11];

perf = classifyFC(traintestData, 'svm', settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Random forest
% 11 linear trees
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings);

%% 11 linear trees + pca(20)
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'linear';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings);

%% linear trees - experimental
clear settings

    settings.iteration = 10;
    settings.forest.nTrees = 11;
    settings.forest.TreeType = 'linear';
    settings.forest.learning = 'bagging';
    settings.forest.distance = Inf;

perf = classifyFC(FCdata,'rf',settings);

%% bagged linear svm
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'svm';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings);

%% random forest (PRTools)
clear settings

settings.forest.nTrees = 11;
settings.implementation = 'prtools';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings);

%% random forest (PRTools)
clear settings

settings.forest.nTrees = 11;
settings.forest.learning = 'boosting';
settings.implementation = 'prtools';

perf = classifyFC(FCdata,'rf',settings);

%% MATLAB random forest
clear settings

settings.forest.nTrees = 11;

perf = classifyFC(FCdata, 'mrf', settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree + pca
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'linTree', settings);

%% linear tree mahal + pca
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.tree.distance = 'mahal';

perf = classifyFC(FCdata,'linTree',settings);

%% linear tree mahal + pca
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 10;
settings.tree.distance = {2,'mahal',Inf};
settings.something = {{}, @sum, true};

% perf = classifyFC(FCdata,'linTree',settings,fullfile('mainSettings','experimental_tree.mat'));
perf = classifyFC(FCdata,'linTree',settings);

%% SVM tree
clear settings

% settings.dimReduction.name = 'pca';
% settings.dimReduction.nDim = 200;

tic
perf = classifyFC(FCdata,'svmtree');
toc

%% MATLAB classification tree
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'mtltree',settings);

%% PRTools classification tree
clear settings

settings.implementation = 'prtools';
settings.note = 'Default settings of PRTools decision tree';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'dectree',settings);

%% PRTools classification tree - Fisher
clear settings

settings.implementation = 'prtools';
settings.note = 'PRTools decision tree using Fisher criterion';
settings.tree.crit = 'fishcrit';
settings.tree.prune = NaN;
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'dectree',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% linear discriminant analysis
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 187;
settings.lda.type = 'diaglinear';

[perf, ~, ~, classLDA] = classifyFC(FCdata,'lda',settings);

%% linear discriminant analysis
clear settings

settings.lda.type = 'linear';

[perf, ~, ~, classLDA] = classifyFC(FCdata,'lda',settings);

%% linear discriminant analysis (PRTools)
clear settings

settings.implementation = 'prtools';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.lda.prior = [0.5,0.5];

[perf, ~, ~, classlda_equal] = classifyFC(FCdata,'lda',settings);

%% linear discriminant classifier (PRTools)
clear settings

settings.implementation = 'prtools';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
% settings.lda.prior = [];
settings.prior = 'lda with no settings';

[perf, ~, ~, classlda_none] = classifyFC(FCdata,'lda',settings);

%% Fisher's linear discriminant (PRTools)
clear settings

settings.implementation = 'prtools';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

[perf, ~, ~, classFisher] = classifyFC(FCdata,'fisher',settings);

%% quadratic discriminant analysis
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 150;
settings.qda.type = 'quadratic';

[perf, ~, ~, classQDA] = classifyFC(FCdata,'qda',settings);

%% quadratic discriminant analysis (PRTools)
clear settings

settings.implementation = 'prtools';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
% settings.qda.prior = [0.5, 0.5];

[perf, ~, ~, classlda_equal] = classifyFC(FCdata,'qda',settings);

%% regularized discriminant analysis (RDA 14)
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.note = 'Default RDA';

tic
perf = classifyFC(FCdata,'rda',settings);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.k = 3;
settings.knn.distance = 'euclidean';
settings.dimReduction.name = 'kendall';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'knn',settings);

%% KNN - gridsearch
clear settings

settings.knn.distance = 'euclidean';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'k'};
settings.gridsearch.levels = 1;
settings.gridsearch.bounds = {[1, 200]};
settings.gridsearch.npoints = 200;
settings.gridsearch.scaling = {{'lin'}};

perf = classifyFC(FCdata,'knn',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.note = '';

perf = classifyFC(FCdata,'llc',settings);

%% logistic linear classifier - PRTools
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.implementation = 'prtools';

perf = classifyFC(FCdata,'llc',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.note = 'Default';

perf = classifyFC(FCdata, 'nb', settings);

%% naive Bayes (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default PRTools';

perf = classifyFC(FCdata, 'nb', settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% linear perceptron
clear settings

settings.note = 'Linear perceptron has no settings';
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata, 'perc', settings);

%% ann
clear settings

settings.note = 'ANN';
settings.ann.hiddenSizes = [];
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata, 'ann', settings);

%% ann - Arbabshirani settings
clear settings

settings.note = 'ANN';
settings.ann.hiddenSizes = [6 6 6]; % [4 4 4] - on reduced
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata, 'ann', settings);

%% ann - automatic(PRTools)
clear settings

settings.note = 'PRTools ANN - no additional settings';
settings.implementation = 'prtools';

perf = classifyFC(FCdata, 'ann', settings);

%% ann - experimental
clear settings

settings.note = 'ANN';
settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'hiddenSizes'};
settings.gridsearch.levels = [2];
settings.gridsearch.bounds = {[1, 5]};
settings.gridsearch.npoints = [5];
settings.gridsearch.scaling = {{'lin'}};

perf = classifyFC(FCdata, 'ann', settings);

%% rbf
clear settings

settings.note = 'default rbf';

perf = classifyFC(FCdata, 'rbf', settings);