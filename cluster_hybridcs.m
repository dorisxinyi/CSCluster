function [num_tran, loads, num_iter, cls_params] = cluster_hybridcs(initparams, grap_params, sp_dist, num_cls)
%{
    @description: clustering with hybrid CS centralized algorithm
    @params: 
        @initparams: the initialization parameters 
        @grap_params: the parameters of graph
        @sp_dist: the distance (i.e., the number of hops) between each pair of nodes
        @num_cls: the number of clusters required
    @return: 
        @num_tran: the number of transmissions in total
        @loads: the number of transmissions of each node, including intra-cluster transmission and inter-cluster transmission
        @num_iter: the number of iterations to compute cluster heads
        @cls_params: information on cluster heads
    @required: backbone_tree.m, get_loads.m
    @author: Ruitao Xie, City University of Hong Kong
%}

%{
    first generate @num_cls cluster heads by k-median clustering algorithm
    second connect nodes to cluster heads by shortest paths
    third build a minumum steiner tree to connect all cluster heads to sink node
%}

% first iteratively generate @num_cls cluster heads
idx_2cent = zeros(1, initparams.N+1);
dist_2cent = zeros(1, initparams.N+1);
nodes_pcls = cell(1, num_cls);
counts_pcls = zeros(1, num_cls);
dist_sum_2clsnodes = zeros(1, initparams.N+1);

num_iter = 0; % the number of iterations
% initialize a set of centers
while 1
    new_centers = randi([1, initparams.N], 1, num_cls) + 1; % the id of sink node is 1
    if length(unique(new_centers)) == num_cls
        break;
    end
end

while 1
    num_iter = num_iter + 1;
    %fprintf(1,'%d th iteration\n', num_iter);
    centers = new_centers;
    
    % connect nodes to closest centers
    for i_node = 1:initparams.N+1
        this_dist = sp_dist(i_node, centers);
        [dist_2cent(i_node), idx_2cent(i_node)] = min(this_dist);
    end
    for i_cls = 1:num_cls
        nodes_pcls{i_cls} = find(idx_2cent == i_cls);
        counts_pcls(i_cls) = length(nodes_pcls{i_cls});
    end
    assert(sum(counts_pcls) == initparams.N+1, 'something wrong in finding the members of each cluster!');
    
    % generate a new center for each cluster
    for i_cls = 1:num_cls
        this_nodes_pcls = nodes_pcls{i_cls};
        for i_clsnode = 1:counts_pcls(i_cls)
            this_node = this_nodes_pcls(i_clsnode);
            dist_sum_2clsnodes(this_node) = sum(sp_dist(this_node, this_nodes_pcls));
        end
        [~, id] = min(dist_sum_2clsnodes(this_nodes_pcls));
        new_centers(i_cls) = this_nodes_pcls(id);
    end
    
    % converge or not
    if (nnz(centers == new_centers) == num_cls)
        break;
    end
end

cls_params.head = centers;

% build a minumum steiner tree to connect all cluster heads to sink node 
[pred_c2c, backbone_nodes, dist_backbone, ~, path_c2c] = backbone_tree(grap_params, cls_params);

% get loads
[dist_n2c, idx_n2c, loads, pred_n2c] = get_loads(initparams, grap_params, cls_params, backbone_nodes);

% compute the number of transmissions in total
num_tran = dist_backbone * initparams.M + sum(dist_n2c) - dist_n2c(1);

% plot clustering result
if initparams.fig
    plot_cluster(initparams, grap_params, cls_params, idx_n2c, pred_n2c, path_c2c);
end