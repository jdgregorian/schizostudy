function splitTrainTest(folder, numberOfTraining, numberOfTesting)
% splitTrainTest splits datasets in traintest type 'folder' to datasets
% containing 'numberOfTraining' training patients plus 'numberOfTraining'
% training healthy subjects and 'numberOfTesting' testning patients plus 
% 'numberOfTesting' testing healthy subjects 
  
  switch nargin
    case 0
      help splitTrainTest
      return
    case 1
      numberOfTraining = 16;
      numberOfTesting = 12;
    case 2
      numberOfTesting = numberOfTraining;
  end
  
  dirContent = dir(fullfile(folder, '*.mat'));
  
  assert(~isempty(dirContent), 'Too few datasets in folder %s', folder)
  
  splittedTraining = splitData(folder, dirContent, 'training', numberOfTraining);
  splittedTesting = splitData(folder, dirContent, 'testing', numberOfTesting);
  
  for s = 1:length(splittedTraining)
    newFolderName = fullfile(folder, ['splittedSet_', num2str(s)]);
    mkdir(newFolderName)
    eval([splittedTraining(s).names.vector, ' =  splittedTraining(s).labels;'])
    eval([splittedTraining(s).names.matrix, ' =  splittedTraining(s).data;'])
    save(fullfile(newFolderName, [num2str(2*numberOfTraining), 'subj_training.mat']), ...
      splittedTraining(s).names.vector, splittedTraining(s).names.matrix); 
    eval([splittedTraining(s).names.vector, ' =  splittedTesting(s).labels;'])
    eval([splittedTesting(s).names.matrix, ' =  splittedTesting(s).data;'])
    save(fullfile(newFolderName, [num2str(2*numberOfTesting), 'subj_testing.mat']), ...
      splittedTraining(s).names.vector, splittedTesting(s).names.matrix);
  end
    
end

function splittedData = splitData(folder, dirContent, dataType, numberOfPoints)
% splitting function for data
% Works only for equal number of data in both categories
%
% Input:
%    folder         - folder with .mat files
%    dirContent     - .mat files in splitted directory
%    dataType       - string contrained in filenames to split
%    numberOfPoints - number of points in each split

  dataID = cell2mat(cellfun(@(x) ~isempty(strfind(x, dataType)), {dirContent.name}, 'UniformOutput', false));
  
  if ~any(dataID)
    warning('There is no filename containing %s.', dataType)
    return
  end
  
  content = load(fullfile(folder, dirContent(dataID).name));
  
  [labels, data, names] = vectOrMat(content);
  categories = unique(labels);
  maxSplits = floor(length(labels)/(2*numberOfPoints)); 
  onesId = find(labels == categories(1));
  twosId = find(labels == categories(2));
  for s = 1:maxSplits
    actualOnesId = onesId((s-1)*numberOfPoints + 1:s*numberOfPoints);
    actualTwosId = twosId((s-1)*numberOfPoints + 1:s*numberOfPoints);
    splittedData(s).labels = [labels(actualOnesId); labels(actualTwosId)]; 
    splittedData(s).data = [data(actualOnesId, :); data(actualTwosId, :)]; 
    splittedData(s).names = names;
  end
end