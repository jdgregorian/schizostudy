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
  
  splitData(dirContent, 'training')
    
end

function splitData(dirContent, dataType)
% splitting function
%
% Input:
%    dirContent - mat files in splitted directory
%    dataType   - string contrained in filenames to split

  dataID = cell2mat(cellfun(@(x) ~isempty(strfind(x, dataType)), {dirContent.name}, 'UniformOutput', false));
  
  if ~any(dataID)
    warning('There is no filename containing %s.', dataType)
    return
  end
  
  load(dirContent(dataID).name)

end