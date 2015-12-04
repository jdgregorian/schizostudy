% Experiment for running arbabshirani settings on reduced data with
% absolute values of coefficients but without running ICASSO
% plus traintest data with ICASSO

% initialization
expfolder = fullfile('exp', 'experiments');

% datafiles
arbabfolder = fullfile('data', 'arbabshirani');
looTrainData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA_reduced', '80subj_training.mat');
looTestData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA_reduced', '68subj_testing.mat');
looAllData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA_reduced', '148subj_all.mat');
traintestOneICAData = fullfile(arbabfolder, 'traintest', 'adCorrAbs_oneICA_reduced');

% settings
arbabsettings = fullfile('exp', 'experiments', 'arbabshiraniSettings.m');

% summary
settingFiles = {arbabsettings};
data = {traintestOneICAData, looTrainData, looTestData, looAllData};
expname = 'exp_arbab_abs_oneICA_reduced';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));