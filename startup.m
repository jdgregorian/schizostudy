addpath(genpath(pwd))
FCdata = fullfile('data','data_FC_203subjects.mat');
SCdata = fullfile('data','data_SC_203subjects.mat');

% best so far forest settings on FC data
bestFmethod = 'rf';
bestFsettings.nTrees = 100;
bestFsettings.Fboot = 1; 
bestFsettings.SampleWithReplacement = 'off';
bestFsettings.NvarToSample = 500;
bestFsettings.MinLeaf = 8;
bestFsettings.SplitCriterion = 'gdi';
bestFsettings.Surrogate = 'off';