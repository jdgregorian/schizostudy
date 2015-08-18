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
    TreeType       % type of the tree (stump, linear)
    trainingData   % data used for forest training
    trainingLabels % labels used for forest training
    learning       % learning algorithm
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
    RF.perfType = defopts(settings, 'perfType', 'treedata');
    RF.trainingData = data;
    RF.trainingLabels = labels;
    
    datacount = size(data,1);
    Ndatause = ceil(RF.FBoot*datacount);

    % tree learning sequence
    for T = 1:NTrees
      % learning algorithm type
      switch RF.learning
        case {'bag','bagging'} % bagging
          useInd = randi(Ndatause, 1, Ndatause);
          datause = data(useInd,:);
          labeluse = labels(useInd);
        otherwise
          warning('Wrong learning algorithm name! Switching to bagging...')
          RF.learning = 'bagging';
          useInd = randi(Ndatause,1,Ndatause);
          datause = data(useInd,:);
          labeluse = labels(useInd);
      end
      
      % tree training
      switch RF.TreeType
        case 'stump'
          Tree = StumpTree(datause,labeluse);
          Tree.maxSplit = 1;
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
        case 'treedata'
          perfData = datause;
          perfLabels = labeluse;
        case {'all','alldata'}
          perfData = data;
          perfLabels = labels;
        otherwise
          perfData = [];
      end
      
      if ~isempty(perfData)
        if strcmpi(RF.TreeType,'svm')
          pred = Tree.predict(perfData);
        else
          pred = Tree.predict(perfData, datause);
        end
        y = round(double(pred));
        RF.performances(T) = sum((y'==perfLabels))/length(perfLabels);
      else
        RF.performances(T) = 1;
      end
    end
  end    
    
  function [y,Y] = predict(RF, data)
  % prediction function for random forest
    nSubj = size(data, 1);
    Y = zeros(nSubj, RF.NTrees);
    
    if strcmpi(RF.TreeType,'svm')
      for i = 1:RF.NTrees
        Y(:,i) = RF.Trees{i}.predict(data);
      end
    else      
      for i = 1:RF.NTrees
        Y(:,i) = RF.Trees{i}.predict(data, RF.trainingData);
      end
    end
      
    perf = RF.performances;
    y = sum(Y.*repmat(perf, nSubj, 1), 2)/sum(perf); % weighted prediction
    fprintf('%f\n', y);
    
    y = round(y); %>0.5;
  end  
    
end

end
