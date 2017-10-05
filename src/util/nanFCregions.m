function [reg, sub] = nanFCregions(FC, subDim)
% reg = nanFCregions(FC, subDim) returns invalid (NaN) regions in FC 
% matrix.
%
% Input:
%   FC     - functional connectivity matrix
%   subDim - number identifying dimension of subjects (default 1)
%
% Output:
%   reg - regions containing NaN values
%   sub - subjects containing NaN values
%
% See Also:
%   reduceFCdata

  reg = [];
  sub = [];

  if nargin < 2
    if nargin < 1
      help nanFCregions
      return
    end
    subDim = 1;
  end
  
  % normalize to subjects be in the last dimension
  FC = shiftdim(FC, subDim);
  % compute matrix where rows corresponds to regions and columns to
  % subjects and 1 indicates NaN region
  nanFC = shiftdim(all(isnan(FC)), 1);
  % find NaN regions and subjects
  sub = find(any(nanFC, 1));
  reg = find(any(nanFC, 2));

end