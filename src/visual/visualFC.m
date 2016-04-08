function h = visualFC(FCmatrix, name, id)
% Visualize function connectivity matrix
%
% Input:
%   FCmatrix - function connectivity matrix
%   id       - patients/volunteers ID
%   name     - name of visualization
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

  h = figure();
%   A = shiftdim(FCmatrix(patId(d), :, :), 1);
  image(FCmatrix*255);
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