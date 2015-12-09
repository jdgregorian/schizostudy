function name = settingsStructName(method)
  
  switch method
    case {'dectree', 'lintree', 'svmtree', 'mtltree'}
      name = 'tree';
    case {'rf', 'mrf'}
      name = 'forest';
    otherwise
      name = method;
  end

end