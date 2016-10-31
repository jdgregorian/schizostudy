%% DWI dataset clustering
% Results of DWI dataset clustering 

%%

% load files
S = load('data/data_DWI_154subjects.mat');
patID = logical(S.indices);
conID = ~logical(S.indices);

%% Perform PCA
[~, redData, lambda] = pca(S.data);

fprintf('Eigenvalues: \n')
printStructure(lambda)
fprintf('\n')

lambdaDiff = lambda(1:end-1)-lambda(2:end);
diffToShow = 0.2;
lastDiffID = find(lambdaDiff > diffToShow, 1, 'last');

fprintf('Differences of first %d eigenvalues: \n', lastDiffID + 1)
for e = 1:lastDiffID
  fprintf('%0.4f\n', lambdaDiff(e));
end

fprintf('\nThe rest of eigenvalues differences is lower than %g.\n', diffToShow)

%% Two principle components
close all

% reduce dimension
dim = 2;
actualData = redData(:, 1:dim);

figure()
hold on
% patients
scatter(actualData(patID, 1), actualData(patID, 2), 'x')
% controls
scatter(actualData(conID, 1), actualData(conID, 2), 'o')

xlabel('First PCA component')
ylabel('Second PCA component')
legend('patients', 'controls')

hold off

%% Three principle components
close all

% reduce dimension
dim = 3;
actualData = redData(:, 1:dim);

figure()
hold on
% patients
scatter3(actualData(patID, 1), actualData(patID, 2), actualData(patID, 3), 'x')
% controls
scatter3(actualData(conID, 1), actualData(conID, 2), actualData(conID, 3), 'o')

grid on

xlabel('First PCA component')
ylabel('Second PCA component')
zlabel('Third PCA component')
legend('patients', 'controls')

view(40, 10)

hold off


%% Perform PCA only on patients
[~, redData, lambda] = pca(S.data(patID, :));

fprintf('Eigenvalues: \n')
printStructure(lambda)
fprintf('\n')

lambdaDiff = lambda(1:end-1)-lambda(2:end);
diffToShow = 0.25;
lastDiffID = find(lambdaDiff > diffToShow, 1, 'last');

fprintf('Differences of first %d eigenvalues: \n', lastDiffID + 1)
for e = 1:lastDiffID
  fprintf('%0.4f\n', lambdaDiff(e));
end

fprintf('\nThe rest of eigenvalues differences is lower than %g.\n', diffToShow)

%% Two principle components (only patients)
close all

% reduce dimension
dim = 2;
actualData = redData(:, 1:dim);

figure()
hold on
% patients
scatter(actualData(:, 1), actualData(:, 2), 'x')

xlabel('First PCA component')
ylabel('Second PCA component')
legend('patients')
title('2 principle components of patients')

hold off

%% Three principle components (only patients)
close all

% reduce dimension
dim = 3;
actualData = redData(:, 1:dim);

figure()
hold on
% patients
scatter3(actualData(:, 1), actualData(:, 2), actualData(:, 3), 'x')

grid on

xlabel('First PCA component')
ylabel('Second PCA component')
zlabel('Third PCA component')
legend('patients')
title('3 principle components of patients')

view(40, 10)

hold off

%% Patients clustering analyses in 2D

close all

% reduce dimension
dim = 2;
% cluster analyses
clusterAnalyses(redData, 1:dim)

%% Patients clustering analyses in 5D

close all

% reduce dimension
dim = 5;
% cluster analyses
clusterAnalyses(redData, 1:dim)

%% Patients clustering analyses in 10D

close all

% reduce dimension
dim = 10;
% cluster analyses
clusterAnalyses(redData, 1:dim)