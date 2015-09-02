classdef SVMTree 
% Class for binary decision tree using linear manifolds learnt through SVM 
% as decision split boundaries.
    
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
    nodeSVM   % SVM in node
    predictor % predictors in leaves
    
    % User defined properties
    maxSplit    % upper bound of possible splits
    dist        % distance type
    inForest    % 1 - tree is a part of a forest, 0 - opposite
    probability % probability prediction mode
  end
    
methods
  function SVMT = SVMTree(data, labels, settings)
    
    % initialize
    if nargin < 3
      settings = [];
    end
    
    % user defined tree properties
    SVMT.maxSplit = defopts(settings,'maxSplit','all');
%     SVMT.dist = defopts(settings,'distance',2);
    SVMT.probability = defopts(settings,'probability',false);
    
    % learning data properties
    Nsubjects = length(labels);
    
    SVMT.features = size(data,2);
    SVMT.zerocount = sum(labels==0);
    SVMT.onescount = Nsubjects - SVMT.zerocount;
    SVMT.inForest = defopts(settings,'inForest',false);
    if SVMT.inForest                      % as a part of forest
      SVMT.traindata = settings.usedInd;  % remember only IDs of individuals
    else
      SVMT.traindata = data;
    end
    SVMT.trainlabels = labels;
    
    % tree properties
    SVMT.Nodes = 1;
    SVMT.parent = 0;
    SVMT.children = [0 0];
    SVMT.nodeData = ones(1,Nsubjects);
    if SVMT.probability
      SVMT.predictor = SVMT.onescount/Nsubjects;
    else
      SVMT.predictor = sum(labels) > sum(~labels);
    end
    SVMT.nodeSVM = {};
    
    % data input check
    if size(data,1) ~= Nsubjects
      fprintf('Data length differs from labels length!');
      return
    end
    
    % prepairing for training cycle
    nPureLeaf = true; % leaves which are not pure or split nodes
    nNodes = 1; % number of nodes
    
    % maximum split setting
    if ischar(SVMT.maxSplit) && strcmp(SVMT.maxSplit,'all')
      maxSplitNum = Nsubjects;
    elseif isnumeric(SVMT.maxSplit)
      maxSplitNum = SVMT.maxSplit;
    else
      fprintf('Wrong maxSplit setting. Replacing by ''all''')
      SVMT.maxSplit = 'all';
      maxSplitNum = Nsubjects;
    end
      
    % gain number of SVM settings to train
    nDistances = 1;
    
    % inicialize variables used to store splitGain results
    allI = zeros(maxSplitNum,nDistances);
    allDataIndZ = cell(maxSplitNum,nDistances);
    allDataIndO = cell(maxSplitNum,nDistances);
    actualDataInd = true(maxSplitNum,Nsubjects);
    
    i = 0;
    % training cycle start
    while any(nPureLeaf) && i < maxSplitNum
      i = i+1; % just to be sure this ends
      
      % prepare for counting and compute infomation gain
      leafInd = find(nPureLeaf);

      % TODO: inicialization of allDataSplit
      if i==1
        idToCompute = 1;
      else
        lastTwoNodes = [false(1,nNodes-2), true(1,2)];
        idToCompute = find(nPureLeaf & lastTwoNodes);
      end
      
      for s = idToCompute
        actualDataInd(s,:) = (SVMT.nodeData == s);
        [allI(s,:),allDataIndZ(s,:),allDataIndO(s,:),allSVM(s,:)] = ...
          SVMTree.splitGain(data,actualDataInd(s,:),labels);
        % check emptiness of child nodes
        if allI(s,:) == 0 && (isempty(allDataIndZ{s,1}) || isempty(allDataIndO{s,1}))
          % split cannot be done because one child would be empty
          nPureLeaf(s) = 0; % stay as leaf and do not split
        end
      end
      
      % use only nodes possible to split
      I = allI(nPureLeaf,:);
      
      if ~isempty(I) % some nodes to split left
        dataIndZ = allDataIndZ(nPureLeaf,:);
        dataIndO = allDataIndO(nPureLeaf,:);
        SVM = allSVM(nPureLeaf,:);
