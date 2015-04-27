function performance = forestClassifier(method, data, indices, settings)
% Classification by forest classifier. Returns performance of the forest in
% LOO CV.
%
% method   - shortcut of the forest type used ('rf','bf','sf') | string
% data     - input data matrix (1st dim - single data, 2nd data dimension)
%            | double matrix
% indices  - class labels for each data | double vector
% settings - structure of additional settings for forest specified in
%            method
  
  % gain number of trees and remove it from setting for easier parsing
  nTrees = defopts(settings,'nTrees',11);
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
  
  % count LOO cross-validation
  Nsubjects = size(data,1);
  correctPredictions = zeros(1,Nsubjects);
    
  for i = 1:Nsubjects
    trainingSet = data;
    trainingSet(i,:) = [];
    trainingIndices = indices;
    trainingIndices(i) = [];
    switch method
      case 'rf' % matlab random forest
        Forest = TreeBagger(nTrees,trainingSet,trainingIndices,otherSettings{:});
      case 'bf' % random forest using matlab trees
        Forest = BinForest(trainingSet,trainingIndices,nTrees,10);
      case 'sf' % stump forest
        Forest = StumpForest(trainingSet,trainingIndices,nTrees);
    end

    y = predict(Forest,data(i,:));
    if iscell(y)
      y = str2double(y{1});
    end
    if y == indices(i)
      correctPredictions(i) = 1;
    end
    fprintf('Subject %d/%d done. Actual performance: %.2f%% \n',i,Nsubjects,sum(correctPredictions)/i*100);
  end

  performance = sum(correctPredictions)/Nsubjects;

end
