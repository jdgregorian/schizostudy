% Script for testing main settings of classifiers

%% initialization
FCdata = fullfile('data','data_FC_190subjects.mat');

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

perf = classifyFC(FCdata,'svm',settings);

%% polynomial - autoscale 'off'
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 

perf = classifyFC(FCdata,'svm',settings);

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

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;

perf = classifyFC(FCdata,'svm',settings);

nValues = 20;
for i=1:nValues
  sigma(i) = i;
  settings.svm.rbf_sigma = sigma(i);
  perf(i) = classifyFC(FCdata,'svm',settings);
end
for i = 1:nValues
  fprintf('Sigma:%f   Perf:%f\n',sigma(i),perf(i))
end

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

settings.dimReduction.name = 'ttest';
settings.dimReduction.nDim = 200;
settings.forest.learning = 'boosting';
settings.forest.TreeType = 'matlab';
settings.forest.MinLeaf = 10;

perf = classifyFC(FCdata,'rf',settings);

%% bagged linear svm
clear settings

settings.forest.nTrees = 11;
settings.forest.TreeType = 'svm';
settings.iteration = 10;

perf = classifyFC(FCdata,'rf',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree + pca
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'linTree');

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

settings.tree.MaxCat = 0;
settings.tree.MinLeaf = 10;

perf = classifyFC(FCdata,'mtltree',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% linear discriminant analysis
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.lda.type = 'linear';

[perf, ~, ~, classLDA] = classifyFC(FCdata,'lda',settings);

%% linear discriminant classifier (PRTools)
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.ldc.prior = [0.5;0.5];

[perf, ~, ~, classLDC] = classifyFC(FCdata,'ldc',settings);

%% linear discriminant classifier (PRTools)
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.ldc.prior = [90;100]/190;

[perf, ~, ~, classLDC] = classifyFC(FCdata,'ldc',settings);

%% Fisher's linear discriminant (PRTools)
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

[perf, ~, ~, classFisher] = classifyFC(FCdata,'fisher',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.k = 3;
settings.knn.distance = 'euclidean';
settings.dimReduction.name = 'kendall';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'knn',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier - experimental
clear settings


settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;

perf = classifyFC(FCdata,'llc',settings);

%% logistic linear classifier - experimental
clear settings

for s=1:100
  settings(s).dimReduction.name = 'pca';
  settings(s).dimReduction.nDim = s+50;
  tic
  perf(s) = classifyFC(FCdata,'llc',settings(s));
  elapsedtime = toc;
end

save(fullfile('results','llc_pca_dim_50plus.mat'),'perf','settings','elapsedtime')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes
clear settings

settings.note = 'Default';

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

%% rbf
clear settings

settings.note = 'default rbf';

perf = classifyFC(FCdata, 'rbf', settings);