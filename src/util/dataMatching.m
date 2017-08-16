% script for matching data according to age and sex

% load table
% dataFile = fullfile('data', 'data_FC_190subjects_B.mat');
% dataFile = fullfile('data', 'data_FC_190subjects_stringent.mat');
% dataFile = fullfile('data', 'data_FC_190subjects_moderate.mat');
% data = load(dataFile);

% tableFile = fullfile('data', 'subjid_list.csv');
% matchTable = readtable(tableFile);
matchTable = load(fullfile('data', 'matchTable'));
matchTable = matchTable.matchTable;

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

permutations = [];
maxIter = 1000;
iter = 0;

notMatch = true;
while notMatch && (iter < maxIter)
  iter = iter + 1;
  fprintf('%d: ', iter)
  patKeepId = patId(sort(randperm(nPat, nPat - nPatientsOut)));
  conKeepId = conId(sort(randperm(nCon, nCon - nControlsOut)));
  keepId = [patKeepId; conKeepId];
  
  if isempty(permutations) || ~ismember(keepId', permutations, 'rows')
    permutations = [permutations; keepId'];

    % age test
    normalDistPat = chi2gof(age(patKeepId));
    fprintf('chi-age-pat: %d  ', normalDistPat)
    normalDistCon = chi2gof(age(conKeepId));
    fprintf('chi-age-con: %d  ', normalDistCon)
    notMatchAge = ttest2(age(patKeepId), age(conKeepId));
    fprintf('ttest-age: %d  ', notMatchAge)
    % sex test
    notMatchSex = ttest2(sex(patKeepId), sex(conKeepId));
    fprintf('ttest-sex: %d  ', notMatchSex)
    % notMatch = normalDistPat || normalDistCon || notMatchAge || notMatchSex;
    notMatch = normalDistPat || notMatchAge || notMatchSex;
  else
    notMatch = 1;
    fprintf('Permutation already tested')
  end
  fprintf('\n')
end

warning('Chi2-test for age controls ignored.')
subjectKeep = ismember(1:length(age), [patKeepId, conKeepId]);
matchTable_new = matchTable(subjectKeep, :);
subjectOut = find(~subjectKeep);

% save results
save(fullfile('data', 'matching_reduce_190_to_180.mat'), 'subjectOut', 'matchTable', 'matchTable_new')