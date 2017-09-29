function res = isfile(filename)
  res = logical(exist(filename, 'file'));
end