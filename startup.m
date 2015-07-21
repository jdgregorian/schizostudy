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
fprintf('SVM trees.\n')
fprintf('Median reduction method??? - according to Honza''s sugestion?\n')

fprintf('\nMost recent: \n')
fprintf('  Adjustable distances. \n')