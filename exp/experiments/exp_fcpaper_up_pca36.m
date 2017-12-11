% Script for testing settings of classifiers for FC paper on datasets with
% 180 subjects using four datasets gained through reduction of original
% dataset with 190 subjects by excluding randomly chosen patients to gain 
% balanced dataset (90 patients : 90 controls). 
% The groups are matched on age and sex.
% Moreover, six datasets with lagged correlation matrices are also tested.
% This results in 12 different datasets (6 non-lagged, 6 lagged).
% 
% This script tests datasets reduced by PCA to dimension 36.
%%
% List of datasets:
%   ICA9        - 9 ICA components
%   ICA9_den    - 9 ICA components, extra denoising
%   ICA24       - 24 ICA components
%   ICA24_den   - 24 ICA components, extra denoising
%   AAL90       - AAL atlas with 90 regions (The subjects were reduced from
%                 data_FC_190subjects_B.mat.)
%   Craddock196 - Craddock atlas with 196 regions (The regions were reduced
%                 because of NaN values in some regions.)
%
% Lagged versions:
%   ICA9_lag, ICA9_den_lag, ICA24_lag, ICA24_den_lag, AAL90_lag, Craddock196_lag  

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
ICA9        = fullfile('data', 'unified_preprocessing', 'data_FC_ica9_up_180sub.mat');
ICA9_den    = fullfile('data', 'unified_preprocessing', 'data_FC_ica9_up_180sub_denoise.mat');
ICA24       = fullfile('data', 'unified_preprocessing', 'data_FC_ica24_up_180sub.mat');
ICA24_den   = fullfile('data', 'unified_preprocessing', 'data_FC_ica24_up_180sub_denoise.mat');
AAL90       = fullfile('data', 'unified_preprocessing', 'data_FC_aal90_up_180sub.mat');
Craddock196 = fullfile('data', 'unified_preprocessing', 'data_FC_craddock196_up_180sub.mat');

ICA9_lag        = fullfile('data', 'unified_preprocessing', 'data_FC_ica9_up_lag_abs_180sub.mat');
ICA9_den_lag    = fullfile('data', 'unified_preprocessing', 'data_FC_ica9_up_lag_abs_180sub_denoise.mat');
ICA24_lag       = fullfile('data', 'unified_preprocessing', 'data_FC_ica24_up_lag_abs_180sub.mat');
ICA24_den_lag   = fullfile('data', 'unified_preprocessing', 'data_FC_ica24_up_lag_abs_180sub_denoise.mat');
AAL90_lag       = fullfile('data', 'unified_preprocessing', 'data_FC_aal90_up_lag_abs_180sub.mat');
Craddock196_lag = fullfile('data', 'unified_preprocessing', 'data_FC_craddock196_up_lag_abs_180sub.mat');

% settings
paperSettings = fullfile(setfolder, 'fcpaperSettings.m');

% additional settings
pca36  = ['settings.dimReduction.name = ''pca'';',...
          'settings.dimReduction.nDim = 36;'];
	  
% summary
settingFiles = {paperSettings};
data = {ICA9, ICA9_den, ICA24, ICA24_den, AAL90, Craddock196, ICA9_lag, ICA9_den_lag, ICA24_lag, ICA24_den_lag, AAL90_lag, Craddock196_lag};
additionalSettings = {pca36};
expname = 'exp_fcpaper_up_pca36';

% running experiment
runExperiment(settingFiles, data, expname, additionalSettings)

% final results listing
listSettingsResults(fullfile(expfolder, expname));
