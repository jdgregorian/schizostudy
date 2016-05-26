%% Visualizing FCdata
% Visualization of function connectivity data 190 subjects (100 patients, 
% 90 volunteers), 90x90 connectivity matrix.
%
% First pixel of each image was substituted by minimal value from all
% matrices to gain comparable color range for all images.

%% Initialize
datapath = 'data/data_FC_190subjects_B.mat';
  
data = load(datapath);
FCdata = shiftdim(data.FC, 1);
nData = size(FCdata, 3);

patId = data.indices_patients;
volId = data.indices_volunteers;
nPatients = length(patId);
nVolunteers = length(volId);
minVal = min(min(min(FCdata)));

%% Average patient and volunteer
close all
h(1) = visualFC(mean(FCdata(:, :, patId), 3), 'Average patient', [], minVal);
h(2) = visualFC(mean(FCdata(:, :, volId), 3), 'Average volunteer', [], minVal);

%% Median patient and volunteer
close all
h(1) = visualFC(median(FCdata(:, :, patId), 3), 'Median patient', [], minVal);
h(2) = visualFC(median(FCdata(:, :, volId), 3), 'Median volunteer', [], minVal);
  
%% Function connectivity volunteers
close all
h = zeros(1, nVolunteers);
for d = 1:nVolunteers
  h(d) = visualFC(FCdata(:, :, volId(d)), 'Volunteer', volId(d), minVal);
end

%% Function connectivity patients
close all
h = zeros(1, nPatients);
for d = 1:nPatients
  h(d) = visualFC(FCdata(:, :, patId(d)), 'Patient', patId(d), minVal);
end

%% Final clearing
close all
clear