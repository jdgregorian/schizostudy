% Script for testing settings of classifiers for FC paper on datasets with
% 180 subjects using four datasets gained through reduction of original
% dataset with 190 subjects by excluding randomly chosen patients to gain 
% balanced dataset (90 patients : 90 controls). 
% The groups are matched on age and sex.
% Moreover, four datasets with lagged correlation matrices are also tested.
% This results in 8 different datasets (4 non-lagged, 4 lagged).
%
% List of datasets:
%   ICA9        - 9 ICA components
%   ICA27       - 27 ICA components
%   AAL90       - AAL atlas with 90 regions (The subjects were reduced from
%                 data_FC_190subjects_B.mat.)
%   Craddock190 - Craddock atlas with 190 regions (The regions were reduced
%                 from data_FC_craddock200_180subjects.mat because of NaN 
%                 values in some regions.)
%
% Lagged versions:
%   ICA9_lag, ICA27_lag, AAL90_lag, Craddock190_lag


% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
ICA9  = fullfile('data', 'data_FC_ica9_180subjects.mat');
ICA27 = fullfile('data', 'data_FC_ica27_180subjects.mat');
AAL90 = fullfile('data', 'data_FC_180subjects.mat');
Craddock190 = fullfile('data', 'data_FC_craddock190_180sub.mat');

ICA9_lag  = fullfile('data', 'data_FC_ica9_lag_abs_180sub.mat');
ICA27_lag = fullfile('data', 'data_FC_ica27_lag_abs_180sub.mat');
AAL90_lag = fullfile('data', 'data_FC_aal90_lag_abs_180sub.mat');
Craddock190_lag = fullfile('data', 'data_FC_craddock190_lag_abs_180sub.mat');

% settings
paperSettings = fullfile(setfolder, 'fcpaperSettings.m');

% summary
settingFiles = {paperSettings};
data = {ICA9, ICA27, AAL90, Craddock190};
expname = 'exp_fcpaper_orig';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));