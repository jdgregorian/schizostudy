% script for FC detrending using linear regression of age and sex

% load data and table
% dataFile = fullfile('data', 'data_FC_190subjects_B.mat');
% dataFile = fullfile('data', 'data_FC_190subjects_stringent.mat');
dataFile = fullfile('data', 'data_FC_190subjects_moderate.mat');
data = load(dataFile);
tableFile = fullfile('data', 'subjid_list.csv');
matchTable = readtable(tableFile);

% variables
% male = 1, female = 0
sex = cellfun(@(x) strcmp(x, 'M'), matchTable.Var3);
age = matchTable.Var4;

% count residuals for each dimension
FC = ones(size(data.FC));
for r = 1:size(data.FC, 2)
  for c = r+1 : size(data.FC, 3)
    res = gainResiduals([age, sex], data.FC(:, r, c), 2);
    FC(:, r, c) = res;
    FC(:, c, r) = res;
  end
end

% save results
indices_patients = data.indices_patients;
indices_volunteers = data.indices_volunteers;
save([dataFile(1:end-4), '_res_age_sex.mat'], 'FC', 'indices_patients', 'indices_volunteers')