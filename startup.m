addpath(genpath('data'))
addpath(genpath('results'))
addpath(genpath('src'))
addpath(genpath('test'))

FCdata = fullfile('data','data_FC_190subjects.mat');
FCdata_old = fullfile('data','data_FC_203subjects.mat');
SCdata = fullfile('data','data_SC_190subjects.mat');
SCdata_old = fullfile('data','data_SC_203subjects.mat');

% Startup tasks informations
fprintf('Checkout SVM toolbox.\n')

fprintf('\nMost recent: \n')
fprintf('    Prepare testing kit for different settings - improve testRFparams?\n')
fprintf('    Trees - Add weight vector to information gain counting. Make InfoGain solo function?\n')
fprintf('    Implement t-test (kendall) feature selection from MATLAB.\n')
fprintf('    ANN ? LDA\n')
fprintf('    Implement all Arbabshirani''s methods.\n')
