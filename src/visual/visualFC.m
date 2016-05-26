function h = visualFC(FCmatrix, name, id, minVal)
% Visualize function connectivity matrix
%
% Input:
%   FCmatrix - function connectivity matrix
%   id       - patients/volunteers ID
%   name     - name of visualization
%   minVal   - minimal value for color scaling between multiple figures
%
% Output:
%   h - handle of image

  if nargin < 3
    id = [];
    if nargin < 2
      name = '';
      if nargin < 1
        h = [];
        help visualFC
        return
      end
    end
  end
  
  if nargin < 4
    minVal = min(min(FCmatrix));
  end

  h = figure();
  % add -1 element to normalize colors in different images
  FCmatrix(1,1) = minVal;
  image(FCmatrix, 'CDataMapping', 'scaled');
  colorbar
  imageTitle = [];
  if ~isempty(name)
    imageTitle = name;
  end
  if ~isempty(id)
    imageTitle = [imageTitle, ' ID', num2str(id)];
  end
  if ~isempty(imageTitle)
    hold on
    title(imageTitle);
    hold off
  end

end