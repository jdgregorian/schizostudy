function prepareFCData(filename, varargin)
% prepareFCData(filename, settings) prepares mat-file data to a normalized 
% format for FC classification
%
% Input:
%   filename   - name of the mat-file
%   settings   - pairs of property (string) and value, or struct with 
%                properties as fields:
%                  ExSubject   - subjects to be excluded
%                  ExDim       - dimensions to be excluded
%                  FCvariable  - variable containing FC matrix
%                  IndicesFile - file containing subject indices
%                  ResultName  - name of resulting file
%
% See Also:
%   reduceFCData

  if nargin == 0
    help prepareFCData
    return
  end

  % default values
  def_data = fullfile('data', 'data_FC_190subjects_B.mat');
  def_result = fullfile('data', 'data.mat');
  tmp_dir = fullfile('data', 'tmp');
  tmp_file = fullfile(tmp_dir, 'data_tmp.mat');

  % parse function settings
  settings = settings2struct(varargin);
  FCvariable = defopts(settings, 'FCvariable', 'corr_max');
  exSubject  = defopts(settings, 'ExSubject', []);
  exDim      = defopts(settings, 'ExDim', []);
  indFile    = defopts(settings, 'IndicesFile', def_data);
  resultName = defopts(settings, 'ResultName', def_result);

  assert(isfile(filename), 'File ''%s'' does not exist!', filename)
  assert(isfile(indFile), 'Indices file ''%s'' does not exist!', indFile)

  S = load(filename, FCvariable);

  assert(isfield(S, FCvariable), 'Variable ''%s'' is not in the file', FCvariable)
 
  if ndims(S.(FCvariable)) == 3
    % subject has to be in the first dimension
    FC = shiftdim(S.(FCvariable), 2);
    ind = load(def_data, 'indices_patients', 'indices_volunteers');
    assert(isfield(ind, 'indices_patients'), 'Variable ''indices_patients'' is not in the file ''%s''', FCvariable)
    assert(isfield(ind, 'indices_volunteers'), 'Variable ''indices_volunteers'' is not in the file ''%s''', FCvariable)
    indices_patients = ind.indices_patients;
    indices_volunteers = ind.indices_volunteers;
    % save the variables as they are
    if isempty(exSubject) && isempty(exDim)
      save(resultName, 'FC', 'indices_patients', 'indices_volunteers')
    
    % reduce the number of subjects or dimensions
    else
      mkdir(tmp_dir)
      save(tmp_file, 'FC', 'indices_patients', 'indices_volunteers')
      reduceFCData(tmp_file, exSubject, exDim, resultName)
      rmdir(tmp_dir, 's')
    end
  else
    error('Variable ''%s'' has not dimension equal to 3', FCvariable)
  end

end