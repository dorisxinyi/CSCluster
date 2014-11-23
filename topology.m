function grap_params = topology(initparams)
%{
    @description: generate topology according to @initparams
    @return: @grap_params
    @required: connectivity.m plot_topology.m
    @author: Ruitao Xie City University of Hong Kong
%}
%{
    The topology consists of N sensor nodes and a sink node which locates 
    at the corner of the field, so there are N+1 nodes in total.
    The variable @adj_mtr is N+1 by N+1.
%}

N = initparams.N;
L = initparams.length;
W = initparams.width;
r = initparams.range;

unconnect = 1;
while unconnect
    adj_mtr = zeros(N+1);
    
    % generate randomly according to the Uniform distribution
    locationx = [0 rand(1, N)] * L;
    locationy = [0 rand(1, N)] * W;
    locations = [locationx; locationy]';
    dist_mtr = squareform( pdist(locations,'euclidean') );
    adj_mtr(dist_mtr > 0 & dist_mtr <= r) = 1;

    % check the connectivity of the graph
    connect = connectivity(adj_mtr);
    if connect
        unconnect = 0;
    end    
end

% compute adjacent list
neighbor = cell(N+1, 1);
for i = 1:N+1
    neighbor{i} = find(adj_mtr(i,:));
end

grap_params.adj_mtr = sparse(adj_mtr);
grap_params.neighbor = neighbor;
grap_params.locationx = locationx;
grap_params.locationy = locationy;
grap_params.num_nodes = N+1;

% plot topology
if initparams.fig
    plot_topology(initparams, grap_params);
end

%{
    % read in from a file
    flocid  = fopen('location.txt', 'r');
    locationx = fscanf(flocid, '%g %g', [1 N+1]);
    locationy = fscanf(flocid, '%g %g', [1 N+1]);
    fclose(flocid);
%}
%{
    % write to a file
    flocid = fopen('location.txt', 'w');
    fprintf(flocid, '%.2f\t', locationx);
    fprintf(flocid, '\n');
    fprintf(flocid, '%.2f\t', locationy);
    fclose(flocid);
%}
