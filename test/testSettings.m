%%% SVM

%% linear
clear settings

settings.svm.kernel_function = 'linear';
perf = classifyFC(FCdata,'svm',settings);

%% quadratic
clear settings

settings.svm.kernel_function = 'quadratic';
settings.svm.autoscale = false;
perf = classifyFC(FCdata,'svm',settings);

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial';
settings.svm.autoscale = false; 
perf = classifyFC(FCdata,'svm',settings);

%% rbf
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 31; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings);

%% rbf
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.autoscale = false;
settings.svm.rbf_sigma = 6; % found through gridsearch

perf = classifyFC(FCdata,'svm',settings);

%% rbf
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 6; % found through gridsearch
settings.svm.autoscale = false;

nValues = 10;
for i=1:nValues
  sigma(i) = i;
  settings.svm.rbf_sigma = sigma(i);
  perf(i) = classifyFC(FCdata,'svm',settings);
end
for i = 1:nValues
  fprintf('Sigma:%f   Perf:%f\n',sigma(i),perf(i))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Random forest
% 11 linear trees

perf = classifyFC(FCdata,'rf');

%% 11 linear trees + pca(20)
clear settings

settings.forest.nTrees = 11;
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.autoscale = true;

perf = classifyFC(FCdata,'rf',settings);

%% linear trees - experimental
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.forest.maxSplit = 1;
settings.forest.learning = 'boosting';

perf = classifyFC(FCdata,'rf',settings);

%% bagged linear svm
clear settings

settings.forest.TreeType = 'svm';
settings.forest.perfType = 'all';

perf = classifyFC(FCdata,'rf',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trees
% linear tree + pca
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'linTree',settings);

%% linear tree mahal + pca
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.tree.distance = 'mahal';

perf = classifyFC(FCdata,'linTree',settings);

%% SVM tree
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'svmtree');

%% MATLAB classification tree
clear settings

settings.tree.MaxCat = 0;

perf = classifyFC(FCdata,'mtltree',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% linear naive Bayes
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.bayes.type = 'diaglinear';

perf = classifyFC(FCdata,'nb',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN
clear settings

settings.knn.k = 3;
settings.knn.distance = 'euclidean';
settings.dimReduction.name = 'kendall';
settings.dimReduction.nDim = 200;

perf = classifyFC(FCdata,'knn',settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier
clear settings

for s=1:100
  settings(s).dimReduction.name = 'pca';
  settings(s).dimReduction.nDim = s+50;
  tic
  perf(s) = classifyFC(FCdata,'llc',settings(s));
  elapsedtime = toc;
end

save(fullfile('results','llc_pca_dim_50plus.mat'),'perf','settings','elapsedtime')