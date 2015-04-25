classdef StumpTree 
% class for binary decision stupms
    
    properties
      dimensions % dimension of input space
      splitdim % dimension where the split is
      splitvalue % decision bound
      zerocount % number of zero labels
      onescount % number of ones labels
    end
    
methods
  function ST = StumpTree(data, labels)                    
    
    ST.dimensions = size(data,2);
    ST.splitdim = 0;
    ST.splitvalue = 0;
    ST.zerocount = sum(labels==0);
    ST.onescount = length(labels) - ST.zerocount;
    if size(data,1) ~= length(labels)
      fprintf('Data length differs from labels length!');
      return
    end
     
    % class division
    A = data(~logical(labels),:);
    B = data(logical(labels),:);
    
    Abig = repmat(A,[1 1 ST.onescount]);
    Bbig = shiftdim(repmat(B',[1 1 ST.zerocount]),2);
    
    diff = Abig - Bbig;
    
    ST.splitdim = max(abs(sum(sum(diff,1),3)));
    
    

  end    
    
    function [y,Y]=predict(ST, data)
        Y=zeros(size(data,1),ST.NTrees);
        if verLessThan('matlab','8.3')
          for i=1:ST.NTrees;
            [~,~,Y(:,i)] = eval(ST.Trees{i},data); % we need only numerical output
            Y(:,i) = Y(:,i) - 1;
          end
        else
          for i=1:ST.NTrees;
            Y(:,i)=ST.Trees{i}.predict(data);
          end
        end
        y=sum(Y.*ST.performances,2)/sum(ST.performances);
        fprintf('%f\n',y);
        y = round(y); %>0.5;
    end  
    
end

end
