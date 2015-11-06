% check if data folder exists
if ~isdir('data')
  mkdir('data')
end

addpath(genpath('data'))
addpath(genpath('exp'))
addpath(genpath('src'))
addpath(genpath('test'))
addpath(genpath(fullfile('vendor','prtools')))

FCdata = fullfile('data','data_FC_190subjects.mat');
FCdata_old = fullfile('data','data_FC_203subjects.mat');
% SCdata = fullfile('data','data_SC_190subjects.mat');
% SCdata_old = fullfile('data','data_SC_203subjects.mat');

% Startup tasks informations
if exist(fullfile('test','sys','.creator'),'file')
  taskInfo
end
