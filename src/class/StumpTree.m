classdef StumpTree 
% class for binary decision stupms
    
    properties
      features % dimension of input space
      splitdim % dimension where the split is
      splitvalue % decision bound
      zerocount % number of zero labels
      onescount % number of ones labels
      predictors % predictors in leaves
    end
    
methods
  function ST = StumpTree(data, labels)   
    
    Nsubjects = length(labels);
    
    ST.features = size(data,2);
    ST.splitdim = 0;
    ST.splitvalue = 0;
    ST.zerocount = sum(labels==0);
    ST.onescount = Nsubjects - ST.zerocount;
    if size(data,1) ~= Nsubjects
      fprintf('Data length differs from labels length!');
      return
    end
     
    % class division
    A = data(~logical(labels),:);
    B = data(logical(labels),:);
    
    % find the most discriminative dimension
%     Abig = repmat(A,[1 1 ST.onescount]);
%     Bbig = shiftdim(repmat(B',[1 1 ST.zerocount]),2);
%     dif = Abig - Bbig;
     
    % choose smaller matrix to operate with
    if ST.zerocount < ST.onescount
      smaller = A;
      larger = B;
    else
      smaller = B;
      larger = A;
    end
    
    % find the most discriminative dimension
    Nsmall = size(smaller,1);
    Nlarge = size(larger,1);
    dif = NaN(Nlarge,ST.features,Nsmall);
    for i = 1:Nsmall
      dif(:,:,i) = larger - repmat(smaller(i,:),Nlarge,1);
    end
    
    [~,ST.splitdim] = max(abs(sum(sum(dif,1),3)));
    
    % find the best split 
    splits = sort(data(:,ST.splitdim));
    splits = (splits(1:end-1) + splits(2:end)) / 2; % count possible splits 
    I = StumpTree.infoGain(data,labels,ST.splitdim,splits);
    [~,id] = max(I);
    ST.splitvalue = splits(id);
    
    % find predictors
    ST.predictors(1) = round(mean(labels(data(:,ST.splitdim) < ST.splitvalue)));
    ST.predictors(2) = round(mean(labels(data(:,ST.splitdim) >= ST.splitvalue)));
    
    if ST.predictors(1) == ST.predictors(2)
      ST.predictors(2) = 1 - ST.predictors(1); % ensure different classes
    end
    
  end    
    
  function y = predict(ST, data)
    y = zeros(size(data,1),1);
    y(data(:,ST.splitdim) < ST.splitvalue) = 1; 
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
