% Script for testing main settings of classifiers with dimension reduced by
% highest means to 40, 80, 150, 300, 500, 1000, 2000

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC190sub_B = fullfile('data', 'data_FC_190subjects_B.mat');

% settings
mainSet = fullfile(setfolder, 'mainSettings.m');

% additional settings
hmean40   = ['settings.dimReduction.name = ''hmean'';',...
             'settings.dimReduction.nDim = 40;'];
hmean80   = ['settings.dimReduction.name = ''hmean'';',...
             'settings.dimReduction.nDim = 80;'];
hmean150  = ['settings.dimReduction.name = ''hmean'';',...
             'settings.dimReduction.nDim = 150;'];
hmean300  = ['settings.dimReduction.name = ''hmean'';',...
             'settings.dimReduction.nDim = 300;'];
hmean500  = ['settings.dimReduction.name = ''hmean'';',...
             'settings.dimReduction.nDim = 500;'];
hmean1000 = ['settings.dimReduction.name = ''hmean'';',...
             'settings.dimReduction.nDim = 1000;'];
hmean2000 = ['settings.dimReduction.name = ''hmean'';',...
             'settings.dimReduction.nDim = 2000;'];

% summary
settingFiles = {mainSet};
data = {FC190sub_B};
additionalSettings = {hmean40, hmean80, hmean150, hmean300, hmean500, hmean1000, hmean2000};
expname = 'exp_main_hmean';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));