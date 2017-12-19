classdef RandomForest 
% Random Decision Forest of user chosen trees (stump, linear)
% settings - structure of appropriate tree and forest settings
    
  properties
    Trees          % cell array of trees
    nvars          % # of features
    NTrees         % number of trees
    performances   % array of performances
    perfType       % type of performance of predictors to weight prediction
    FBoot          % fraction of input data used to training
    TreeType       % type of the tree (stump, linear, matlab, svm)
    trainingData   % data used for forest training
    trainingLabels % labels used for forest training
    learning       % learning algorithm (bagging, boosting)
    treeWeights    % weights of individual trees
  end
    
methods
  function RF = RandomForest(data, labels, NTrees, settings)     

    % initialize
    RF.NTrees = 0;
    RF.nvars=size(data,2);
    if nargin < 4
      if nargin < 3
        NTrees = 11;
      end
      settings.nTrees = NTrees;
    end
    RF.FBoot = defopts(settings, 'FBoot', 1);
    RF.TreeType = defopts(settings, 'TreeType', 'linear');
    RF.learning = defopts(settings, 'learning', 'bagging');
    RF.perfType = defopts(settings, 'perfType', 'alldata');
    RF.trainingData = data;
    RF.trainingLabels = labels;
    RF.treeWeights = zeros(1, settings.nTrees);
    
    datacount = size(data,1);
    Ndatause = ceil(RF.FBoot*datacount);
    settings.weights = ones(Ndatause, 1) / Ndatause;
    switch RF.learning
      case 'adaboost'
        useInd = 1:datacount;
        % This variable will contain the results of the single weak
        % classifiers weight by their alpha
        estimateclasssum = zeros(size(labels));
      case 'boosting'
        useInd = 1:datacount;
        weightBase = ones(1, Ndatause);
    end
        
    if strcmpi(RF.TreeType, 'matlab')
      cellset = cellSettings(settings, {'FBoot', 'TreeType', 'learning' ,'perfType'});
    end

    % tree learning sequence
    for T = 1:NTrees
      % choose training data according to learning algorithm type
      switch RF.learning
        case {'bag', 'bagging'} % bagging
          useInd = randi(Ndatause, 1, Ndatause);

        case {'adaboost', 'boosting'} % boosting
          % boosting will be changed according to different boosting strategies
        otherwise
          warning('Wrong learning algorithm name! Switching to bagging...')
          RF.learning = 'bagging';
          useInd = randi(Ndatause,1,Ndatause);
      end
      datause = data(useInd,:);
      labeluse = labels(useInd);
      
      % tree training
      switch RF.TreeType
        case 'stump'
          Tree = StumpTree(datause,labeluse);
          Tree.maxSplit = 1;
        case 'matlab'
            % be careful, tree has different settings according to version
            % (older versions may not accept new settings)
            if verLessThan('matlab','8.3') 
              Tree = ClassificationTree.fit(datause, labeluse, cellset{:});
            else
              Tree = fitctree(data(useInd,:), labels, cellset{:});
            end
        case 'linear'
          settings.inForest = true;
          settings.usedInd = useInd;
          Tree = LinearTree(datause,labeluse,settings);
        case 'svm'
          settings.inForest = true;
          settings.usedInd = useInd;
          Tree = SVMTree(datause,labeluse,settings);
        otherwise
          fprintf('Wrong tree format!!!')
          RF.Trees = {};
          RF.performances = [];
          return
      end
      
      RF.Trees{T} = Tree;
      RF.NTrees = RF.NTrees + 1;

      % tree performance counting
      switch RF.perfType
        case {'treedata','treedataNP'} % performance on tree training data
          perfData = datause;
          perfLabels = labeluse;
        case {'all','alldata', 'allNP'} % performance on forest training data
          perfData = data;
          perfLabels = labels;
        otherwise
          perfData = [];
      end
      
      if ~isempty(perfData)
        if any(strcmpi(RF.TreeType,{'svm','matlab'}))
          pred = Tree.predict(perfData);
        else
          pred = Tree.predict(perfData, datause);
        end
        y = round(double(pred));
        correctPred = (y' == perfLabels);
        switch RF.learning
          case 'adaboost'
            err = sum( settings.weights.*(~correctPred') )/sum(settings.weights);
            % Weak classifier influence on total result is based on the 
            % current classification error
            alpha = 1/2 * log((1-err)/max(err, eps));
            % We update weights so that wrongly classified samples will 
            % have more weight
            settings.weights = settings.weights.* exp(alpha.* (~correctPred'));
            settings.weights = settings.weights./sum(settings.weights);
            % Calculate the current error of the cascade of weak
            % classifiers
            y(y == 0) = -1;
            estimateclasssum = estimateclasssum + y'*alpha;
            % prediction > 0.5 ? and scale back to [0,1]
            estimateclasstotal = (sign(estimateclasssum) + 1) / 2; 
            RF.performances(T) = sum(estimateclasstotal == labels)/length(labels);
            RF.treeWeights(T) = alpha;
            if(RF.performances(T) == 1)
              break;
            end
          case 'boosting'
            % TODO: will be changed according to different boosting strategies by using weights
            weightBase = weightBase + (~correctPred);
            settings.weights = weightBase/sum(weightBase);
            RF.performances(T) = sum((correctPred))/length(perfLabels);
            RF.treeWeights(T) = RF.performances(T);
          otherwise
            RF.performances(T) = sum((correctPred))/length(perfLabels);
            RF.treeWeights(T) = RF.performances(T);
        end     
      else
        RF.performances(T) = 1;
      end
    end
  end    
    
  function [y,Y] = predict(RF, data)
  % prediction function for random forest
    nSubj = size(data, 1);
    Y = zeros(nSubj, RF.NTrees);
    
    if any(strcmpi(RF.TreeType,{'svm','matlab'}))
      for i = 1:RF.NTrees
        Y(:,i) = RF.Trees{i}.predict(data);
      end
    else      
      for i = 1:RF.NTrees
        Y(:,i) = RF.Trees{i}.predict(data, RF.trainingData);
      end
    end
      
    if any(strcmpi(RF.perfType, {'allNP','treedataNP'}))
      perf = ones(1,RF.NTrees);
    else
      perf = RF.treeWeights(1:RF.NTrees);
    end
    
    y = sum(Y.*repmat(perf, nSubj, 1), 2)/sum(perf); % weighted prediction
    fprintf('%f\n', y);
    
    y = round(y); % > 0.5 ?
  end  
    
end

end
