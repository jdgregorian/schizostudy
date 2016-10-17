% script for DWI detrending using linear regression of age and sex

% load data and table
dataFile = fullfile('data', 'data_DWI_154subjects.mat');
dataContent = load(dataFile);
subFile = fullfile('data', 'mikolas_subjects.mat');
subContent = load(subFile);
subjects = subContent.subjects;

% variables
% male = 1, female = 0
sex = 2 - [subjects.sex]';
age = [subjects.age]';

% count residuals for each dimension
stepConst = 100;
data = zeros(size(dataContent.data));
tic
for c = 1:floor(size(dataContent.data, 2)/stepConst)
  fprintf('Residuals for dimension %d - %d...\n', (c-1)*stepConst+1, c*stepConst)
  res = arrayfun(@(x) gainResiduals([age, sex], dataContent.data(:, x), 2), (c-1)*stepConst+1:c*stepConst, 'UniformOutput', false);
  data(:, (c-1)*stepConst+1 : c*stepConst) = cell2mat(res);
end
% last part
fprintf('Residuals for dimension %d - %d...\n', c*stepConst+1, size(dataContent.data, 2))
res = arrayfun(@(x) gainResiduals([age, sex], dataContent.data(:, x), 2), c*stepConst+1:size(dataContent.data, 2), 'UniformOutput', false);
data(:, c*stepConst+1:end) = cell2mat(res);
toc

% save results
indices = dataContent.indices;
save([dataFile(1:end-4), '_res_age_sex.mat'], 'data', 'indices')