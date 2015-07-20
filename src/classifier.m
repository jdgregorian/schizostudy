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
    settings = []; 
  end
  
  % settings before the main loop
  switch method
    case 'svm'
      settings.svm = defopts(settings,'svm',[]);
      cellset = cellSettings(settings.svm);
      
    case {'rf','sf','lf','bf'}
      settings.forest = defopts(settings,'forest',[]);
      % gain number of trees 
      nTrees = defopts(settings.forest,'nTrees',11);
      
      switch method
        case 'rf'
          cellset = cellSettings(settings.forest,{'nTrees'});
        case 'sf'
          settings.forest.TreeType = 'stump';
        case 'lf'
          settings.forest.TreeType = 'linear';
      end
  end
  
  % dimension reduction outside the LOO loop
  [data, settings] = reduceDim(data, indices, settings);
  settings.transformPrediction = false;
  
  Nsubjects = size(data,1);
  
  % count LOO cross-validation
  correctPredictions = zeros(1,Nsubjects);
    
  for sub = 1:Nsubjects
    
    trainingSet = data;
    trainingSet(sub,:) = [];
    trainingIndices = indices;
    trainingIndices(sub) = [];
    
    % dimension reduction inside the LOO loop
%     [trainingSet, settings] = reduceDim(trainingSet,settings);
    
    % training
    switch method
      case 'svm' % support vector machine classifier
        SVM = svmtrain(trainingSet,trainingIndices,cellset{:});
        
      case 'rf' % matlab random forest
        % forest learning
        Forest = TreeBagger(nTrees,trainingSet,trainingIndices,cellset{:});
        
      case 'bf' % random forest using matlab trees
        Forest = BinForest(trainingSet,trainingIndices,nTrees,10);
        
      case {'sf','lf'} % stump and linear random forest
        Forest = RandomForest(trainingSet,trainingIndices,nTrees,settings.forest);
        
      otherwise
        fprintf('Wrong method format!!!\n')
        return
        
    end
    
    % prediction
    % transform data if necessary
    if settings.transformPrediction
      transData = data(sub,:)*settings.dimReduction.transMatrix;
    else
      transData = data(sub,:);
    end
    
    % predict according to the method
    switch method
      case 'svm'
        y = svmclassify(SVM,transData);
        
      case {'rf','bf','sf','lf'}
        y = predict(Forest,transData);
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

function [reducedData,settings] = reduceDim(data, indices, settings)
% function for dimension reduction specified in settings
  
  [Nsubjects, dim] = size(data);
  
  % dimension reduction
  defSet.name = 'none';
  settings.dimReduction = defopts(settings,'dimReduction',defSet);
  settings.transformPrediction = false;
  
  switch settings.dimReduction.name
    case 'pca'
      % principle compopnent analysis feature reduction
      nDim = defopts(settings.dimReduction,'nDim',Nsubjects-1); % maximum of chosen dimensions
      if nDim > Nsubjects-1
        nDim = Nsubjects-1;
      end
      
      [settings.dimReduction.transMatrix, transData] = pca(data);
      reducedData = transData(:,1:nDim);
      
      settings.transformPrediction = true;
      
    case 'kendall'
      % Kendall tau rank coefficient feature reduction
      % (according to Hui 2009)
      nDim = defopts(settings.dimReduction, 'nDim', dim); % maximum of chosen dimensions
      treshold = defopts(settings.dimReduction, 'treshold', -1); % minimal Kendall tau rank value
      
      nOne = sum(indices);
      nZero = Nsubjects - nOne;
      nc = zeros(1,dim);
      % for each value from one group count equalities for each value from the
      % other
      for ind = 1:nZero
        for counterInd = nZero + 1:Nsubjects
          nc = nc + (sign(data(ind,:)-data(counterInd,:)) == true(1,dim)*sign(indices(ind)-indices(counterInd)));
        end
      end
      nd = ones(1,dim) * nOne * nZero - nc;
      tau = (nc - nd)/(nZero*nOne); % count Kendall tau ranks
      
      [sortedTau, tauId] = sort(abs(tau),'descend');
      reducedData = data(:,tauId(1:nDim)); % reduction by dimension setting
      reducedData = reducedData(:,sortedTau(1:nDim) > treshold); % reduction by treshold
      
      if isempty(reducedData) % check if some data left
        warning('Too severe constraints! Preventing emptyness of reduced dataset by keeping one dimension with the greatest Kendall tau rank.')
        reducedData = data(:,tauId(1));
      end
      
      settings.transformPrediction = true;
      
    case 'ttest'
      % t-test feature reduction
      nDim = defopts(settings.dimReduction, 'nDim', dim);    % maximum of chosen dimensions
      alpha = defopts(settings.dimReduction, 'alpha', 0.05); % significance level
      
      t2 = zeros(1,dim);
      p = zeros(1,dim);
      for d = 1:dim
        [t2(d), p(d)] = ttest2(data(logical(indices),d),data(~logical(indices),d),'Alpha',alpha);
      end
      
      reducedData = data(:,logical(t2)); % reduction by ttest

      if isempty(reducedData) % check if some data left
        warning('Too severe constraints! Preventing emptyness of reduced dataset by keeping one dimension with the greatest Kendall tau rank.')
        [~, pMinId] = min(p);
        reducedData = data(:,pMinId(1));
      elseif sum(t2) > nDim   % reduction by dimensions with the lowest p-values 
        [~, pId] = sort(p(logical(t2)));
        reducedData = reducedData(:,pId(1:nDim));
      end
      
      settings.transformPrediction = true;
    
    case 'median'
      % feature reduction according to Honza Kalina's suggestion:
      %    Choose median value in each dimension, count how many
      %    individuals has greater or lower value
      
      nOne = sum(indices);
      nZero = Nsubjects - nOne;
      
      medData = median(data,1);
      greaterOnes = false(Nsubjects,dim);
      for ind = 1:Nsubjects
        greaterOnes(ind,:) = data(ind,:) > medData;
      end
      
      warning('Median method is not working yet.');
      reducedData = data;
      
      settings.transformPrediction = true; 
      
    case 'none'
      reducedData = data;
      
    otherwise
      error('Wrong dimReduction property name!!!')
      
  end

end

function cellset = cellSettings(settings,remove)
% cellSettings removes settings in remove and transforms the rest to cell
% array for matlab algorithms
  
  if nargin < 2
    remove = {};
  end
  
  % remove settings from stucture
  for i = 1:length(remove)
    if isfield(settings,remove{i})
      settings = rmfield(settings,remove{i});
    end
  end

  if isempty(settings)
    cellset = {};
  else
    % parse settings to cell array
    settingsNames = fieldnames(settings);
    settingsValues = struct2cell(settings);
    cellset = cell(1,2*length(settingsNames));
    for s = 1 : length(settingsNames)
      cellset{2*s-1} = settingsNames{s};
      cellset{2*s} = settingsValues{s};
    end
  end
end
