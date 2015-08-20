function [performance, FC, categoryValues] = classifyFC(data, method, settings, filename)
% data - path to datafile
% method - method used to classification
% settings - settings of chosen method

  if nargin < 3
      settings = [];
  end
  method = lower(method);

  % prepare data
  loadedData = load(data);
  if isfield(loadedData,'FC') % functional connectivity
    FC = loadedData.FC;
  elseif isfield(loadedData,'SC') % structional connectivity
    FC = loadedData.SC;
  else
    fprintf('Wrong connectivity matrix!')
    performance = NaN;
    FC = [];
    categoryValues = [];
    return
  end
  if isfield(loadedData,'categoryValues')
    categoryValues = loadedData.categoryValues;
  else
    indicesPatients = loadedData.indices_patients;
    categoryValues = zeros(1,size(FC,1));
    categoryValues(indicesPatients) = 1;
  end
  Nsubjects = length(categoryValues);
  matDim = size(FC,2);

  % transform 3D FC matrix to matrix where each subject has its own row
  % and each feature one column
  vectorFC = NaN(Nsubjects,matDim*(matDim-1)/2);
  for i = 1:Nsubjects
      oneFC = shiftdim(FC(i,:,:),1);
      vectorFC(i,:) = transpose(nonzeros(triu(oneFC+5)-6*eye(matDim)))-5;
  end

  % test classification by chosen method for 'iteration' times
  iteration = defopts(settings,'iteration',1);
  performance = zeros(1,iteration);
  class = cell(1,iteration);
  for i = 1:iteration
    [performance(i), class{i}] = classifier(method,vectorFC, categoryValues, settings);
  end
  avgPerformance = mean(performance);

  fprintf('Method %s had %.2f%% performance in average (%d iterations) on data %s.\n', method, avgPerformance*100, iteration, data);
  
  % save results
  if nargin == 4
    save(fullfile('results',filename), 'settings', 'method', 'data', 'performance', 'avgPerformance', 'class')
  end
end