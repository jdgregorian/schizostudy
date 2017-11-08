%% SVM classifier performance test
% Different settings of SVM classifiers give various results. However, the
% results of SVM-RBF does not seem to be correct in cases where the
% dimension is not low (12+).
%
% Data consists of two equally-sized groups generated using normal
% distribution: A ~ N(0, 1), B ~ N(1, 1) (in each dimension).

%% Define data

nGroupA = 90;
nGroupB = 90;
dim = 30;
spaceShift = 1;
nSubjects = nGroupA + nGroupB;

%% Generate data

A_data = randn(nGroupA, dim);
B_data = spaceShift + randn(nGroupB, dim);

data_mat = [A_data; B_data];
labels = [ones(nGroupA, 1); zeros(nGroupB, 1)];

%% LOO CV loop

correctPredictions_lin = zeros(1, nSubjects);
correctPredictions_poly = zeros(1, nSubjects);
correctPredictions_rbf = zeros(1, nSubjects);
CVindices = 1:nSubjects;
  
for sub = 1:nSubjects
    
  foldIds = sub == CVindices;
  trainingData = data_mat(~foldIds,:);
  trainingLabels = labels(~foldIds);
    
  % training
  svm_lin = fitcsvm(trainingData, trainingLabels, 'kernelfunction', 'linear');
  svm_poly = fitcsvm(trainingData, trainingLabels, 'kernelfunction', 'polynomial');
  svm_rbf = fitcsvm(trainingData, trainingLabels, 'kernelfunction', 'gauss');

  testingData = data_mat(foldIds, :);
  testingLabels = labels(foldIds);

  % prediction
  y_lin = predict(svm_lin, testingData);
  y_poly = predict(svm_poly, testingData);
  y_rbf = predict(svm_rbf, testingData);
      
  % return class predictions
  correctPredictions_lin(foldIds) = y_lin == testingLabels;
  correctPredictions_poly(foldIds) = y_poly == testingLabels;
  correctPredictions_rbf(foldIds) = y_rbf == testingLabels;
end
  
%% Results
% Overall performances of different SVM settings
fprintf('SVM-lin: %2.2f  SVM-poly: %2.2f  SVM-rbf: %2.2f\n', ...
  sum(correctPredictions_lin)/nSubjects, ...
  sum(correctPredictions_poly)/nSubjects, ...
  sum(correctPredictions_rbf)/nSubjects);