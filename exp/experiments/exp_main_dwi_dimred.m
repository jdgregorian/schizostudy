% Script for testing main settings of classifiers on DWI dataset with
% 154 subjects with dimension reduced by pca to 20, 40, 80, 153 and by
% ttest using significance level 0.05 out of cross-validation loop.
% Leave-two-out method is used.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
DWI154sub = fullfile('data', 'data_DWI_154subjects.mat');

% main settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% additional settings
ltoSet = ['settings.crossval = ''lto'';',...
          'settings.pairing = [1:77, 1:77];'];
pca20  = [ltoSet,...
          'settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 20;'];
pca40  = [ltoSet,...
          'settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 40;'];
pca80  = [ltoSet,...
          'settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 80;'];
pca153 = [ltoSet,...
          'settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 153;'];
ttest05 = [ltoSet,...
          'settings.dimReduction.name = ''ttest'';',...
          'settings.dimReduction.alpha = 0.05;'];

% summary
settingFiles = {mainSettings};
data = {DWI154sub};
additionalSettings = {pca20, pca40, pca80, pca153, ttest05};
expname = 'exp_main_dwi_dimred';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));