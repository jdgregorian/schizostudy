classdef LinearTree 
% Class for binary decision tree using linear manifolds as decision split
% boundaries.
    
  properties
    % Data properties
    features    % dimension of input space
    zerocount   % number of zero labels
    onescount   % number of ones labels
    traindata   % data used for tree training
    trainlabels % labels used for tree training

    % Tree properties
    Nodes     % # of nodes
    children  % children coordinates
    parent    % parent coordinates
    splitZero % 'zero' points determining the split boundary
    splitOne  % 'one' points determining the split boundary
    nodeData  % data assigned to the specific node
    nodeDistance % distance used in the specific node
    
    % User defined properties
    maxSplit  % upper bound of possible splits
    dist      % distance type
    inForest  % 1 - tree is a part of a forest, 0 - opposite
%     predictors % predictors in leaves
  end
    
methods
  function LT = LinearTree(data, labels, settings)
    
    % initialize
    if nargin < 3
      settings = [];
    end
    
    % user defined tree properties
    LT.maxSplit = defopts(settings,'maxSplit','all');
    LT.dist = defopts(settings,'distance',2);
    
    % learning data properties
    Nsubjects = length(labels);
    
    LT.features = size(data,2);
    LT.zerocount = sum(labels==0);
    LT.onescount = Nsubjects - LT.zerocount;
    LT.inForest = defopts(settings,'inForest',false);
    if LT.inForest                      % as a part of forest
      LT.traindata = settings.usedInd;  % remember only IDs of individuals
    else
      LT.traindata = data;
    end
    LT.trainlabels = labels;
    
    % tree properties
    LT.Nodes = 1;
    LT.parent = 0;
    LT.children = [0 0];
    LT.nodeData = ones(1,Nsubjects);
    LT.nodeDistance = {2};
    
    % data input check
    if size(data,1) ~= Nsubjects
      fprintf('Data length differs from labels length!');
      return
    end
    
    % prepairing for training cycle
    nPureLeaf = true; % leaves which are not pure or split nodes
    nNodes = 1; % number of nodes
    
    % maximum split setting
    if ischar(LT.maxSplit) && strcmp(LT.maxSplit,'all')
      maxSplitNum = Nsubjects;
    elseif isnumeric(LT.maxSplit)
      maxSplitNum = LT.maxSplit;
    else
      fprintf('Wrong maxSplit setting. Replacing by ''all''')
      LT.maxSplit = 'all';
      maxSplitNum = Nsubjects;
    end
      
    i = 0;
    % training cycle start
    while any(nPureLeaf) && i < maxSplitNum
      i = i+1; % just to be sure this ends
      
      % training drawing for 2D
      if LT.features == 2
        figure(i)
        scatter(data(~logical(labels),1),data(~logical(labels),2),'o','blue')
        hold on
        scatter(data(logical(labels),1),data(logical(labels),2),'s','green')
        for p = 1:Nsubjects
          text(data(p,1)+0.05,data(p,2),num2str(p),'FontSize',7)
        end
        xlim manual
        ylim manual
      end
      
      % prepare for counting and compute infomation gain
      leafInd = find(nPureLeaf);
      nToSplit = sum(nPureLeaf); % number of leaves possible to split
      if iscell(LT.dist)
        nDistances = length(LT.dist);
      else
        nDistances = 1;
      end
      I = zeros(nToSplit,nDistances);
      dataIndZ = cell(nToSplit,nDistances);
      dataIndO = cell(nToSplit,nDistances);
      actualDataInd = true(nToSplit,Nsubjects);
      % TODO: inicialization of dataSplit
      %       contraproductive counting of the same nodes
      for s = 1:nToSplit
        actualDataInd(s,:) = (LT.nodeData == leafInd(s));
        [I(s,:),dataIndZ(s,:),dataIndO(s,:),dataSplit(s,:)] = ...
          LinearTree.splitGain(data,actualDataInd(s,:),labels,LT.dist);
      end
      
      % split node with the maximum information gain
      [~,maxIid] = max(I(:));
      [maxNode, maxDist] = ind2sub(size(I),maxIid);
      
      LT.parent(end+1:end+2) = leafInd(maxNode);
      nNodes = nNodes + 2;
      LT.Nodes = nNodes;
      LT.children(leafInd(maxNode),:) = [nNodes-1 nNodes];
      LT.children(nNodes-1:nNodes,:) = zeros(2,2);
      
      if iscell(LT.dist)
        chosenDistance = LT.dist{maxDist};
      else
        chosenDistance = LT.dist;
      end
      LT.nodeDistance{leafInd(maxNode)} = chosenDistance;
      LT.nodeDistance(nNodes-1:nNodes) = {{},{}};      
      
      % fill new splits and prepare leaves for another iteration
      if isnumeric(chosenDistance)
        LT.splitZero{leafInd(maxNode)} = dataSplit(maxNode,maxDist).splitZero;
        LT.splitOne{leafInd(maxNode)} = dataSplit(maxNode,maxDist).splitOne;
      else
        LT.splitZero{leafInd(maxNode)} = dataSplit(maxNode,maxDist).zeroIndex;
        LT.splitOne{leafInd(maxNode)} = dataSplit(maxNode,maxDist).onesIndex;
      end
      
      changeIndZ = false(Nsubjects,1); % actualDataInd(maxNode,:);
      changeIndZ(dataIndZ{maxNode,maxDist}) = true;
      changeIndO = false(Nsubjects,1); % actualDataInd(maxNode,:);
      changeIndO(dataIndO{maxNode,maxDist}) = true;
      LT.nodeData(changeIndZ) = nNodes - 1;
      LT.nodeData(changeIndO) = nNodes;
      
      nPureLeaf(leafInd(maxNode)) = 0; % leaf became splitting node
      nPureLeaf(nNodes-1) = ~all(~labels(dataIndZ{maxNode,maxDist}));
      nPureLeaf(nNodes) = ~all(labels(dataIndO{maxNode,maxDist}));
      
      % training split drawing in 2D
      if LT.features == 2
        sZ = LT.splitZero{maxNode};
        sO = LT.splitOne{maxNode};
        scatter(sZ(1),sZ(2),'x','blue')
        scatter(sO(1),sO(2),'x','green')

        x(i,1) = min(data(actualDataInd(maxNode,:),1));
        x(i,2) = max(data(actualDataInd(maxNode,:),1));
        ybound(i,1) = ((sZ(1)-x(i,1))^2-(sO(1)-x(i,1))^2+sZ(2)^2-sO(2)^2)/(2*(sZ(2)-sO(2)));
        ybound(i,2) = ((sZ(1)-x(i,2))^2-(sO(1)-x(i,2))^2+sZ(2)^2-sO(2)^2)/(2*(sZ(2)-sO(2)));
        for l = 1:i
          plot(x(l,:),ybound(l,:),'r')
        end
        hold off
      end
    end
    fprintf('Nodes: %d\n',LT.Nodes)
    % training cycle end
  end    
    
  function y = predict(LT, data, originalData)
  % prediction function of linear tree for dataset data
  
    if nargin<3 
      if LT.inForest
        error('Tree with no entrance original data cannot be part of a forest!')
      end
      originalData = [];
    end
    
    nData = size(data,1);
    y = zeros(nData,1);
    dataNodeNum = ones(nData,1);
    
    splitNodes = find(LT.children(:,1));
    nSplitNodes = length(splitNodes);
    
    if LT.inForest
      trainingdata = originalData(LT.traindata,:);
    else
      trainingdata = LT.traindata;
    end
    
    for node = 1:nSplitNodes
      nodeDataId = (splitNodes(node) == dataNodeNum);
      if any(nodeDataId) % are there any data for prediction?
        nodeDataPred = data(nodeDataId,:);
        nNodeData = sum(nodeDataId);
        tempDataNum = zeros(nNodeData,1);
        if iscell(LT.dist)
          currentDistance = LT.nodeDistance{splitNodes(node)};
        else
          currentDistance = LT.dist;
        end
        if isnumeric(currentDistance)
          zeroDist = LinearTree.pdistance(nodeDataPred,LT.splitZero{splitNodes(node)},currentDistance);
          oneDist = LinearTree.pdistance(nodeDataPred,LT.splitOne{splitNodes(node)},currentDistance);
        else
          zeroID = LT.splitZero{splitNodes(node)};
          onesID = LT.splitOne{splitNodes(node)};
          zeroDist = LinearTree.mahalanobis(nodeDataPred,trainingdata(zeroID,:));
          oneDist = LinearTree.mahalanobis(nodeDataPred,trainingdata(onesID,:));
        end
        tempDataNum(zeroDist<oneDist) = LT.children(splitNodes(node),1);
        tempDataNum(zeroDist>=oneDist) = LT.children(splitNodes(node),2);
        dataNodeNum(nodeDataId) = tempDataNum;
      end
    end
    
    % if the node number is one, prediction equals one
    y(logical(mod(dataNodeNum,2))) = 1;
    
  end
    
