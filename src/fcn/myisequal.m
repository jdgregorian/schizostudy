function res = myisequal(a, b)

  res = isequal(a, b);
  
  % negative cases
  if not( res || iscell(a) || isstruct(a) || iscell(b) || isstruct(b) || ischar(a) || ischar(b)) && all(size(a) == size(b)
    res = isnan(a) && isnan(b);
    
  % compare cells
  elseif ~res && iscell(a) && iscell(b) && all(size(a) == size(b))
      res = isempty(find(~cellfun( @myisequal, a, b), 1));
      
  % compare structures
  elseif ~res && isstruct(a) && isstruct(b) && all(size(a) == size(b))
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