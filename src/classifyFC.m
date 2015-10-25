function [performance, preparedData, preparedLabels, class] = classifyFC(data, method, settings, filename)
% classifyFC(data, method, settings, filename) classifies functional 
% (structural) connectivity data in 'data' by 'method' with additional
% settings to method.
%
% Input:
%
% data     - path to datafile or folder with training and testing folders 
%            | string
% method   - method used to classification | string
% settings - settings of chosen method | structure
% filename - name of file with results (optional) | string
%          - if empty no saving is done
%
% Output:
%
% performance    - performance of chosen classifier with appropriate 
%                  settings
% preparedData   - functional connectivity data used for computations
% preparedLabels - labels of data in 'preparedData' matrix from 'data'
% class          - labels of data assigned by classifier
%
% See Also:
% classifier

  if nargin < 3
      settings = [];
      if nargin < 2
        help classifyFC
        return
      end
  end
  method = lower(method);

  % prepare data
  if isdir(data)
    [preparedData, preparedLabels] = loadTrainTestData(data);
  else
    loadedData = load(data);
    % functional or structural connectivity data
    if isfield(loadedData,'FC') || isfield(loadedData,'SC') 
      [preparedData, preparedLabels] = loadFC(loadedData);
    % one matrix and one vector of data 
    elseif length(fieldnames(loadedData)) == 2 
      [preparedData, preparedLabels] = loadDataLabels(loadedData);
      if isempty(preparedData) || isempty(preparedLabels)
        warning('Wrong input format or file!')
        performance = NaN;
        return
      end
    else
      warning('Wrong input format or file!')
      performance = NaN;
      preparedData = [];
      preparedLabels = [];
      return
    end
  end

  % test classification by chosen method for 'iteration' times
  iteration = defopts(settings,'iteration',1);
  performance = zeros(1,iteration);
  class = cell(1,iteration);
  correctPredictions = cell(1,iteration);
  errors = cell(1,iteration);
  for i = 1:iteration
    if iteration > 1
      fprintf('Iteration %d:\n',i)
    end
    [performance(i), class{i}, correctPredictions{i}, errors{i}] = classifier(method, preparedData, preparedLabels, settings);
  end
  avgPerformance = mean(performance);

  fprintf('Method %s had %.2f%% performance in average (%d iterations) on data %s.\n', method, avgPerformance*100, iteration, data);
  
  % save results
  if nargin == 4
    save(fullfile('exp','experiments',filename), 'settings', 'method', 'data', 'performance', 'avgPerformance', 'class', 'correctPredictions', 'errors')
  end
end

function [data, labels] = loadFC(loadedData)
% Loading FC datafile

  if isfield(loadedData,'FC') % functional connectivity
    FC = loadedData.FC;
  else % structural connectivity
    FC = loadedData.SC;
  end
  if isfield(loadedData,'categoryValues')
    labels = loadedData.categoryValues;
  else
    indicesPatients = loadedData.indices_patients;
    labels = zeros(size(FC,1),1);
    labels(indicesPatients) = 1;
  end

  Nsubjects = length(labels);
  matDim = size(FC,2);

  % transform 3D FC matrix to matrix where each subject has its own row
  % and each feature one column
  data = NaN(Nsubjects,matDim*(matDim-1)/2);
  for i = 1:Nsubjects
      oneFC = shiftdim(FC(i,:,:),1);
      data(i,:) = transpose(nonzeros(triu(oneFC+5)-6*eye(matDim)))-5;
  end
end

function [data, labels] = loadDataLabels(loadedData)
% Loading data with one vector of labels and one matrix of features

  data = [];
  labels = [];
  
  [vector, matrix] = vectOrMat(loadedData);
  if isempty(vector) || isempty(matrix)
    return
  end
  
  vectorLength = length(vector);
  classes = double(unique(vector));
  if size(matrix, 1) ~= vectorLength % correct shape filter
    return
  elseif vectorLength < 2 % small data filter
    warning('Data size is only %d. Cannot perform classification!', vectorLength)
    return
  elseif length(classes) ~= 2 % non-binary classification filter
    warning('ClassifyFC performs only binary classification.')
    return
  else
    data = double(matrix);
    vector(double(vector) == classes(1)) = 0;
    vector(double(vector) == classes(2)) = 1;
    if size(vector,1) < size(vector,2)
      labels = vector';
    else
      labels = vector;
    end
  end
end

function [data, labels] = loadTrainTestData(foldername)
% Loading training and testing data
%
% Only for David's format - two folders 'training' and 'testing' containing
% .mat file 'GraphAndData' with matrix of features 'dataname' and vector of
% labels 'labelname'.
  trainDataList = dir(fullfile(foldername, '*_training.mat'));
  testDataList = dir(fullfile(foldername, '*_testing.mat'));
  loadedTrainData = load(fullfile(foldername, trainDataList.name));
  loadedTestData = load(fullfile(foldername, testDataList.name));
  
  [labels{1}, data{1}] = vectOrMat(loadedTrainData);
  [labels{2}, data{2}] = vectOrMat(loadedTestData);
  
  labels{1} = labels{1} - 1;
  labels{2} = labels{2} - 1;
end

function [vector, matrix] = vectOrMat(datafile)
% Loads vector and matrix from datafile
  vector = [];
  matrix = [];

  names = fieldnames(datafile);
  value1 = getfield(datafile, names{1});
  value2 = getfield(datafile, names{2});
  
  % matrix and vector filter
  if ismatrix(value1) && isvector(value2)
    matrix = value1;
    vector = value2;
  elseif ismatrix(value2) && isvector(value1)
    matrix = value2;
    vector = value1;
  else
    return
  end
  
end