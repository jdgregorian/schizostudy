%% DWI dataset clustering and outliers finding
% Results of DWI dataset clustering and outliers finding. 
% This analysis starts with PCA and continues with agglomerative 
% hierarchical clustering, and outliers finding using Mahalanobis distance 
% and Tukey's test. 
% All clustering and outliers finding methods use data in 2, 5, 10, and 20D
% (reduced by PCA).
% The whole analysis was done using first the whole dataset and the second 
% only patients data. 

%%

% load files
S = load('data/data_DWI_154subjects.mat');
patID = logical(S.indices);
conID = ~logical(S.indices);

%% PCA full data
% The dimension of the whole dataset was reduced using PCA.

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

%% Full data clustering analysis
% Agglomerative hierarchical cluster analysis on the whole dataset. 
% The dimension was reduced using PCA to 2, 5, 10, and 20D.

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

%%

% 20D
dim = 20;
% cluster analysis
clusterAnalysis(redData, 1:dim)

%% Full data outlier finding - Tukey's test
% Tukey's test is based on measures such as the interquartile range. Let 
% $Q_1$ and $Q_3$ be the lower and upper quartiles 
% respectively, then one could define an outlier to be any observation 
% outside the range $[ Q_1 - k(Q_3 - Q_1) , Q_3 + k(Q_3 - Q_1 ) ]$
% for some nonnegative constant $k$. John Tukey proposed this test, where 
% $k = 1.5$ indicates an "outlier", and $k = 3$ indicates data that is 
% "far out" (Tukey, John W. (1977). Exploratory Data Analysis. 
% Addison-Wesley. ISBN 0-201-07616-0.).
%
% Tukey's test with $k=1.5$ is computed in each dimension. Graphs show 
% numbers of
% dimension where the point was evaluated as an outlier. Points where the
% number of outlier dimensions is greater (or equal) to median of all
% non-zero outlier dimensions is marked as a possible outlier (red color).
% The dimension was reduced using PCA to 2, 5, 10, and 20D.

close all
clear settings
settings.method = 'tukey';
settings.dataNames = {'patients', 'controls'};
settings.showMaxOut = 15;

% 2D
dim = 2;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 5D
dim = 5;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 10D
dim = 10;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 20D
dim = 20;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

%% Full data outlier finding - Mahalanobis
% Mahalanobis distance is computed between each point and the rest of 
% points. Most probable outliers were chosen according to Tukey's test
% ($k=1.5$) using Mahalanobis distance. 
% The dimension was reduced using PCA to 2, 5, 10, and 20D.

close all
clear settings
settings.method = 'mahal';
settings.dataNames = {'patients', 'controls'};

% 2D
dim = 2;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 5D
dim = 5;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 10D
dim = 10;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 20D
dim = 20;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

%%
% Afterwards, the dimension was reduced using PCA to 40, 80, 120, and 150D 
% (for more interested reader).

close all

% 40D
dim = 40;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 80D
dim = 80;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 120D
dim = 120;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

% 150D
dim = 150;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis({redData(patID, :), redData(conID,: )}, 1:dim, settings)

%% PCA patients
% The dimension of patients data was reduced using PCA.

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

%% Patients clustering analysis
% Agglomerative hierarchical cluster analysis on patients data. 
% The dimension was reduced using PCA to 2, 5, 10, and 20D.

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

%%

% 20D
dim = 20;
% cluster analysis
clusterAnalysis(redData, 1:dim)

%% Patients outlier finding - Tukey's test
% Tukey's test is based on measures such as the interquartile range. Let 
% $Q_1$ and $Q_3$ be the lower and upper quartiles 
% respectively, then one could define an outlier to be any observation 
% outside the range $[ Q_1 - k(Q_3 - Q_1) , Q_3 + k(Q_3 - Q_1 ) ]$
% for some nonnegative constant $k$. John Tukey proposed this test, where 
% $k = 1.5$ indicates an "outlier", and $k = 3$ indicates data that is 
% "far out" (Tukey, John W. (1977). Exploratory Data Analysis. 
% Addison-Wesley. ISBN 0-201-07616-0.).
%
% Tukey's test with $k=1.5$ is computed in each dimension. Graphs show 
% numbers of
% dimension where the point was evaluated as an outlier. Points where the
% number of outlier dimensions is greater or equal to median of all
% non-zero outlier dimensions is marked as a possible outlier (red color).
% The dimension was reduced using PCA to 2, 5, 10, and 20D.

close all
clear settings
settings.method = 'tukey';
settings.dataNames = {'patients'};
settings.showMaxOut = 15;

% 2D
dim = 2;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

% 5D
dim = 5;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

% 10D
dim = 10;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

% 20D
dim = 20;
settings.title = ['Tukey''s test ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

%% Patients outlier finding - Mahalanobis
% Mahalanobis distance is computed between each point and the rest of 
% points. Most probable outliers were chosen according to Tukey's test
% ($k=1.5$) using Mahalanobis distance. 
% The dimension was reduced using PCA to 2, 5, 10, and 20D.

close all
clear settings
settings.method = 'mahal';
settings.dataNames = {'patients'};

% 2D
dim = 2;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

% 5D
dim = 5;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

% 10D
dim = 10;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

% 20D
dim = 20;
settings.title = ['Mahalanobis ', num2str(dim), 'D'];
% outlier analysis
outlierAnalysis(redData, 1:dim, settings)

%%

% final clearing
close all