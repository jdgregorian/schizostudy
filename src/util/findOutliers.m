% script to find outliers among patients in DWI dataset 

%% load data

datafile = 'data/data_DWI_154subjects.mat';
S = load(datafile);
patients = S.data(78:end, :);

%% find outliers

% decrease dimension
fprintf('Using PCA...\n')
pcaPatients = pcaReduction(patients);
nPatients = size(patients, 1);
mahal_dist = NaN(nPatients, 1);
% mahalanobis distance for each point from the rest
fprintf('Computing mahalanobis distance...\n')
for p = 1:nPatients
  id = true(1, nPatients);
  id(p) = false;
  % count mahalanobis distance
  mahal_dist(p) = mahal(pcaPatients(p, :), pcaPatients(id, :));
end

disp(mahal_dist)