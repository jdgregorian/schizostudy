function saved = reduceSubjects(datafile, subjectOut, classOut, balance)
% Exclude subjects in 'subjectOut' from class 'classOut', balance dataset 
% according to 'balanceMode' and save it.
% 
% Input:
%   datafile   - name of datafile with connectivity matrix | string
%   subjectOut - subjects to remove from matrix | double vector
%   classOut   - label of subjects to be removed (if empty, subjects will
%                be removed without consideration group balance)
%   balance    - mode of balancing the dataset | 
%                'first'  - first N data not labeled as 'classOut' are 
%                           removed, N is the number of removed data in
%                           'classOut' group
%                'equal'  - from both groups are removed data with
%                           'subjectOut' id
%                'random' - data to remove not labeled as 'classOut' are
%                           chosen at random
%                'none'   - only data labeled as 'classOut' are excluded
%
% Output:
%   saved - denotes if the result was succesfully saved | boolean
%
% See Also:
%   reduceFCData, csvexport

  saved = false;

  % check input
  if nargin < 4
    if nargin < 3
      if nargin < 2
        help reduceSubjects
        return
      end
      classOut = [];
    end
    balance = 'none';
  end

  loadedData = load(datafile);
  
  [labels, data, names] = vectOrMat(loadedData);
  
  assert(~isempty(data), 'Data in %s does not exist!', datafile)
  assert(~isempty(labels), 'Labels in %s does not exist!', datafile)
  
  nLabels = length(labels);
  nData = size(data, 1);
  
  assert(nLabels == nData, 'Data and labels in %s does not have the same length.', datafile)
  
  sKeep = true(nLabels,1);
  
  if isempty(classOut) % reduce whole dataset
    if islogical(subjectOut)
      assert(length(subjectOut) == nLabels, 'Vector of subjects has to have length same as label vector!')
      sKeep = ~subjectOut;
    else
      sKeep(subjectOut) = false;
    end
  else % reduce the 'classOut' data, the rest according to 'balance'
    classes = unique(labels);
    assert(any(classes == classOut), 'Data %s does not contain label %s.', datafile, num2str(classOut))
    reducedClassData = labels == classOut; % which data have the reduced label
    
    if islogical(subjectOut)
      assert(length(subjectOut) == sum(reducedClassData), 'Vector of subjects has to have length same as ''classOut'' label vector!')
    else
      extraSubjects = subjectOut > length(reducedClassData);
      if any(extraSubjects)
        warning('Omitting %d subjects with greater id than contained in %s.', sum(extraSubjects), datafile)
        subjectOut(extraSubjects) = [];
      end
      s = subjectOut;
      subjectOut = false(length(reducedClassData), 1);
      subjectOut(s) = true;
    end
    
    sKeep = true(length(labels), 1);
    sKeep(reducedClassData)  = ~subjectOut;
      
    % choose reduction for the non-'classOut' group
    switch balance
      case 'first' % omit first N subjects from the other group
        sKeep(~reducedClassData) = [false(1 : sum(subjectOut));
                                   true(sum(subjectOut) + 1 : length(~reducedClassData))];

      case 'equal' % omit the same subjects in both groups
        sKeep(~reducedClassData)  = ~subjectOut;
        
      case 'random' % omit N random subjects from the other group
        s = true(length(~reducedClassData), 1);
        s(randperm(length(~reducedClassData), sum(subjectOut))) = false; 
        sKeep(~reducedClassData) = s;
        
      case 'none' % default case - nothing else to do
        
      otherwise
        error('Wrong balance setting')
    end
  end
  
  eval([names.matrix, ' = data(sKeep, :);'])
  eval([names.vector, ' = labels(sKeep);'])
  
  % check and save new data
  filename = [datafile(1:end-4), '_reduced', num2str(sum(sKeep)), '.mat'];
  if exist(filename, 'file')
      answer = questdlg(['Overwrite ', filename, ' ?'], 'Overwritting mat file', 'Overwrite', 'No', 'Overwrite');
      if strcmp('Overwrite', answer)
          overwrite = 1;
      else
          overwrite = 0;
      end
  else
    overwrite = 1;
  end
  if overwrite
    save(filename, names.vector, names.matrix)
    fprintf('Reduced dataset saved to %s.\n', filename)
    saved = true;
  end
  
end