% Script for testing main settings of classifiers with dimension reduced by
% pca to 20, 40, 80, 150, 189

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
FC190sub_B = fullfile('data', 'data_FC_190subjects_B.mat');

% settings
mainSet = fullfile(setfolder, 'mainSettings.m');

% additional settings
pca20  = ['settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 20;'];
pca40  = ['settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 40;'];
pca80  = ['settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 80;'];
pca150 = ['settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 150;'];
pca189 = ['settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 189;'];

% summary
settingFiles = {mainSet};
data = {FC190sub_B};
additionalSettings = {pca20, pca40, pca80, pca150, pca189};
expname = 'exp_main_pca';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));