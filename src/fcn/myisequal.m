function res = myisequal(a, b)
% Compares 'a' and 'b' and returns true if they are the same (even in the 
% case of NaN) and false if they are not.

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
      if isequal(sfa, fieldnames(b))
        for f = 1 : length(sfa)
          aValues = arrayfun(@(x) x.(sfa{f}), a, 'UniformOutput', false);
          bValues = arrayfun(@(x) x.(sfa{f}), b, 'UniformOutput', false);
          % return in case of inequality
          if ~myisequal(aValues, bValues)          
            return
          end
        end
        res = true;
      end
    end
  end
    
end