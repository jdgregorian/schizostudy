function prepareICAData(folder)
% prepareICAData(data) splits data processed by ICA into separate folders
% convenient for later classification by schizostudy toolbox

  assert(isdir(fullfile(folder, 'training')) && isdir(fullfile(folder, 'testing')), ...
         'Wrong input folder format! Training or testing folder is missing.')
  
  % load variables
  trainVar = load(fullfile(folder, 'training', 'GraphAndData'));
  testVar = load(fullfile(folder, 'testing', 'GraphAndData'));

  % create directories
  mkdir(fullfile(folder, 'loo'))
  mkdir(fullfile(folder, 'loo', 'adCorrAbs'))
  mkdir(fullfile(folder, 'loo', 'adCorrPos'))
  mkdir(fullfile(folder, 'traintest'))
  mkdir(fullfile(folder, 'traintest', 'adCorrAbs'))
  mkdir(fullfile(folder, 'traintest', 'adCorrPos'))
  
  % load and save data
  anId = trainVar.anId;
  nTrain = length(anId);
  adCorrAbs = trainVar.adCorrAbs(:,:,1);
  save(fullfile(folder, 'loo', 'adCorrAbs', [num2str(nTrain), 'subj_training']), 'anId', 'adCorrAbs')
  save(fullfile(folder, 'traintest', 'adCorrAbs', [num2str(nTrain), 'subj_training']), 'anId', 'adCorrAbs')
  adCorrPos = trainVar.adCorrPos(:,:,1);
  save(fullfile(folder, 'loo', 'adCorrPos', [num2str(nTrain), 'subj_training']), 'anId', 'adCorrPos')
  save(fullfile(folder, 'traintest', 'adCorrPos', [num2str(nTrain), 'subj_training']), 'anId', 'adCorrPos')
  
  anId = testVar.anId;
  nTest = length(anId);
  adCorrAbs = testVar.adCorrAbs(:,:,1);
  save(fullfile(folder, 'loo', 'adCorrAbs', [num2str(nTest), 'subj_testing']), 'anId', 'adCorrAbs')
  save(fullfile(folder, 'traintest', 'adCorrAbs', [num2str(nTest), 'subj_testing']), 'anId', 'adCorrAbs')
  adCorrPos = testVar.adCorrPos(:,:,1);
  save(fullfile(folder, 'loo', 'adCorrPos', [num2str(nTest), 'subj_testing']), 'anId', 'adCorrPos')
  save(fullfile(folder, 'traintest', 'adCorrPos', [num2str(nTest), 'subj_testing']), 'anId', 'adCorrPos')
  
  anId = [trainVar.anId; testVar.anId];
  nAll = nTrain + nTest;
  adCorrAbs = [trainVar.adCorrAbs(:,:,1); testVar.adCorrAbs(:,:,1)];
  save(fullfile(folder, 'loo', 'adCorrAbs', [num2str(nAll), 'subj_all']), 'anId', 'adCorrAbs')
  adCorrPos = [testVar.adCorrPos(:,:,1); testVar.adCorrPos(:,:,1)];
  save(fullfile(folder, 'loo', 'adCorrPos', [num2str(nAll), 'subj_all']), 'anId', 'adCorrPos')
  
end