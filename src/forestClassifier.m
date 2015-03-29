function performance = forestClassifier(method, data, indices, settings)
% Classification by MATLAB forest classifier. Returns performance of forest in LOO CV.
  
  % gain number of trees and remove it from setting for easier parsing
  nTrees = defopts(settings,'nTrees',100);
  if isfield(settings,'nTrees')
    settings = rmfield(settings,'nTrees');
  end
  
  % if setting are now empty, fill some default value
  if isempty(settings)
    settings.FBoot = 1;
  end
  
  % parse settings to cell array
  settingsNames = fieldnames(settings);
  settingsValues = struct2cell(settings);
  otherSettings = cell(1,2*length(settingsNames));
  for i = 1 : length(settingsNames)
    otherSettings{2*i-1} = settingsNames{i};
    otherSettings{2*i} = settingsValues{i};
  end
  
  Nsubjects = size(data,1);
  correctPredictions = zeros(1,Nsubjects);
    
  for i = 1:Nsubjects
    trainingSet = data;
    trainingSet(i,:) = [];
    trainingIndices = indices;
    trainingIndices(i) = [];
    switch method
      case 'rf'
        Forest = TreeBagger(nTrees,trainingSet,trainingIndices,otherSettings{:});
      case 'bf'
        Forest = BinForest(trainingSet,trainingIndices,5);
    end

    y = predict(Forest,data(i,:));
    if strcmp(y{1},num2str(indices(i)))
      correctPredictions(i) = 1;
    end
    fprintf('Subject %d/%d done...\n',i,Nsubjects);
  end

  performance = sum(correctPredictions)/Nsubjects;

end
