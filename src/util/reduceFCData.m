function reduceFCData(data, subjectOut, regionOut, resultName)
% reduceFCData(data, subjectOut, regionOut, resultName) omits subjects
% specified in 'subjectOut' and regions in 'regionOut' from connectivity 
% matrix and indices vectors in file 'data' and saves dataset to 
% 'resultName'.
% 
% Input:
%   data       - name of datafile with connectivity matrix | string
%   subjectOut - subjects to remove from matrix | double vector or
%                'default'
%   regionOut  - regions to remove from matrix | double vector or 'default'
%   resultName - name of resulting datafile | string
%
% See Also:
%   csvexport

  % check input
  if nargin == 0
    help reduceFCData
    return
  end
  if nargin == 1 || strcmp(subjectOut, 'default')
    subjectOut = [66,101,102,104,113,144,152,166,178,179,189,190,192];
  end
  if nargin < 3 || strcmp(regionOut, 'default')
    regionOut = [71,72];
    if nargin < 4
      resultName = [];
    end
  end

  load(data)
  
  % find out type of connectivity matrix
  if exist('FC','var')
    newName = 'FC';
    CM = FC;
  elseif exist('SC','var')
    newName = 'SC';
    CM = SC;
  else
    error('FC or SC matrix has to be included in file!')
  end
  
  % check indices existence
  assert( exist('indices_patients', 'var') && exist('indices_volunteers', 'var'), ...
    'Vectors indices_patients and indices_volunteers has to be included in file.')

  % decide which subjects and regions stay
  nOrigSub = size(CM, 1);
  subjectStay = true(1, nOrigSub);
  subjectStay(subjectOut) = false;
  regionStay = true(1, size(CM, 2));
  regionStay(regionOut) = false;

  % create new dataset
  CM = CM(subjectStay, regionStay, regionStay);
  indices_volunteers = 1:(length(indices_volunteers) - sum(ismember(subjectOut, indices_volunteers)));
  indices_patients = length(indices_volunteers) + (1 : (length(indices_patients) - sum(ismember(subjectOut, indices_patients))));
  nNewSub = size(CM, 1);
  if nNewSub ~= length([indices_volunteers, indices_patients])
    fprintf('Wrong data extraction! Check original data and extraction vectors!');
  else
    % ask and save new data
    if isempty(resultName)
      resultName = fullfile('data', ['data_', newName, '_', num2str(nNewSub), 'subjects.mat']);
    end
    if exist(resultName, 'file')
        answer = questdlg(['Overwrite ', resultName, ' ?'], 'Overwritting mat file', 'Overwrite', 'No', 'Overwrite');
        if strcmp('Overwrite', answer)
            overwrite = 1;
        else
            overwrite = 0;
        end
    else
      overwrite = 1;
    end
    if overwrite
      eval([newName, ' = CM;'])
      save(resultName, newName, 'indices_patients', 'indices_volunteers')
    end
  end
end
