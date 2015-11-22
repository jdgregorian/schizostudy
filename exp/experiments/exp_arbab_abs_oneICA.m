% Experiment for running arbabshirani settings on data with
% absolute values of coefficients but without running ICASSO

% initialization
expfolder = fullfile('exp', 'experiments');

% datafiles
arbabfolder = fullfile('data', 'arbabshirani');
looTrainData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA', '100subj_training.mat');
looTestData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA', '80subj_testing.mat');
looAllData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA', '180subj_all.mat');
traintestData = fullfile(arbabfolder, 'traintest', 'adCorrAbs_oneICA');

% settings
arbabsettings = fullfile('exp', 'experiments', 'arbabshiraniSettings.m');

% summary
settingFiles = {arbabsettings};
data = {traintestData, looTrainData, looTestData, looAllData};
expname = 'exp_arbab_abs_oneICA';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));