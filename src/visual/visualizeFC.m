%% Visualizing FCdata
% Visualization of function connectivity data 190 subjects (100 patients, 
% 90 volunteers), 90x90 connectivity matrix.

%% Initialize
datapath = 'data/data_FC_190subjects_B.mat';
  
data = load(datapath);
FCdata = shiftdim(data.FC, 1);
nData = size(FCdata, 3);

patId = data.indices_patients;
volId = data.indices_volunteers;
nPatients = length(patId);
nVolunteers = length(volId);

%% Average patient and volunteer
h(1) = visualFC(mean(FCdata(:, :, patId), 3), 'Average patient');
h(2) = visualFC(mean(FCdata(:, :, volId), 3), 'Average volunteer');

%% Median patient and volunteer
h(1) = visualFC(median(FCdata(:, :, patId), 3), 'Median patient');
h(2) = visualFC(median(FCdata(:, :, volId), 3), 'Median volunteer');
  
%% Function connectivity volunteers
close all
h = zeros(1, nVolunteers);
for d = 1:nVolunteers
  h(d) = visualFC(FCdata(:, :, volId(d)), 'Volunteer', volId(d));
end

%% Function connectivity patients
close all
h = zeros(1, nPatients);
for d = 1:nPatients
  h(d) = visualFC(FCdata(:, :, patId(d)), 'Patient', patId(d));
end

%% Final clearing
close all
clear