%% DWI dataset clustering and finding outliers
% Results of DWI dataset clustering and outliers finding

%%

% load files
S = load('data/data_DWI_154subjects.mat');
patID = logical(S.indices);
conID = ~logical(S.indices);

%% Fulldata PCA
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

%%
% Two and three principle components
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
title('2 principle components of full data')

hold off

% Three principle components

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
title('3 principle components of full data')

view(40, 10)

hold off


%% PCA only on patients
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

%%
% Two and three principle components (only patients)
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

% Three principle components (only patients)

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

%% Patients clustering analysis in 2, 5, and 10D

close all

%%

% 2D
dim = 2;
% cluster analysis
clusterAnalysis(redData, 1:dim)

%%

% 5D
dim = 5;
% cluster analysis
clusterAnalysis(redData, 1:dim)

%%

% 10D
dim = 10;
% cluster analysis
clusterAnalysis(redData, 1:dim)

%% Outlier finding - mahalanobis
% Mahalanobis distance is computed between each point and the rest of 
% points. 5 points are marked as possible outliers.

close all

% 2D
dim = 2;
% outlier analysis
outlierAnalysis(redData, 1:dim)

% 5D
dim = 5;
% outlier analysis
outlierAnalysis(redData, 1:dim)

% 10D
dim = 10;
% outlier analysis
outlierAnalysis(redData, 1:dim)


%%

% final clearing
close all