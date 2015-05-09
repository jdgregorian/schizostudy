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
    children  % children coordinates
    parent    % parent coordinates
    splitZero % 'zero' points determining the split boundary
    splitOne  % 'one' points determining the split boundary
    nodeData  % data assigned to the specific node
%       predictors % predictors in leaves
  end
    
methods
  function ST = LinearTree(data, labels)   
    
    
    Nsubjects = length(labels);
    
    ST.features = size(data,2);
    ST.zerocount = sum(labels==0);
    ST.onescount = Nsubjects - ST.zerocount;
    ST.traindata = data;
    
    ST.children = [0 0];
    ST.parent = 0;
    ST.splitZero = NaN(1,ST.features);
    ST.splitOne = NaN(1,ST.features);
    ST.nodeData = ones(1,Nsubjects);
    
    if size(data,1) ~= Nsubjects
      fprintf('Data length differs from labels length!');
      return
    end
     
    nPureLeaf = true; % leaves which are not pure or split nodes
    i = 0;
    while any(nPureLeaf) && i < 10
      i = i+1; % just to be sure this ends
      
      leafInd = find(nPureLeaf);
      nToSplit = sum(nPureLeaf); % number of leaves possible to split
      I = zeros(1,nToSplit);
      splitZ = NaN(nToSplit,ST.features);
      splitO = NaN(nToSplit,ST.features);
      dataIndZ = {};
      dataIndO = {};
      for s = 1:nToSplit
        actualDataInd(s,:) = (ST.nodeData == leafInd(s));
        [I(s),splitZ(s,:),splitO(s,:),dataIndZ{s},dataIndO{s}] = ...
          LinearTree.splitGain(data(actualDataInd(s,:),:),actualDataInd(s,:),labels);
      end
      
      % split node with the maximum information gain
      [~,maxInd] = max(I);
      
      ST.parent(end+1:end+2) = leafInd(maxInd);
      nNodes = length(ST.parent);
      ST.children(leafInd(maxInd),:) = [nNodes-1 nNodes];
      ST.children(nNodes-1:nNodes,:) = zeros(2,2);
      
      ST.splitZero(leafInd(maxInd),:) = splitZ(maxInd,:);
      ST.splitOne(leafInd(maxInd),:) = splitO(maxInd,:);
      ST.splitZero(nNodes-1:nNodes,:) = NaN(2,ST.features);
      ST.splitOne(nNodes-1:nNodes,:) = NaN(2,ST.features);
      
      changeIndZ = actualDataInd(maxInd,:);
      changeIndZ(dataIndZ{maxInd}) = false;
      changeIndO = actualDataInd(maxInd,:);
      changeIndO(dataIndO{maxInd}) = false;
      ST.nodeData(changeIndZ) = nNodes - 1;
      ST.nodeData(changeIndO) = nNodes;
      
      nPureLeaf(maxInd) = 0; % leaf became splitting node
      nPureLeaf(nNodes-1) = ~all(~labels(dataIndZ{maxInd}));
      nPureLeaf(nNodes) = ~all(labels(dataIndO{maxInd}));
    end
    % class division
    A = data(~logical(labels),:);
    B = data(logical(labels),:);
    
    % count mean
    ST.splitZero = mean(A,1);
    ST.splitOne = mean(B,1);
    
  end    
    
  function y = predict(ST, data)
    nData = size(data,1);
    y = zeros(nData,1);
    zeroDist = sqrt(sum((data-repmat(ST.splitZero,nData,1)).^2,2));
    oneDist = sqrt(sum((data-repmat(ST.splitOne,nData,1)).^2,2));
    y(oneDist < zeroDist) = 1; 
  end 
    
end

methods (Static)
  
  % TODO: splitGain
  function [I,splitZero,splitOne,dataIndZ,dataIndO] = splitGain(data,index,labels)
    
    nData = size(data,1);
    dataID = 1:nData;
    
    % class division
    A = data(~logical(labels(index)),:);
    B = data(logical(labels(index)),:);
    
    % count mean
    splitZero = mean(A,1);
    splitOne = mean(B,1);
    
    % count indexes
    zeroDist = sqrt(sum((data-repmat(splitZero,nData,1)).^2,2));
    oneDist = sqrt(sum((data-repmat(splitOne,nData,1)).^2,2));
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
  
end

end
