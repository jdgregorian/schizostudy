classdef BinForest 
    
    properties
        Trees  % T-1 cell array of trees
        nvars  % # of features
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
            if verLessThan('matlab','8.3')
              Tree = classregtree(data(useInd,:),labels,'method','classification','minleaf',BF.minleaf,'minparent',2*BF.minleaf);
              [~,~,y] = eval(Tree,data(useInd,:)); % y will be double - we have only two classes, we need only numbers
              y = y - 1; 
            else
              Tree = fitctree(data(useInd,:),labels,'MinLeafSize',BF.minleaf,'MinParentSize',2*BF.minleaf);
              y = Tree.predict(data(useInd,:));
            end
            BF.Trees{T} = Tree;
            % tree performance counting

            BF.performances(T) = sum((y'==labels))/length(labels);
            BF.NTrees = BF.NTrees + 1;
        end
    end    
    
    function [y,Y]=predict(BF, data)
        Y=zeros(size(data,1),BF.NTrees);
        if verLessThan('matlab','8.3')
          for i=1:BF.NTrees;
            [~,~,Y(:,i)] = eval(BF.Trees{i},data); % we need only numerical output
            Y(:,i) = Y(:,i) - 1;
          end
        else
          for i=1:BF.NTrees;
            Y(:,i)=BF.Trees{i}.predict(data);
          end
        end
        y=sum(Y.*BF.performances,2)/sum(BF.performances);
        fprintf('%f\n',y);
        y = round(y); %>0.5;
    end  
    
end

end
