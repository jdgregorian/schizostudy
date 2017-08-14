% script for matching data according to age and sex

% load table
% dataFile = fullfile('data', 'data_FC_190subjects_B.mat');
% dataFile = fullfile('data', 'data_FC_190subjects_stringent.mat');
% dataFile = fullfile('data', 'data_FC_190subjects_moderate.mat');
% data = load(dataFile);
tableFile = fullfile('data', 'subjid_list.csv');
matchTable = readtable(tableFile);

% variables
% male = 1, female = 0
sex = cellfun(@(x) strcmp(x, 'M'), matchTable.Var3);
age = matchTable.Var4;
diagnoses = matchTable.Var2;
code = matchTable.Var1;

% choose patients and controls to be removed
nPatientsOut = 10;
nControlsOut = 0;

patId = find(strcmp(diagnoses, 'pacient'));
conId = find(strcmp(diagnoses, 'kontrola'));
nPat = length(patId);
nCon = length(conId);

assert(nPatientsOut < nPat, 'Too many patients to exclude')
assert(nControlsOut < nCon, 'Too many controls to exclude')

notMatch = true;
while notMatch
  patKeepId = patId(sort(randperm(nPat, nPat - nPatientsOut)));
  conKeepId = conId(sort(randperm(nCon, nCon - nControlsOut)));
  
%   newAge = age([patKeepId, conKeepId]);
%   newSex = sex([patKeepId, conKeepId]);

  ttest2(age(patKeepId), age(conKeepId))
  notMatch = false;
end

% save results
% indices_patients = data.indices_patients;
% indices_volunteers = data.indices_volunteers;
% save([dataFile(1:end-4), '_res_age_sex.mat'], 'FC', 'indices_patients', 'indices_volunteers')