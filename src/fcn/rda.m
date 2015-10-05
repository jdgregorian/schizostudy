function [class, dist1, dist2] = rda(trainingData, trainingLabels, testingData, alpha)
% rda(trainingData, trainingLabels, testingData, alpha) returns binary
% classification of 'testingData' points by regularized discriminant
% analysis using 'trainingData' and 'trainingLabels'.
%
% Input:
%    trainingData   - N x DIM matrix of training data
%    trainingLabels - double vector of labels (length N)
%    testingData    - M x DIM matrix of testing data
%    alpha          - regularization parameter alpha
%
% Output:
%    class - double vector of classified testing points (length M)
%    dist1 - distances to the first class
%    dist2 - distances to the second class

  class = NaN;
  dist1 = NaN;
  dist2 = NaN;

  % input checkout
  switch nargin
    case 0
      help rda
      return
    case {1,2}
      error('Not enough input arguments!')
    case 3
      alpha = 0.999999;
  end
  if size(trainingLabels, 2) > 1
    trainingLabels = trainingLabels';
  end
  
  dim = size(trainingData, 2);
  m = size(testingData, 1);
  
  classes = unique(trainingLabels);
  labels = [trainingLabels; classes];

  id1 = labels == classes(1);
  id2 = labels == classes(2);
  n1 = sum(id1);
  n2 = sum(id2);
  
  class = classes(ones(m,1));
  dist1= NaN(m,1);
  dist2 = NaN(m,1);
  
  for d = 1:m % has to be done for each data separately
    data = [trainingData; testingData([d,d],:)];

    cov1 = cov(data(id1,:));
    cov2 = cov(data(id2,:));
    S = ((n1-1)*cov1 + (n2-1)*cov2)/(n1+n2-1);

    Sstar = alpha*S + (1 - alpha)*eye(dim); % S* = alpha*S + (1-alpha)*I
    [eigVecS, eigValS] = eig(Sstar);
    % possible speed up inverse, multiplication?
    sqEigS = sqrt(1./diag(eigValS));
    Shalf = eigVecS * diag(sqEigS) * eigVecS'; % S^{-1/2} = Q*Lambda^{-1/2}*Q' 
%     Shalf = eigVecS * sqrt(inv(eigValS)) * eigVecS'; % maybe
    Xstar = trainingData * Shalf; % X* = X*S^{-1/2};

    m1 = mean(Xstar(trainingLabels == classes(1),:));
    m2 = mean(Xstar(trainingLabels == classes(2),:));
    Z = testingData(d,:) * Shalf;
    dist1(d) = norm(Z - m1);
    dist2(d) = norm(Z - m2);
  end
  
  class(dist1 > dist2) = classes(2);
    
end