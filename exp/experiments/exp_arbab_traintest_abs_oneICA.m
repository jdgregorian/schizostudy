% Experiment for running arbabshirani settings on traintest data with
% absolute values of coefficients but without running ICASSO

% initialization
expfolder = fullfile('exp', 'experiments');

% datafiles
arbabfolder = fullfile('data', 'arbabshirani', 'traintest');
FCAbsData = fullfile(arbabfolder, 'adCorrAbs_oneICA');

% settings
arbabsettings = fullfile('exp', 'experiments', 'arbabshiraniSettings.m');

% summary
settingFiles = {arbabsettings};
data = {FCAbsData};
expname = 'exp_arbab_traintest_abs_oneICA';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));