% script for removing outliers from DWI data

% load data and table
dataFile = fullfile('data', 'data_DWI_154subjects.mat');
dataContent = load(dataFile);
subFile = fullfile('data', 'mikolas_subjects.mat');
subContent = load(subFile);
subjects = subContent.subjects;

nPatients = sum(dataContent.indices);
% id's chosen (by Tukey) to be excluded
out_id = [13   72    5  134   99    4   95   80   24   12];
out_id(out_id > nPatients) = out_id(out_id > nPatients) - nPatients;
out_id_05 = out_id(1:4);
out_id_10 = out_id(1:8);

% id's chosen not to be removed
stay_id_05 = true(1, nPatients*2);
stay_id_10 = true(1, nPatients*2);
stay_id_05([out_id_05, out_id_05 + nPatients]) = false;
stay_id_10([out_id_10, out_id_10 + nPatients]) = false;

% save results for 5%
indices = dataContent.indices(stay_id_05);
data = dataContent.data(stay_id_05, :);
save([dataFile(1:end-4), '_out_05.mat'], 'data', 'indices')

% save results for 10%
indices = dataContent.indices(stay_id_10);
data = dataContent.data(stay_id_10, :);
save([dataFile(1:end-4), '_out_10.mat'], 'data', 'indices')