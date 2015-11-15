% Experiment for running arbabshirani settings on splitted traintest data

arbifolder = fullfile('data', 'arbabshirani', 'traintest');
Abs1 = fullfile(arbifolder, 'adCorrAbs', 'splittedSet_1');
Abs2 = fullfile(arbifolder, 'adCorrAbs', 'splittedSet_2');
Abs3 = fullfile(arbifolder, 'adCorrAbs', 'splittedSet_3');
Pos1 = fullfile(arbifolder, 'adCorrPos', 'splittedSet_1');
Pos2 = fullfile(arbifolder, 'adCorrPos', 'splittedSet_2');
Pos3 = fullfile(arbifolder, 'adCorrPos', 'splittedSet_3');

arbisettings = fullfile('exp', 'experiments', 'arbabshiraniSettings.m');

settingFiles = {arbisettings};
data = {Abs1, Abs2, Abs3, Pos1, Pos2, Pos3};
expname = 'exp_splitted_arbi';

