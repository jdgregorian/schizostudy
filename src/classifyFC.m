function [performance, FC, categoryValues] = classifyFC(data, method, settings)
% data - path to datafile
% method - method used to classification
% settings - settings of chosen method

  if nargin < 3
      settings = [];
  end
  method = lower(method);

    % prepare data
    loadedData = load(data);
%     FC = loadedData.FC;
    indicesPatients = loadedData.indices_patients;
    categoryValues = zeros(1,size(FC,1));
    categoryValues(indicesPatients) = 1;
    Nsubjects = length(categoryValues);
    matDim = size(FC,2);
    
    % transform 3D FC matrix to matrix where each subject has its own row
    % and each feature one column
    vectorFC = NaN(Nsubjects,matDim*(matDim-1)/2);
    for i = 1:Nsubjects
        oneFC = shiftdim(FC(i,:,:),1);
        vectorFC(i,:) = transpose(nonzeros(triu(oneFC+5)-6*eye(matDim)))-5;
    end
    
    % test classification by chosen method
    switch method
        
        % random forest
        case {'rf','bf','sf'}
            performance = forestClassifier(method,vectorFC, categoryValues, settings);
            
        % wrong method
        otherwise
            fprintf('Wrong method format!!!\n')
            performance = NaN;
            return
    end
    
    fprintf('Method %s had %.2f%% performance on recent data.\n',method,performance*100);
end