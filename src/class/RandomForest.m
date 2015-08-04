classdef RandomForest 
% Random Decision Forest of user chosen trees (stump, linear)
% settings - structure of appropriate tree and forest settings
    
  properties
    Trees          % cell array of trees
    nvars          % # of features
    NTrees         % number of trees
    performances   % array of performances
    FBoot          % fraction of input data used to training
    TreeType       % type of the tree (stump, linear)
    trainingData   % data used for forest training
    trainingLabels % labels used for forest training
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
    RF.FBoot = defopts(settings,'FBoot',1);
    RF.TreeType = defopts(settings,'TreeType','linear');
    RF.trainingData = data;
    RF.trainingLabels = labels;
    
    datacount = size(data,1);
    datause = ceil(RF.FBoot*datacount);

    % tree learning sequence
    for T = 1:NTrees
      % bootstrap
      useInd = randi(datause,1,datause);
      labeluse = labels(useInd);
      switch RF.TreeType
        case 'stump'
          Tree = StumpTree(data(useInd,:),labeluse);
          Tree.maxSplit = 1;
        case 'linear'
          settings.inForest = true;
          settings.usedInd = useInd;
          Tree = LinearTree(data(useInd,:),labeluse,settings);
        case 'svm'
          Tree = svmtrain(data(useInd,:),labeluse);
          Tree.maxSplit = 1;
        otherwise
          fprintf('Wrong tree format!!!')
          RF.Trees = {};
          RF.performances = [];
          return
      end
      
      RF.Trees{T} = Tree;
      RF.NTrees = RF.NTrees + 1;
      
      % old tree performance counting
%       if strcmp(Tree.maxSplit,'all') % not necessary when performing all splits
%         RF.performances(T) = 1;
%       else
%         y = Tree.predict(data(useInd,:),data);
%         RF.performances(T) = sum((y'==labeluse))/length(labeluse);
%       end

      % tree performance counting
      if strcmpi(RF.TreeType,'svm')
        y = svmclassify(Tree,data);
      else
        y = round(Tree.predict(data,data));
      end
      RF.performances(T) = sum((y'==labeluse))/length(labeluse);
    end
  end    
    
  function [y,Y] = predict(RF, data)
  % prediction function for random forest
    nSubj = size(data,1);
    Y = zeros(nSubj,RF.NTrees);
    if strcmpi(RF.TreeType,'svm')
      for i = 1:RF.NTrees
        Y(:,i) = svmclassify(RF.Trees{i},data);
      end
    else
      for i = 1:RF.NTrees
        Y(:,i) = RF.Trees{i}.predict(data,RF.trainingData);
      end
    end
    perf = RF.performances;
    y = sum(Y.*repmat(perf,nSubj,1),2)/sum(perf);
    fprintf('%f\n',y);
    
    % confidence loop
%     i = 1;
%     while abs(y-0.5)<0.1 
%       ind = true(1,ST.NTrees);
%       ind(randi(ST.NTrees,1,i)) = false;
%       y = sum(Y(:,ind).*perf(ind),2)/sum(perf(ind));
%       fprintf('%f\n',y);
%       i = i+1;
%     end
    
    y = round(y); %>0.5;
  end  
    
end

end
