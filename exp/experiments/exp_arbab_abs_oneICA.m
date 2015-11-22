% Experiment for running arbabshirani settings on data with
% absolute values of coefficients but without running ICASSO
% plus traintest data with ICASSO

% initialization
expfolder = fullfile('exp', 'experiments');

% datafiles
arbabfolder = fullfile('data', 'arbabshirani');
looTrainData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA', '100subj_training.mat');
looTestData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA', '80subj_testing.mat');
looAllData = fullfile(arbabfolder, 'loo', 'adCorrAbs_oneICA', '180subj_all.mat');
traintestOneICAData = fullfile(arbabfolder, 'traintest', 'adCorrAbs_oneICA');
traintestAbsData = fullfile(arbabfolder, 'traintest', 'adCorrAbs');
traintestPosData = fullfile(arbabfolder, 'traintest', 'adCorrPos');

% settings
arbabsettings = fullfile('exp', 'experiments', 'arbabshiraniSettings.m');

% summary
settingFiles = {arbabsettings};
data = {traintestOneICAData, looTrainData, looTestData, looAllData, traintestAbsData, traintestPosData};
expname = 'exp_arbab_abs_oneICA';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));