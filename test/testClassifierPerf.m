% classifier performance test

%% define data

nPatients = 90;
nControls = 90;
dim = 30;
spaceShift = 1;

dimdistname = [num2str(dim), 'D_dist_', strrep(num2str(spaceShift), '.', '~')];
dataname = ['test_data_', dimdistname, '.mat'];
datafolder = fullfile('data', 'test_data');

%% generate data

pat_data = randn(nPatients, dim);
con_data = spaceShift + randn(nControls, dim);

data_mat = [pat_data; con_data];
indices = [ones(nPatients, 1); zeros(nControls, 1)];

%% save generated data

mkdir(datafolder)
save(fullfile(datafolder, dataname), 'data_mat', 'indices')

%% show data

scatter(pat_data(:, 1), pat_data(:, 2), '+', 'r');
hold on
scatter(con_data(:, 1), con_data(:, 2), '+', 'b');
hold off

%% classify

FCdata = fullfile(datafolder, dataname);
filename = ['test_', num2str(dim), 'D'];
expfolder = fullfile('exp', 'experiments');
datamark = ['_test_', dimdistname];
mkdir(expfolder, filename)