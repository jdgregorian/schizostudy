% Experiment for running arbabshirani settings on splitted traintest data

% initialization
expfolder = fullfile('exp', 'experiments');
setfolder = fullfile('exp', 'settings');

% datafiles
arbabfolder = fullfile('data', 'arbabshirani', 'traintest');
Abs1 = fullfile(arbabfolder, 'adCorrAbs', 'splittedSet_1');
Abs2 = fullfile(arbabfolder, 'adCorrAbs', 'splittedSet_2');
Abs3 = fullfile(arbabfolder, 'adCorrAbs', 'splittedSet_3');
Pos1 = fullfile(arbabfolder, 'adCorrPos', 'splittedSet_1');
Pos2 = fullfile(arbabfolder, 'adCorrPos', 'splittedSet_2');
Pos3 = fullfile(arbabfolder, 'adCorrPos', 'splittedSet_3');

% settings
arbabsettings = fullfile(setfolder, 'arbabshiraniSettings.m');

% summary
settingFiles = {arbabsettings};
data = {Abs1, Abs2, Abs3, Pos1, Pos2, Pos3};
expname = 'exp_splitted_arbi';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));