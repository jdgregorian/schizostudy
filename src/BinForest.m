classdef BinForest 
    
    properties
        Trees  % T-1 cell array of tree stumps
        nvars  % #of features
        NTrees % number of trees
        minleaf % minimal number of points in leaf
        performances % array of performances
    end
    
methods
    function BF = BinForest(data, labels, NTrees, minleaf)                    
        %if k is bigger than data length, k=2/3 data size.
        
        BF.NTrees = 0;
        BF.nvars=size(data,2);
        
        BF.minleaf = minleaf;
        
        for T = 1:NTrees
            
            useInd = randi(size(data,1),1,size(data,1));
            Tree = fitctree(data(useInd,:),labels,'MinLeafSize',BF.minleaf,'MinParentSize',2*BF.minleaf);
            BF.Trees{T} = Tree;
            % tree performance counting
            y = Tree.predict(data(useInd,:));
            BF.performances(T) = sum(~xor(y',labels))/length(labels);
            BF.NTrees = BF.NTrees + 1;
        end
    end    
    
    function [y,Y]=predict(BF, data)
        Y=zeros(size(data,1),BF.NTrees);
        for i=1:BF.NTrees;
            Y(:,i)=BF.Trees{i}.predict(data);
        end            
        y=sum(Y,2)/BF.NTrees;%>0.5;
        fprintf('%f\n',y);
        y = round(y);
    end  
    
end

end
