function performance = forestClassifier(method,data, indices, varargin)
% Classification by MATLAB forest classifier. Returns performance of forest in LOO CV.

    Nsubjects = size(data,1);
    correctPredictions = zeros(1,Nsubjects);
    
    for i = 1:Nsubjects
        trainingSet = data;
        trainingSet(i,:) = [];
        trainingIndices = indices;
        trainingIndices(i) = [];
        switch method
            case 'RF'
                Forest = TreeBagger(1000,trainingSet,trainingIndices);
            case 'BF'
                Forest = BinForest(trainingSet,trainingIndices,5);
        end
        y = predict(Forest,data(i,:));
        if y == indices(i) %strcmp(y{1},num2str(indices(i)))
            correctPredictions(i) = 1;
        end
        fprintf('Subject %d/%d done...\n',i,Nsubjects);
    end
    
    performance = sum(correctPredictions)/Nsubjects;

end
