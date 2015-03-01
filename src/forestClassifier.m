function performance = forestClassifier(data, indices)
    
    % testing hack - will be removed
%     data = data(:,1:100); 
    
    Nsubjects = size(data,1);
    correctPredictions = zeros(1,Nsubjects);
    
    for i = 1:Nsubjects
        trainingSet = data;
        trainingSet(i,:) = [];
        trainingIndices = indices;
        trainingIndices(i) = [];
        Forest = TreeBagger(10,trainingSet,trainingIndices);
        y = predict(Forest,data(i,:));
        if strcmp(y{1},num2str(indices(i)))
            correctPredictions(i) = 1;
        end
        fprintf('Subject %d/%d done...\n',i,Nsubjects);
    end
    
    performance = sum(correctPredictions)/Nsubjects;

end