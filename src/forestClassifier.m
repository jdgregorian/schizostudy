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
  
  if nargin < 4
    settings = struct([]);
  end
  
  % gain number of trees 
  nTrees = defopts(settings,'nTrees',11);
  
  % count LOO cross-validation
  Nsubjects = size(data,1);
  correctPredictions = zeros(1,Nsubjects);
    
  for sub = 1:Nsubjects
    trainingSet = data;
    trainingSet(sub,:) = [];
    trainingIndices = indices;
    trainingIndices(sub) = [];
    
    switch method
      case 'rf' % matlab random forest
        % remove nTrees from setting for easier parsing
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
        for s = 1 : length(settingsNames)
          otherSettings{2*s-1} = settingsNames{s};
          otherSettings{2*s} = settingsValues{s};
        end
        
        % forest learning
        Forest = TreeBagger(nTrees,trainingSet,trainingIndices,otherSettings{:});
        
      case 'bf' % random forest using matlab trees
        Forest = BinForest(trainingSet,trainingIndices,nTrees,10);
        
      case 'sf' % stump random forest
        settings.TreeType = 'stump';
        Forest = RandomForest(trainingSet,trainingIndices,nTrees,settings);
        
      case 'lf' % linear random forest
        settings.TreeType = 'linear';
        Forest = RandomForest(trainingSet,trainingIndices,nTrees,settings);
        
    end

    y = predict(Forest,data(sub,:));
    if iscell(y)
      y = str2double(y{1});
    end
    if y == indices(sub)
      correctPredictions(sub) = 1;
    end
    fprintf('Subject %d/%d done. Actual performance: %.2f%% \n',sub,Nsubjects,sum(correctPredictions)/sub*100);
  end

  performance = sum(correctPredictions)/Nsubjects;

end
