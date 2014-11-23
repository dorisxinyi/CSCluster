function plot_topology(initparams, grap_params)
%{
    @description: plot topology according to @initparams and @grap_params
    @required: NA
    @author: Ruitao Xie City University of Hong Kong
%}

N = initparams.N;
L = initparams.length;
W = initparams.width;
locationx = grap_params.locationx;
locationy = grap_params.locationy;
neighbor = grap_params.neighbor;

figure(1)
hold on
grid off
axis([0 L 0 W]);
axis off
axis equal;
set(gcf, 'color', 'w');

% plot a frame
line([0 L], [W W], 'color', 'k', 'lineWidth', 1);
line([L L], [0 W], 'color', 'k', 'lineWidth', 1);
line([0 0], [0 W], 'color', 'k', 'lineWidth', 1);
line([0 L], [0 0], 'color', 'k', 'lineWidth', 1);

% plot nodes
plot(locationx, locationy, 'o', 'MarkerEdgeColor','b', 'MarkerFaceColor', 'b', 'Markersize', 3);
plot(0, 0, '^', 'MarkerEdgeColor','b', 'MarkerFaceColor', 'b', 'Markersize', 10);
text(0.2, -0.3, 'sink');

% plot edges
for i = 1:N+1
    neigh_temp = neighbor{i};
    num = length(neigh_temp);
    for k = 1:num
        j = neigh_temp(k);
        line([locationx(i) locationx(j)], [locationy(i) locationy(j)]);
    end
end