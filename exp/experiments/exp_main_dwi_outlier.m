% Script for testing main settings of classifiers on DWI datasets with
% 138 and 146 subjects with dimension reduced by pca to 20. Subject number
% was reduced by outlier analysis in cluster_dwi script from the original
% DWI dataset with 154 subjects.
% Leave-two-out method is used.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
DWI154sub = fullfile('data', 'data_DWI_154subjects.mat');

% main settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% additional settings
pca20  = ['settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 20;'];
ltoSet_05 = ['settings.crossval = ''lto'';',...
             'settings.pairing = [1:73, 1:73];', ...
             pca20];
ltoSet_10 = ['settings.crossval = ''lto'';',...
             'settings.pairing = [1:69, 1:69];', ...
             pca20];
        
% summary
settingFiles = {mainSettings};
data = {DWI154sub};
additionalSettings = {ltoSet_05, ltoSet_10};
expname = 'exp_main_dwi_outlier';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));