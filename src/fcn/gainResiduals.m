function res = gainResiduals(X, y, categoricalVar)
% res = gainResiduals(X, y, categoricalVar) returns residuals of linear 
% regression on X and y.
%
% Input:
%   X              - linear regression data matrix | double
%   y              - linear regression response variable | double
%   categoricalVar - numbers of 'X' columns containing categorical
%                    variables | integer
%
% Output:
%   res - linear regression residuals | double
%
% See Also:
%   fitln

  if nargin < 3
    if nargin < 2
      if nargout == 1
        res = [];
      end
      help gainResiduals
      return
    end
    categoricalVar = 1:size(X, 2);
  end
  
  catVar = arrayfun(@(x) ['x', num2str(x)], categoricalVar, 'UniformOutput', false);
  LM = fitlm(X, y, 'CategoricalVar', catVar);
  res = LM.Residuals.Raw;

end