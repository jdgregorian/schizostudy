% Experiment for running arbabshirani settings on splitted traintest data

% initialization
expfolder = fullfile('exp', 'experiments');

% datafiles
arbifolder = fullfile('data', 'arbabshirani', 'traintest');
Abs1 = fullfile(arbifolder, 'adCorrAbs', 'splittedSet_1');
Abs2 = fullfile(arbifolder, 'adCorrAbs', 'splittedSet_2');
Abs3 = fullfile(arbifolder, 'adCorrAbs', 'splittedSet_3');
Pos1 = fullfile(arbifolder, 'adCorrPos', 'splittedSet_1');
Pos2 = fullfile(arbifolder, 'adCorrPos', 'splittedSet_2');
Pos3 = fullfile(arbifolder, 'adCorrPos', 'splittedSet_3');

% settings
arbisettings = fullfile('exp', 'experiments', 'arbabshiraniSettings.m');

% summary
settingFiles = {arbisettings};
data = {Abs1, Abs2, Abs3, Pos1, Pos2, Pos3};
expname = 'exp_splitted_arbi';

% running experiment
runExperiment(settingFiles, data, expname)

% final results listing
listSettingsResults(fullfile(expfolder, expname));