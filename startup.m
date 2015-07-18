addpath(genpath(pwd))
FCdata = fullfile('data','data_FC_190subjects.mat');
FCdata_old = fullfile('data','data_FC_203subjects.mat');
SCdata = fullfile('data','data_SC_190subjects.mat');
SCdata_old = fullfile('data','data_SC_203subjects.mat');

% best so far forest settings on FC data
bestFmethod = 'rf';
bestFsettings.nTrees = 11;
bestFsettings.Fboot = 0.5; 
bestFsettings.SampleWithReplacement = 'off';
bestFsettings.NvarToSample = 100;
bestFsettings.MinLeaf = 1;
bestFsettings.SplitCriterion = 'deviance';
bestFsettings.Surrogate = 'off';

fprintf('Change LOO to common CV.\n')
fprintf('Move datapoints from trees to the whole forest.\n')
fprintf('SVM trees.\n')
fprintf('Adjustable distances. \n')

fprintf('\nMost recent: \n')
fprintf('  kendall - solving too hard conditions case - let one dimension with warning?\n')
fprintf('  t-test - chosen number of dimensions, p-values?, hard condition case, significance level?\n')