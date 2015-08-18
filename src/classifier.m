function [performance, class] = classifier(method, data, indices, settings)
% Classification by classifier chosen in method. Returns performance of 
% appropriate classifier in LOO CV.
%
% method   - shortcut of the classifier type used | string
%            'svm'     - support vector machine
%            'rf'      - random forest
%            'mrf'     - MATLAB random forest
%            'bf'      - binary forest
%            'lintree' - tree using linear distance based decision splits
%            'svmtree' - tree using linear svm based decision splits
%            'nb'      - naive Bayes
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
    case 'svm' % support vector machine
      settings.svm = defopts(settings, 'svm', []);
      cellset = cellSettings(settings.svm);
      
    case {'rf', 'mrf', 'bf'} % forests
      settings.forest = defopts(settings, 'forest', []);
      % gain number of trees 
      nTrees = defopts(settings.forest, 'nTrees', 11);
      
      if strcmpi(method, 'mrf')
          cellset = cellSettings(settings.forest, {'nTrees'});
      end
      
    case {'lintree', 'mtltree', 'svmtree'} % trees
      settings.tree = defopts(settings, 'tree', []);
      
      if strcmpi(method, 'mtltree')
        cellset = cellSettings(settings.tree);
      end
      
    case 'nb' % naive Bayes
      settings.bayes = defopts(settings, 'bayes', []);
      settings.bayes.type = defopts(settings.bayes, 'type', 'diaglinear');
      
    case 'knn' % k-nearest neighbours
      settings.knn = defopts(settings, 'knn', []);
      settings.knn.k = defopts(settings.knn, 'k', 1);
      settings.knn.distance = defopts(settings.knn, 'distance', 'euclidean');
      settings.knn.rule = defopts(settings.knn, 'rule', 'nearest');
      
    case 'llc' % logistic linear classifier
      if isfield(settings,'llc')
        warning('Logistic linear classifier do not accept additional settings.')
      end
      
  end
  
  % dimension reduction outside the LOO loop
  [data, settings] = reduceDim(data, indices, settings);
  settings.transformPrediction = false; % reduction is outside -> further 
                                        % transformation is not necessary
  Nsubjects = size(data, 1);
  
  % data scaling to zero mean and unit variance
  settings.autoscale = defopts(settings, 'autoscale', false);
  if settings.autoscale
    mx    = mean(data);
    stdx  = std(data);
    data    = (data-mx(ones(Nsubjects,1),:))./stdx(ones(Nsubjects,1),:);
  end
  
  % count LOO cross-validation
  class = zeros(1, Nsubjects);
  correctPredictions = zeros(1, Nsubjects);
    
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
        SVM = svmtrain(trainingSet, trainingIndices, cellset{:});
