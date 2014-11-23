function plot_cluster(initparams, grap_params, cls_params, idx_n2c, pred_n2c, path_c2c)
%{
    @description: plot clustering results 
    @params:
        @initparams: initialization parameters
        @grap_params: parameters of graph
        @cls_params: information on cluster
        @idx_n2c: the index of nearest CH (in 1...num_cls) to which each node connects
        @pred_n2c: the predecessor node to which each node connects in its cluster
        @path_CH: path from a CH to its predecessor CH
    @author: Ruitao Xie, City University of Hong Kong
%}

heads = cls_params.head;
num_cls = length(heads);
locx = grap_params.locationx;
locy = grap_params.locationy;
L = initparams.length;
W = initparams.width;

figure
hold on
axis([0 L 0 W]);
axis off
axis equal;
set(gcf, 'color', 'w');
colorchar = 'rgbmk';

% plot a frame
line([0 L], [W W], 'color', 'k', 'lineWidth', 1);
line([L L], [0 W], 'color', 'k', 'lineWidth', 1);
line([0 0], [0 W], 'color', 'k', 'lineWidth', 1);
line([0 L], [0 0], 'color', 'k', 'lineWidth', 1);

% plot nodes
for i_cls = 1:num_cls
    linespec = colorchar( mod(i_cls,length(colorchar))+1 );
    plot(locx(idx_n2c == i_cls), locy(idx_n2c == i_cls), ...
            'o', 'MarkerEdgeColor', linespec,...
            'MarkerFaceColor', linespec, 'MarkerSize',4);
    CH_str = ['CH' int2str(i_cls)];
    text(locx(heads(i_cls))+0.2,locy(heads(i_cls))+0.2, CH_str, 'FontSize',14, 'FontWeight', 'bold');
end
plot(locx(heads),locy(heads),'s', 'MarkerEdgeColor','b', 'MarkerFaceColor', 'b', 'MarkerSize', 12);
plot(0, 0, '^', 'MarkerEdgeColor','b', 'MarkerFaceColor', 'b', 'Markersize', 12);
text(0.2, -0.1, 'Sink', 'FontSize',14,'FontWeight', 'bold');    

% plot the shortest path within cluster
for i_node = 2:initparams.N+1
    if pred_n2c(i_node) ~= 0  % otherwise node i_node is a cluster head
        line([locx(i_node) locx(pred_n2c(i_node))], ...
                [locy(i_node) locy(pred_n2c(i_node))], 'color', 'r', 'linewidth', 2);
    end
end

% plot the backbone routing tree
for i_cls = 1:num_cls
    this_path = path_c2c{i_cls};
    for n = 1:length(this_path)-1
        line([locx(this_path(n)) locx(this_path(n+1))], ...
            [locy(this_path(n)) locy(this_path(n+1))], 'color', 'b', 'linewidth', 3);
    end
end

