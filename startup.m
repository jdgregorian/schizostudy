% check if data folder exists
if ~isdir('data')
  mkdir('data')
end

addpath(genpath('data'))
addpath(genpath('doc'))
addpath(genpath('exp'))
addpath(genpath('src'))
addpath(genpath('test'))

% toolbox checking
if ~isdir(fullfile('vendor', 'prtools'))
  warning([' PrTools toolbox is missing! It might cause malfunction of some classifiers.',...
           ' Download PrTools at http://www.37steps.com/software/ to vendor directory.'])
else
  addpath(genpath(fullfile('vendor', 'prtools')))
end

if ~isdir(fullfile('vendor', 'conn'))
  fprintf('\n---------------------------------------------------------------------------------\n\n')
  fprintf('    Download CONN at https://www.nitrc.org/projects/conn to vendor directory\n')
  fprintf('\n---------------------------------------------------------------------------------\n\n')
else
  addpath(genpath(fullfile('vendor', 'conn')))
end

% define useful variables
FCdata = fullfile('data', 'data_FC_190subjects_B.mat');

% startup tasks informations
if exist(fullfile('test', 'sys', '.creator'), 'file')
  taskInfo
end