%           SVM = svmtrain(trainingSet,trainingIndices','-t 0');
%         SVM = fitcsvm(trainingSet,trainingIndices,cellset{:});
        
      case 'mrf' % matlab random forest
        % forest learning
        Forest = TreeBagger(nTrees, trainingSet, trainingIndices, cellset{:});
        
      case 'bf' % random forest using matlab trees
        Forest = BinForest(trainingSet, trainingIndices, nTrees, 10);
        
      case 'rf' % random forest
        Forest = RandomForest(trainingSet, trainingIndices, nTrees, settings.forest);
        
      case 'lintree' % linear tree
        Forest = LinearTree(trainingSet, trainingIndices, settings.tree);
        
      case 'svmtree' % SVM tree
        Forest = SVMTree(trainingSet, trainingIndices, settings.tree);
        
      case 'mtltree' % matlab classification tree
        Forest = ClassificationTree.fit(trainingSet, trainingIndices, cellset{:});
        
      case 'llc' % logistic linear classifier
        LLC = mnrfit(trainingSet, trainingIndices' + 1);
        
    end
    
    % prediction
    % transform data if necessary (automatically disabled in outside
    % transformation)
    if settings.transformPrediction
      transData = data(sub,:)*settings.dimReduction.transMatrix;
    else
      transData = data(sub,:);
    end
    
    % predict according to the method
    switch method
      case 'svm' % support vector machine classifier
        y = svmclassify(SVM, transData);
%         y = svmpredict(randi(2)-1,transData,SVM);
%         [y,score] = predict(SVM,transData);
%         fprintf('%f\n',score)
        
      case {'rf', 'mrf', 'bf', 'lintree', 'svmtree', 'mtltree'} % tree based methods
        y = predict(Forest, transData);
        
      case 'nb' % naive Bayes
        y = classify(transData, trainingSet, trainingIndices, settings.bayes.type);
        
      case 'knn' % k-nearest neighbours
        y = knnclassify(transData, trainingSet, trainingIndices, ...
          settings.knn.k, settings.knn.distance, settings.knn.rule);
        
      case 'llc' % logistic linear classifier
        y = arrayfun(@(x) (LLC(1) + transData(x,:)*LLC(2:end)) < 0,1:size(transData,1));
        
      otherwise
        fprintf('Wrong method format!!!\n')
        return
    end
    
    if iscell(y)
      y = str2double(y{1});
    end
    if y == indices(sub)
      correctPredictions(sub) = 1;
    end
    class(sub) = y;
    
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
      fprintf('Starting dimension reduction by PCA...\n')
      nDim = defopts(settings.dimReduction,'nDim',Nsubjects-1); % maximum of chosen dimensions
      if nDim > Nsubjects-1
        nDim = Nsubjects-1;
      end
      
      [settings.dimReduction.transMatrix, transData] = pca(data);
      reducedData = transData(:,1:nDim);
      
      settings.transformPrediction = true;
      fprintf('Dimension reduced from %d to %d\n', dim, nDim)
      
    case 'kendall'
      % Kendall tau rank coefficient feature reduction
      % (according to Hui 2009)
      fprintf('Starting dimension reduction using Kendall tau rank coefficients...\n')
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
      
      fprintf('Dimension reduced from %d to %d\n', dim, size(reducedData,2))
      
    case 'ttest'
      % t-test feature reduction
      fprintf('Starting dimension reduction using t-test...\n')
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
      
      fprintf('Dimension reduced from %d to %d\n', dim, size(reducedData,2))
    
    case 'median'
      % feature reduction according to Honza Kalina's suggestion:
      %    Choose median value in each dimension, count how many
      %    individuals has greater or lower value
      fprintf('Starting dimension reduction using median difference coefficients...\n')
      nDim = defopts(settings.dimReduction, 'nDim', dim);    % maximum of chosen dimensions
      nOnes = sum(indices);
      nZeros = Nsubjects - nOnes;
      minDif = defopts(settings.dimReduction, 'minDif', 2*abs(nOnes-nZeros)); % minimum number of differences
      
      medData = median(data,1);
      greaterSub = data > repmat(medData,Nsubjects,1);
      greaterOnes = sum(greaterSub & repmat(indices',1,dim),1);
      greaterZeros = sum(greaterSub & repmat(~indices',1,dim),1);
      % count median difference coefficient
      nDif = abs(greaterOnes - greaterZeros) + abs(nOnes - nZeros - greaterOnes + greaterZeros);
      
      reducedData = data(:,nDif >= minDif);
      redDim = size(reducedData,2);
      
      if redDim == 0 % check if some data left
        warning(['Too severe constraints! Preventing emptyness of reduced',...
          'dataset by keeping one dimension with the greatest difference coefficient.'])
        [~, minId] = min(nDif);
        reducedData = data(:, minId(1));
      elseif redDim > nDim   % reduction by dimensions with the greatest difference coefficients
        [~, difId] = sort(nDif(nDif >= minDif),'descend');
        reducedData = reducedData(:,difId(1:nDim));
      end
      
      fprintf('Dimension reduced from %d to %d\n', dim, redDim)
      
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
