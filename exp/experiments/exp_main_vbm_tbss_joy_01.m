% Script for testing main settings of classifiers on datasets 
% with 72 subjects with dimension reduced by pca to 20, 40, 71.
% Modalities are VBM, TBSS and fMRI-joystick.
% Leave-one-out method is used.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
vbm72sub = fullfile('data', 'data_vbm_72subjects.mat');
tbss72sub = fullfile('data', 'data_tbss_72subjects.mat');
joy72sub = fullfile('data', 'data_fmri_joystick_72subjects.mat');

% main settings
mainSettings = fullfile(setfolder, 'mainSettings.m');

% additional settings
pca20 = ['settings.dimReduction.name = ''pca'';',...
         'settings.dimReduction.nDim = 20;'];
pca40 = ['settings.dimReduction.name = ''pca'';',...
         'settings.dimReduction.nDim = 40;'];
pca71 = ['settings.dimReduction.name = ''pca'';',...
         'settings.dimReduction.nDim = 71;'];
nopca = '';

% summary
settingFiles = {mainSettings};
data = {vbm72sub, tbss72sub, joy72sub};
additionalSettings = {pca20, pca40, pca71, nopca};
expname = 'exp_main_vbm_tbss_joy_01';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));