% Script for testing Arbabshirani's settings of classifiers using simple
% gridsearch. ANN and RBF are missing - trainCVClassifier needs to be
% improved to search optimal architecture.
%
% Variables 'FCdata', 'filename', 'expfolder' and 'datamark' should be 
% defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data', 'data_FC_190subjects.mat');
end
if ~exist('filename', 'var')
  filename = 'arbabshiraniGridSettings';
end
if ~exist('expfolder', 'var')
  expfolder = fullfile('exp', 'experiments');
end 
if ~exist('datamark', 'var')
  datamark = '';
else
  datamark = ['_', datamark];
end
mkdir(expfolder, filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM - gridsearch
% linear
clear settings

settings.svm.kernel_function = 'linear';
settings.note = 'Linear SVM using simple gridsearch on property boxconstraint.';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'boxconstraint'};
settings.gridsearch.levels = 3;
settings.gridsearch.bounds = {[1.1 * 10^-3, 3]};
settings.gridsearch.npoints = 11;
settings.gridsearch.scaling = {{'log', 'lin', 'lin'}};

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_sgrid', datamark, '.mat']));

%% polynomial
clear settings

settings.svm.kernel_function = 'polynomial';
settings.note = 'Polynomial SVM using simple gridsearch on properties boxconstraint and polyorder.';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'boxconstraint', 'polyorder'};
settings.gridsearch.levels = [3, 1];
settings.gridsearch.bounds = {[1.1 * 10^-3, 10^5], [3, 5]};
settings.gridsearch.npoints = [11, 3];
settings.gridsearch.scaling = {{'log', 'lin', 'lin'}, {'lin'}};

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_poly_sgrid', datamark, '.mat']));

%% rbf
clear settings

settings.svm.kernel_function = 'rbf';
settings.note = 'RBF SVM using simple gridsearch on properties boxconstraint and rbf_sigma.';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'boxconstraint', 'rbf_sigma'};
settings.gridsearch.levels = [3, 3];
settings.gridsearch.bounds = {[1.1 * 10^-3, 10^5], [10^-5, 10^5]};
settings.gridsearch.npoints = [11, 11];
settings.gridsearch.scaling = {{'log', 'lin', 'lin'}, {'log', 'lin', 'lin'}};

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_rbf_sgrid', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRTools classification tree - information gain criterion, optimal pruning
clear settings

settings.implementation = 'prtools';
settings.tree.crit = 'infcrit';
settings.tree.prune = NaN;
settings.note = 'PRTools decision tree using information gain criterion and optimization of pruning level.';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_inf_optim', datamark, '.mat']));

%% PRTools classification tree - Fisher criterion, optimal pruning
clear settings

settings.implementation = 'prtools';
settings.tree.crit = 'fishcrit';
settings.tree.prune = NaN;
settings.note = 'PRTools decision tree using Fisher criterion and optimization of pruning level.';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_fish_optim', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KNN - gridsearch
clear settings

settings.knn.k = 1;
settings.knn.distance = 'euclidean';
settings.note = 'KNN classifier using simple gridsearch on property k.';

settings.gridsearch.mode = 'simple';
settings.gridsearch.kfold = 5;
settings.gridsearch.properties = {'k'};
settings.gridsearch.levels = 1;
settings.gridsearch.bounds = {[1, 30]};
settings.gridsearch.npoints = 30;
settings.gridsearch.scaling = {{'lin'}};

classifyFC(FCdata, 'knn', settings, fullfile(filename, ['knn_sgrid', datamark, '.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final results listing

listSettingsResults(fullfile(expfolder, filename));