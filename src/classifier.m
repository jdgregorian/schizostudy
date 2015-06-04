function performance = classifier(method, data, indices, settings)
% Classification by classifier chosen in method. Returns performance of 
% appropriate classifier in LOO CV.
%
% method   - shortcut of the classifier type used ('rf','bf','sf','lf') 
%            | string
% data     - input data matrix (1st dim - single data, 2nd data dimension)
%            | double matrix
% indices  - class labels for each data | double vector
% settings - structure of additional settings for classifier specified in
%            method

  % default value
  performance = NaN;

  if nargin < 4
    settings = struct([]);
  end
  
  Nsubjects = size(data,1);
  
  % dimension reduction
  defSet.name = 'none';
  settings.dimReduction = defopts(settings,'dimReduction',defSet);
  
  switch settings.dimReduction.name
    case 'pca'
      nDim = defopts(settings.dimReduction,'nDim',Nsubjects-1);
      if nDim > Nsubjects-1
        nDim = Nsubjects-1;
      end
      
      [~,transData] = pca(data);
      dataRedDim = transData(:,1:nDim);
      
    case 'none'
      dataRedDim = data;
      
    otherwise
      fprintf('Wrong dimReduction property name!!!\n')
      return
  end
  
  % count LOO cross-validation
  correctPredictions = zeros(1,Nsubjects);
    
  for sub = 1:Nsubjects
    trainingSet = dataRedDim;
    trainingSet(sub,:) = [];
    trainingIndices = indices;
    trainingIndices(sub) = [];
    
    % training
    switch method
      case 'rf' % matlab random forest
        
        % gain number of trees 
        nTrees = defopts(settings,'nTrees',11);
        
        % remove nTrees and dimReduction from setting for easier parsing
        settings = rmfield(settings,'nTrees');
        if isfield(settings,'dimReduction')
          settings = rmfield(settings,'dimReduction');
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
        
        % gain number of trees 
        nTrees = defopts(settings,'nTrees',11);
        Forest = BinForest(trainingSet,trainingIndices,nTrees,10);
        
      case 'sf' % stump random forest
        
        % gain number of trees 
        nTrees = defopts(settings,'nTrees',11);
        settings.TreeType = 'stump';
        Forest = RandomForest(trainingSet,trainingIndices,nTrees,settings);
        
      case 'lf' % linear random forest
        
        % gain number of trees 
        nTrees = defopts(settings,'nTrees',11);
        settings.TreeType = 'linear';
        Forest = RandomForest(trainingSet,trainingIndices,nTrees,settings);
        
      otherwise
        
        fprintf('Wrong method format!!!\n')
        return
        
    end
    
    % prediction
    switch method
      case {'rf','bf','sf','lf'}
        y = predict(Forest,dataRedDim(sub,:));
    end
    
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
