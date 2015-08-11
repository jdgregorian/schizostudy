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

%% 11 linear trees - experimental
clear settings

settings.forest.nTrees = 100;
settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 200;
settings.forest.probability = false;
settings.forest.maxSplit = 6;

perf = classifyFC(FCdata,'rf',settings);

%% bagged linear svm
clear settings

settings.forest.TreeType = 'svm';

perf = classifyFC(FCdata,'rf',settings);

%% linear tree + pca
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% linear naive Bayes
clear settings

settings.dimReduction.name = 'pca';
settings.dimReduction.nDim = 20;
settings.bayes.type = 'mahal';

perf = classifyFC(FCdata,'nb',settings);