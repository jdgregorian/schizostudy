classdef StumpForest 
    
    properties
        Trees  % cell array of tree stumps
        nvars  % # of features
        NTrees % number of trees
        performances % array of performances
    end
    
methods
  function SF = StumpForest(data, labels, NTrees)     

    % initialize
    SF.NTrees = 0;
    SF.nvars=size(data,2);

    for T = 1:NTrees
      % bootstrap
      useInd = randi(size(data,1),1,size(data,1));
      Tree = StumpTree(data(useInd,:),labels);
      y = Tree.predict(data(useInd,:));
      SF.Trees{T} = Tree;
      SF.NTrees = SF.NTrees + 1;
      % stump performance counting
      SF.performances(T) = sum((y'==labels))/length(labels);
    end
  end    
    
  function [y,Y] = predict(ST, data)
  % prediction function for stump forest
    Y = zeros(size(data,1),ST.NTrees);
    for i = 1:ST.NTrees
      Y(:,i) = ST.Trees{i}.predict(data);
    end
    perf = ones(1,length(ST.performances));
    y = sum(Y.*perf,2)/sum(perf);
    fprintf('%f\n',y);
    y = round(y); %>0.5;
  end  
    
end

end
