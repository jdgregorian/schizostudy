function drawColorTables(gene, error)
% Plots colored graphs for gene and error matrices for better visualisation
% of RDA performance changing according to alpha and delta parametres

errorTable = load(error);
geneTable = load(gene);

errorTable = errorTable(2:end,:);
geneTable = geneTable(2:end,:);

plotTable(geneTable,errorTable,'pcolor',1)

plotTable(geneTable,errorTable,'contour',2)

end

function plotTable(gene,err,style,newFig)

if nargin < 4
  newFig = 0;
end

if newFig
  figure('Name',[style ' graph'],'Units','centimeters','Position',[5+15*(newFig-1),15,14,45],'NumberTitle','off')
else
  figure()
end

hold on
subplot(2,1,1)
subplotTable(gene,'Number of features used',style)
subplot(2,1,2)
subplotTable(err,'Number of misclassifications',style)

hold off




end

function subplotTable(A,name,style)

switch style
  case 'pcolor'
    pcolor(A)
  case 'contour'
    contour(A)
  otherwise
    fprintf('Only pcolor and contour available as style parameter!')
end

grid off
colormap('jet')
colorbar
title(name,'FontSize',14)
xlabel('\delta')
ylabel('\alpha')

xvalues = get(gca,'XTick');
set(gca, 'XTickLabel',cellstr(num2str(xvalues'/100)));
yvalues = get(gca,'YTick');
set(gca, 'YTickLabel',cellstr(num2str(yvalues'/100)));

end