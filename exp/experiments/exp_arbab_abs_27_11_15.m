% Experiment for running arbabshirani settings on data with
% absolute values of coefficients without incomplete brains, 
% joint ICA training+testing, 20 IC, ICASSO 10x.

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
arbabfolder = fullfile('data', 'arbabshirani');
looTrainData = fullfile(arbabfolder, 'loo', 'adCorrAbs_27_11_15', '32subj_training.mat');
looTestData = fullfile(arbabfolder, 'loo', 'adCorrAbs_27_11_15', '24subj_testing.mat');
looAllData = fullfile(arbabfolder, 'loo', 'adCorrAbs_27_11_15', '56subj_all.mat');
traintestData = fullfile(arbabfolder, 'traintest', 'adCorrAbs_27_11_15');

% settings
arbabsettings = fullfile(setfolder, 'arbabshiraniSettings.m');

% summary
settingFiles = {arbabsettings};
data = {traintestData, looTrainData, looTestData, looAllData};
expname = 'exp_arbab_abs_27_11_15';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));