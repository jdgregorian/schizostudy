classdef LinearTree 
% class for binary decision tree using linear boundaries
% NOT FINISHED
    
  properties
    % Data properties
    features  % dimension of input space
    zerocount % number of zero labels
    onescount % number of ones labels

    % Tree properties
    children  % children coordinates
    parent    % parent coordinates
    splitZero % 'zero' points determining the split boundary
    splitOne  % 'one' points determining the split boundary
%       predictors % predictors in leaves
  end
    
methods
  function ST = LinearTree(data, labels)   
    
    
    Nsubjects = length(labels);
    
    ST.features = size(data,2);
    ST.zerocount = sum(labels==0);
    ST.onescount = Nsubjects - ST.zerocount;
    
    ST.children = [0 0];
    ST.parent = 0;
    ST.splitZero = [];
    ST.splitOne = [];
    
    if size(data,1) ~= Nsubjects
      fprintf('Data length differs from labels length!');
      return
    end
     
    nPureLeaf = 0; % leaves which are not pure
    i = 0;
    while any(nPureLeaf) || i < 10
      i = i+1; % just to be sure this ends
      
      nToSplit = sum(nPureLeaf); % number of leaves possible to split
      I = zeros(1,nToSplit);
      splitZero = NaN(nToSplit,ST.features);
      splitOne = NaN(nToSplit,ST.features);
      for s = 1:nToSplit
        [I(s),splitZero(s),splitOne(s)] = splitGain(ST,data); %TODO: splitGain function
      end
      
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
  
  % TODO: splitGain
  function [I,A,B] = splitGain(ST,data)
    I = NaN;
    A = NaN;
    B = NaN;
  end
    
end

methods (Static)

  function I = infoGain(data,labels,splitdim,splitvalues)
  % splitdim - dimension of split
  % splitvalue - vector of decision bounds in splitdim dimension
  
    A = data(~logical(labels),splitdim);
    B = data(logical(labels),splitdim);
    Ndata = length(labels);
    
    NallA = length(A);
    NallB = Ndata - NallA;
    
    NleftA = NaN(Ndata-1,1);
    NleftB = NaN(Ndata-1,1);
    for i = 1 : Ndata - 1
      NleftA(i) = length(A(A<splitvalues(i)));
      NleftB(i) = length(B(B<splitvalues(i)));
    end
    
    NrightA = NallA - NleftA;
    NrightB = NallB - NleftB;
    
    pFull = [NallA/Ndata, NallB/Ndata];
    pLeft = [NleftA./(NleftA+NleftB), NleftB./(NleftA+NleftB)];
    pRight = [NrightA./(NrightA+NrightB), NrightB./(NrightA+NrightB)];
        
    I = StumpTree.shannonEntropy(pFull)*ones(Ndata-1,1) - (NleftA+NleftB)./Ndata.*StumpTree.shannonEntropy(pLeft)...
        - (NrightA+NrightB)./Ndata.*StumpTree.shannonEntropy(pRight);
  end
  
  function H = shannonEntropy(p)
  % p is matrix of probabilities
    H = - sum(p.*log(p),2);
    H(isnan(H)) = 0;
  end
  
end

end