%         dataSplit = allDataSplit(nPureLeaf,:);

        % split node with the maximum information gain
        [~,maxIid] = max(I(:));
        [maxNode, maxSet] = ind2sub(size(I),maxIid);

        % check emptiness of child nodes
        SVMT.parent(end+1:end+2) = leafInd(maxNode);
        nNodes = nNodes + 2;
        SVMT.Nodes = nNodes;
        SVMT.children(leafInd(maxNode),:) = [nNodes-1 nNodes];
        SVMT.children(nNodes-1:nNodes,:) = zeros(2,2);
        
        % save chosen SVM
        SVMT.nodeSVM{leafInd(maxNode)} = SVM(maxNode,maxSet);
        
        % split data
        chosenDataZ = dataIndZ{maxNode,maxSet};
        chosenDataO = dataIndO{maxNode,maxSet};
        
        % mark data in correspondance with nodes
        changeIndZ = false(Nsubjects,1);
        changeIndZ(chosenDataZ) = true;
        changeIndO = false(Nsubjects,1);
        changeIndO(chosenDataO) = true;
        SVMT.nodeData(changeIndZ) = nNodes - 1;
        SVMT.nodeData(changeIndO) = nNodes;

        nPureLeaf(leafInd(maxNode)) = 0; % leaf became splitting node
        nPureLeaf(nNodes-1) = ~all(labels(chosenDataZ)==labels(chosenDataZ(1)));
        nPureLeaf(nNodes) = ~all(labels(chosenDataO)==labels(chosenDataO(1)));
        
        % probability prediction
        if SVMT.probability 
          SVMT.predictor(nNodes-1,1) = sum(labels(chosenDataZ))/length(chosenDataZ);
          SVMT.predictor(nNodes,1) = sum(labels(chosenDataO))/length(chosenDataO);
        else
          SVMT.predictor(nNodes-1,1) = sum(labels(chosenDataZ)) > sum(~labels(chosenDataZ));
          SVMT.predictor(nNodes,1) = sum(labels(chosenDataO)) >= sum(~labels(chosenDataO));
        end
        
      end % nonempty split end
    end % training cycle end
    fprintf('Nodes: %d\n',nNodes)
    
  end    
    
  function y = predict(SVMT, data)
  % prediction function of SVM tree for dataset data
  
    nData = size(data,1);
    y1 = zeros(nData,1);
    dataNodeNum = ones(nData,1);
    
    splitNodes = find(SVMT.children(:,1));
    nSplitNodes = length(splitNodes);
        
    for node = 1:nSplitNodes
      nodeDataId = (splitNodes(node) == dataNodeNum);
      if any(nodeDataId) % are there any data for prediction?
        nodeDataPred = data(nodeDataId,:);
        nNodeData = sum(nodeDataId);
        tempDataNum = zeros(nNodeData,1);
        tempY = logical(svmclassify(SVMT.nodeSVM{splitNodes(node)},nodeDataPred));
%         tempY = logical(predict(SVMT.nodeSVM{splitNodes(node)},nodeDataPred));
        tempDataNum(~tempY) = SVMT.children(splitNodes(node),1);
        tempDataNum(tempY) = SVMT.children(splitNodes(node),2);
        dataNodeNum(nodeDataId) = tempDataNum;
      end
    end
    
    % if the node number is one, prediction equals one
    y1(logical(mod(dataNodeNum,2))) = 1;
    y = SVMT.predictor(dataNodeNum);
    if ~SVMT.probability && any(y1 ~= y)
      fprintf('Classification differs from previous prediction style.\n')
    end
    
  end
    
end

methods (Static)
  
  function [I,dataIndZ,dataIndO,SVM] = splitGain(data,index,labels,svmSettings)
  % splitGain returns information value I of the split determined with 
  % points splitZero and splitOne. Furthermore, it returns apropriate 
  % indices of data: dataIndZ and dataIndO
    
    if nargin == 3
      svmSettings = {};
    end
    
    actualData = data(index,:);
    actualLabels = labels(index);
    dataID = find(index);
    
    % class division
    zeroIndex = ~logical(labels) & index;
    onesIndex = logical(labels) & index;
    A = data(zeroIndex,:);
    B = data(onesIndex,:);
    
    if ~iscell(svmSettings)
      svmSettings = {svmSettings};
    end
    nSettings = 1; % length(svmSettings);
    
    % in case of emptyness do not compute
    if isempty(A) || isempty(B)
      fprintf('One branch is empty\n')
      I = zeros(1,nSettings);
      dataIndZ = cell(1,nSettings);
      dataIndO = cell(1,nSettings);
      for d = 1:nSettings
        SVM(1,d) = [];
        SVM(1,d) = [];
      end
      return
    end
    
    for d = 1:nSettings % count for each settings
      SVM = svmtrain(actualData,actualLabels,svmSettings{:});
%         SVM = fitcsvm(actualData,actualLabels,svmSettings{:});
      y = logical(svmclassify(SVM,actualData));
      
      dataIndZ{:,d} = dataID(~y);
      dataIndO{:,d} = dataID(y); 

      % count information gain
      I(1,d) = SVMTree.infoGainSet(dataIndZ{:,d},dataIndO{:,d},labels);
      
    end
      
  end

  function I = infoGainSet(dataIndZ,dataIndO,labels)
  % Function counts information gain of split of two sets of points
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
        
    I = SVMTree.shannonEntropy(pFull) - NallZ./Ndata.*SVMTree.shannonEntropy(pLeft)...
        - NallO./Ndata.*SVMTree.shannonEntropy(pRight);
  end
  
  function H = shannonEntropy(p)
  % p is matrix of probabilities
    H = - sum(p.*log(p),2);
    H(isnan(H)) = 0;
  end
  
  function D = mahalanobis(A,X)
  % Counts mahalanobis distance between the set of points A and the 
  % reference set X
  
    alpha = 0.001; % regularization coefficient
    
    ra = size(A,1);
    cx = size(X,2);
    
    Am = A - repmat(mean(X,1),ra,1);
    C = cov(X) + alpha*diag(ones(cx,1)); % regularization
    D = C\Am';            % too much computation
    D = diag(Am*D); % too much computation
    
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