end

methods (Static)
  
  function [I,dataIndZ,dataIndO,S] = splitGain(data,index,labels,distance)
  % splitGain returns information value I of the split determined with 
  % points splitZero and splitOne. Furthermore, it returns apropriate 
  % indices of data: dataIndZ and dataIndO
  
    actualData = data(index,:);
    dataID = find(index);
    
    % class division
    zeroIndex = ~logical(labels) & index;
    onesIndex = logical(labels) & index;
    A = data(zeroIndex,:);
    B = data(onesIndex,:);
    
    if ~iscell(distance)
      distance = {distance};
    end
    
    nDistances = length(distance);
    for d = 1:nDistances % count each distance
      dis = distance{d};
    
      if strcmp(dis,'mahal')

        % count indexes
        zeroDist = LinearTree.mahalanobis(actualData,A);
        oneDist = LinearTree.mahalanobis(actualData,B);

        S(1,d).zeroIndex = zeroIndex;
        S(1,d).onesIndex = onesIndex;

      else

        % count mean
        S(1,d).splitZero = mean(A,1);
        S(1,d).splitOne = mean(B,1);

        % count indexes
        zeroDist = LinearTree.pdistance(actualData,S(1,d).splitZero,dis);
        oneDist = LinearTree.pdistance(actualData,S(1,d).splitOne,dis);

      end

      dataIndZ{:,d} = dataID(zeroDist<oneDist);
      dataIndO{:,d} = dataID(zeroDist>=oneDist); 

      % count information gain
      I(1,d) = LinearTree.infoGainSet(dataIndZ{:,d},dataIndO{:,d},labels);
      
    end
      
  end

  function I = infoGainSet(dataIndZ,dataIndO,labels)
  % dataIndZ - 'zero' set of data
  % dataIndO - 'one' set of data
  % labels   - labels of data [dataIndZ,dataIndO]
      
    NallZ = length(dataIndZ); % # of points to the 'zero' child
    NallO = length(dataIndO); % # of points to the 'one' child
    Ndata = NallZ + NallO;
    
    NzeroZ = sum(~labels(dataIndZ)); % # of zero points in 'zero' child (correct)
    NzeroO = NallZ - NzeroZ;         % # of one points in 'zero' child (incorrect)
    
    NoneZ = sum(~labels(dataIndO)); % # of zero points in 'one' child (incorrect)
    NoneO = NallO - NoneZ;         % # of one points in 'one' child (correct)
    
    pFull = [sum(~labels([dataIndZ,dataIndO]))/Ndata, sum(labels([dataIndZ,dataIndO]))/Ndata];
    pLeft = [NzeroZ./NallZ, NzeroO./NallZ]; % zero goes to the left child
    pRight = [NoneZ./NallO, NoneO./NallO];  % one goes to the right child
        
    I = LinearTree.shannonEntropy(pFull) - NallZ./Ndata.*LinearTree.shannonEntropy(pLeft)...
        - NallO./Ndata.*LinearTree.shannonEntropy(pRight);
  end
  
  function H = shannonEntropy(p)
  % p is matrix of probabilities
    H = - sum(p.*log(p),2);
    H(isnan(H)) = 0;
  end
  
  function D = mahalanobis(A,X)
  % count mahalanobis distance between the set of points A and the 
  % reference set X
  
    alpha = 0.001; % regularization coefficient
    
    ra = size(A,1);
    cx = size(X,2);
    
    Am = A - repmat(mean(X,1),ra,1);
    C = cov(X) + alpha*diag(ones(cx,1)); % regularization
    D = C\Am';            % too much computation
    D = sqrt(diag(Am*D)); % too much computation
    
    % adjusted code from mahal.m function
    
%     [rx,cx] = size(X);
%     [ra,~] = size(A);
% 
%     m = mean(X,1);
%     M = m(ones(ra,1),:);
%     C = X - m(ones(rx,1),:);
%     
%     R = chol(C'*C + alpha*diag(ones(cx,1))); % regularization
%     
%     ri = R'\(A-M)';
%     D = sum(ri.*ri,1)'*(rx-1);
    
  end
  
  function D = pdistance(A,b,type)
  % count distance between the set of points and one point using p-norm
  
    if nargin == 2
      type = 2;
    end
    
    ra = size(A,1);
    
    D = arrayfun(@(id) norm(A(id,:)-b,type), 1:ra);
  end
  
end

end
