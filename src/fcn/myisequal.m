function res = myisequal(a, b)
% Compares 'a' and 'b' and returns true if they are the same (even in the 
% case of NaN) and false if they are not.
%
% Warning & TODO: Does not work for array of struct.

  res = isequal(a, b);
  
  if ~res && all(size(a) == size(b))
    % negative cases
    if not( iscell(a) || isstruct(a) || iscell(b) || isstruct(b) || ischar(a) || ischar(b)) 
      res = isequal(a(~isnan(a)), b(~isnan(b)));

    % compare cells
    elseif iscell(a) && iscell(b)
      res = isempty(find(~cellfun( @myisequal, a, b), 1));

    % compare structures
    elseif isstruct(a) && isstruct(b)
      sfa = fieldnames(a);
      sfb = fieldnames(b);
      if isequal(sfa, sfb)
        partRes = false(1, length(sfa));
        for f = 1 : length(sfa)
          partRes(f) = myisequal(getfield(a, sfa{f}), getfield(b, sfb{f}));
        end
        res = all(partRes);
      end
    end
  end
    
end