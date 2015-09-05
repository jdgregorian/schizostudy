  function I = infoGainSet(dataIndZ, dataIndO, labels, weights)
  % Function counts information gain of split of two sets of points
  % dataIndZ - 'zero' set of data
  % dataIndO - 'one' set of data
  % labels   - labels of data [dataIndZ,dataIndO]
  % weights  - weights of datapoints
      
    allData = [dataIndZ, dataIndO];
    Ndata = length(allData);
    
    if nargin < 4
      maxInd = max(allData);
      weights = ones(1, maxInd)/maxInd;
    else
      weights = weights/sum(weights); % normalize sum of weights to one
    end 
    
    PallZ = sum(weights(dataIndZ)); % weighted initial 'zero' probability
    PallO = sum(weights(dataIndO)); % weighted initial 'one' probability
    
    PzeroZ = sum(~labels(dataIndZ).*weights(dataIndZ)); % weighted probability of zero points in 'zero' child (correct)
    PzeroO = PallZ - PzeroZ;         % weighted probability of one points in 'zero' child (incorrect)
    
    PoneZ = sum(~labels(dataIndO).*weights(dataIndO)); % weighted probability of zero points in 'one' child (incorrect)
    PoneO = PallO - PoneZ;         % weighted probability of one points in 'one' child (correct)
    
    pFull = [sum(~labels(allData).*weights(allData)), sum(labels(allData).*weights(allData))];
    pLeft = [PzeroZ./PallZ, PzeroO./PallZ]; % zero goes to the left child
    pRight = [PoneZ./PallO, PoneO./PallO];  % one goes to the right child
        
    I = shannonEntropy(pFull) - PallZ./Ndata.*shannonEntropy(pLeft)...
        - PallO./Ndata.*shannonEntropy(pRight);
  end
  
  function H = shannonEntropy(p)
  % p is matrix of probabilities
    H = - sum(p.*log(p),2);
    H(isnan(H)) = 0;
  end