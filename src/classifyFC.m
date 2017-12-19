function [avgPerformance, preparedData, preparedLabels, class] = classifyFC(data, method, settings, filename)
% classifyFC(data, method, settings, filename) classifies functional 
% (structural) connectivity data in 'data' by 'method' with additional
% settings to method.
%
% Input:
%   data     - path to datafile or folder with training and testing 
%              folders | string
%   method   - method used to classification | string
%   settings - settings of chosen method | structure
%   filename - name of file with results (optional) | string
%            - if empty no saving is done
%
% Output:
%   avgPerformance - average performance of chosen classifier with 
%                    appropriate settings
%   preparedData   - functional connectivity data used for computations
%   preparedLabels - labels of data in 'preparedData' matrix from 'data'
%   class          - labels of data assigned by classifier
%
% See Also:
%   classifier

  if nargin < 3
    settings = [];
    if nargin < 2
      help classifyFC
      return
    end
  end
  
  % result saving settings
  if nargin == 4
    avgPerformance = NaN;
    resultFileName = fullfile('exp', 'experiments', filename);
    [foldername, resultFile, resFileExt] = fileparts(resultFileName);
    if ~isdir(foldername)
      mkdir(foldername)
    end
    % temporary folder
    tmpfolder = fullfile(foldername, 'tmp');
    tmpFileName = fullfile(tmpfolder, [resultFile, resFileExt]);
    % TODO: load temporary file and continue
  end
  
  method = lower(method);

  % prepare data
  if isdir(data)
    [preparedData, preparedLabels] = loadTrainTestDataFolder(data);
  else
    loadedData = load(data);
    % functional or structural connectivity data
    if isfield(loadedData,'FC') || isfield(loadedData,'SC') 
      [preparedData, preparedLabels] = loadFC(loadedData);
    % one matrix and one vector of data 
    elseif length(fieldnames(loadedData)) == 2 
      [preparedData, preparedLabels] = loadDataLabels(loadedData);
    else
      preparedData = [];
      preparedLabels = [];
    end
  end
  
  % prepared data check
  if isempty(preparedData) || isempty(preparedLabels)
    errors = 'Wrong input format or file!';
    warning(errors)
    if nargin == 4
      save(resultFileName, 'avgPerformance', 'errors', 'data')
    end
    return
  end

  % test classification by chosen method for 'iteration' times
  iteration = defopts(settings, 'iteration', 1);
  saveClassif = defopts(settings, 'saveClassifier', false);
  performance = zeros(1,iteration);
  class = cell(1,iteration);
  correctPredictions = cell(1,iteration);
  errors = cell(1,iteration);
  trainedClassifier = cell(1, iteration);
  elapsedTime = zeros(1,iteration);
  % iteration loop
  for i = 1:iteration
    if iteration > 1
      fprintf('Iteration %d:\n',i)
    end
    tic
    [performance(i), class{i}, correctPredictions{i}, errors{i}, trainedClassifier{i}] = classifier(method, preparedData, preparedLabels, settings);
    elapsedTime(i) = toc;
    
    % compute average performance using finished iterations
    avgPerformance = mean(performance(1:i));
    
    % save temporary results
    if nargin == 4
      [tmp_stat, ~] = mkdir(tmpfolder);
      if tmp_stat
        save(tmpFileName, 'settings', 'method', 'data', 'performance', 'avgPerformance', 'class', 'correctPredictions', 'errors', 'elapsedTime')
        if saveClassif
          save(tmpFileName, 'trainedClassifier', '-append')
        end
      end
    end
  end

  fprintf('Method %s had %.2f%% performance in average (%d iterations) on data %s.\nAnd lasted %.2f seconds.\n', ...
          method, avgPerformance*100, iteration, data, sum(elapsedTime));
        
  % save results
  if nargin == 4
    save(resultFileName, 'settings', 'method', 'data', 'performance', 'avgPerformance', 'class', 'correctPredictions', 'errors', 'elapsedTime')
    if saveClassif
      save(resultFileName, 'trainedClassifier', '-append')
    end
    % delete temporary file (and folder) if possible
    if isfile(tmpFileName)
      delete(tmpFileName);
      [~] = rmdir(tmpfolder);
    end
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
      % to ensure saving zero correlations constant is added before
      % and subtracted after transformation
      if min(triu(oneFC, 1)) > 0
        shiftConst = 0;
      else
        shiftConst = ceil(abs(min(min(triu(oneFC, 1)))) + 1);
      end
      data(i, :) = nonzeros(triu(oneFC + shiftConst, 1))' - shiftConst;
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
    if ~isequal(classes, [0, 1])
      vector(double(vector) == classes(1)) = 0;
      vector(double(vector) == classes(2)) = 1;
    end
    if size(vector,1) < size(vector,2)
      labels = vector';
    else
      labels = vector;
    end
  end
end

function [data, labels] = loadTrainTestDataFolder(foldername)
% Loading training and testing data saved in folder in different files
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
  
  minvalue = min(min(labels{1}), min(labels{2}));
  labels{1} = labels{1} - minvalue;
  labels{2} = labels{2} - minvalue;
end