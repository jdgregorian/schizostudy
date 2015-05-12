classdef LinearTree 
% class for binary decision tree using linear boundaries
% NOT FINISHED
    
  properties
    % Data properties
    features  % dimension of input space
    zerocount % number of zero labels
    onescount % number of ones labels
    traindata % data used for tree training

    % Tree properties
    Nodes     % # of nodes
    children  % children coordinates
    parent    % parent coordinates
    splitZero % 'zero' points determining the split boundary
    splitOne  % 'one' points determining the split boundary
    nodeData  % data assigned to the specific node
    maxSplit  % upper bound of possible splits
%       predictors % predictors in leaves
  end
    
methods
  function ST = LinearTree(data, labels)   
    
    
    Nsubjects = length(labels);
    
    ST.features = size(data,2);
    ST.zerocount = sum(labels==0);
    ST.onescount = Nsubjects - ST.zerocount;
    ST.traindata = data;
    
    ST.Nodes = 1;
    ST.parent = 0;
    ST.children = [0 0];
    ST.splitZero = NaN(1,ST.features);
    ST.splitOne = NaN(1,ST.features);
    ST.nodeData = ones(1,Nsubjects);
    ST.maxSplit = 25;
    
    if size(data,1) ~= Nsubjects
      fprintf('Data length differs from labels length!');
      return
    end
    
    nPureLeaf = true; % leaves which are not pure or split nodes
    nNodes = 1; % number of nodes
    i = 0;
    % training cycle start
    while any(nPureLeaf) && i < ST.maxSplit
      i = i+1; % just to be sure this ends
      
      % training drawing for 2D
      if ST.features == 2
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
      
      leafInd = find(nPureLeaf);
      nToSplit = sum(nPureLeaf); % number of leaves possible to split
      I = zeros(1,nToSplit);
      splitZ = NaN(nToSplit,ST.features);
      splitO = NaN(nToSplit,ST.features);
      dataIndZ = cell(nToSplit,1);
      dataIndO = cell(nToSplit,1);
      actualDataInd = true(nToSplit,Nsubjects);
      for s = 1:nToSplit
        actualDataInd(s,:) = (ST.nodeData == leafInd(s));
        [I(s),splitZ(s,:),splitO(s,:),dataIndZ{s},dataIndO{s}] = ...
          LinearTree.splitGain(data,actualDataInd(s,:),labels);
      end
      
      % split node with the maximum information gain
      [~,maxInd] = max(I);
      
      ST.parent(end+1:end+2) = leafInd(maxInd);
      nNodes = nNodes + 2;
      ST.Nodes = nNodes;
      ST.children(leafInd(maxInd),:) = [nNodes-1 nNodes];
      ST.children(nNodes-1:nNodes,:) = zeros(2,2);
      
      ST.splitZero(leafInd(maxInd),:) = splitZ(maxInd,:);
      ST.splitOne(leafInd(maxInd),:) = splitO(maxInd,:);
      ST.splitZero(nNodes-1:nNodes,:) = NaN(2,ST.features);
      ST.splitOne(nNodes-1:nNodes,:) = NaN(2,ST.features);
      
      changeIndZ = false(Nsubjects,1); % actualDataInd(maxInd,:);
      changeIndZ(dataIndZ{maxInd}) = true;
      changeIndO = false(Nsubjects,1); % actualDataInd(maxInd,:);
      changeIndO(dataIndO{maxInd}) = true;
      ST.nodeData(changeIndZ) = nNodes - 1;
      ST.nodeData(changeIndO) = nNodes;
      
      nPureLeaf(leafInd(maxInd)) = 0; % leaf became splitting node
      nPureLeaf(nNodes-1) = ~all(~labels(dataIndZ{maxInd}));
      nPureLeaf(nNodes) = ~all(labels(dataIndO{maxInd}));
      
      % training split drawing in 2D
      if ST.features == 2
        sZ = splitZ(maxInd,:);
        sO = splitO(maxInd,:);
        scatter(sZ(1),sZ(2),'x','blue')
        scatter(sO(1),sO(2),'x','green')

        x(i,1) = min(data(actualDataInd(maxInd,:),1));
        x(i,2) = max(data(actualDataInd(maxInd,:),1));
        ybound(i,1) = ((sZ(1)-x(i,1))^2-(sO(1)-x(i,1))^2+sZ(2)^2-sO(2)^2)/(2*(sZ(2)-sO(2)));
        ybound(i,2) = ((sZ(1)-x(i,2))^2-(sO(1)-x(i,2))^2+sZ(2)^2-sO(2)^2)/(2*(sZ(2)-sO(2)));
        for l = 1:i
          plot(x(l,:),ybound(l,:),'r')
        end
        hold off
      end
    end
    % training cycle end
  end    
    
  function y = predict(ST, data)
    nData = size(data,1);
    y = zeros(nData,1);
    dataNodeNum = ones(nData,1);
    
    splitNodes = find(ST.children(:,1));
    nSplitNodes = length(splitNodes);
    
    
    for node = 1:nSplitNodes
      nodeDataId = (splitNodes(node) == dataNodeNum);
      if any(nodeDataId) % are there any data for prediction?
        nodeDataPred = data(nodeDataId,:);
        nNodeData = sum(nodeDataId);
        tempDataNum = zeros(nNodeData,1);
        zeroDist = LinearTree.distance(repmat(ST.splitZero(splitNodes(node),:),nNodeData,1),nodeDataPred);
        oneDist = LinearTree.distance(repmat(ST.splitOne(splitNodes(node),:),nNodeData,1),nodeDataPred);
        tempDataNum(zeroDist<oneDist) = ST.children(splitNodes(node),1);
        tempDataNum(zeroDist>=oneDist) = ST.children(splitNodes(node),2);
        dataNodeNum(nodeDataId) = tempDataNum;
      end
    end
    
    % if the node number is one, prediction equals one
    y(logical(mod(dataNodeNum,2))) = 1;
    
  end
    
end

methods (Static)
  
  function [I,splitZero,splitOne,dataIndZ,dataIndO] = splitGain(data,index,labels)
  % splitGain returns information value I of the split determined with 
  % points splitZero and splitOne. Furthermore, it returns apropriate 
  % indices of data: dataIndZ and dataIndO
  
    actualData = data(index,:);
    nData = size(actualData,1);
    dataID = find(index);
    
    % class division
    A = data(~logical(labels) & index,:);
    B = data(logical(labels) & index,:);
    
    % count mean
    splitZero = mean(A,1);
    splitOne = mean(B,1);
    
    % count indexes
    zeroDist = LinearTree.distance(actualData,repmat(splitZero,nData,1));
    oneDist = LinearTree.distance(actualData,repmat(splitOne,nData,1));
    dataIndZ = dataID(zeroDist<oneDist);
    dataIndO = dataID(zeroDist>=oneDist); 
    
    % count information gain
    I = LinearTree.infoGainSet(dataIndZ,dataIndO,labels);
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
  
  function D = distance(a,b)
  % count distance between two points or two sets of points
    D = sqrt(sum((a-b).^2,2)); 
  end
  
end

end
