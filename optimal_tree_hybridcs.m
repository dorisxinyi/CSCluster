function [cost, loads, num_iter, core_nodes] = optimal_tree_hybridcs(grap_params, initparams, sp_dist)
%{
    @description: optial tree with hybrid CS
        a greedy algorithm in L. Xiang, J. Luo, and A. Vasilakos, “Compressed Data Aggregation
        for Energy Efficient Wireless Sensor Networks,” Proc. IEEE Sensor, Mesh, and Ad Hoc Comm. and Networks (SECON ’11), pp. 46-
        54, June 2011.
    @required: MST.m SPT_forest.m
    @author: Ruitao Xie City University of Hong Kong
%}

M = initparams.M;
num_nodes = initparams.N + 1;       % a sink node has an index of 1;
core_nodes = 1;

core_neigh_nodes = grap_params.neighbor{1};
cost_temp = inf;
cost = inf;
node_cand = 0;

pred_tree = zeros(1, initparams.N+1);
mst_spf_tree = zeros(initparams.N+1);
num_desc_nodes = zeros(1, initparams.N+1);

num_iter = 0;

while ~isempty(core_neigh_nodes)
    for i = 1:length(core_neigh_nodes)
        node_test = core_neigh_nodes(i);
        core_nodes_test = [core_nodes node_test];
        
        num_iter = num_iter + 1;
        
        [cost_mst, leaf_nodes] = MST(core_nodes_test, grap_params);
        [cost_spt, num_decendants_percore] = SPT_forest(core_nodes_test, sp_dist);
        
        [~, loc_leaf_nodes] = ismember(leaf_nodes, core_nodes_test);
        num_decendants_perleaf = num_decendants_percore(loc_leaf_nodes);
        
        if cost_mst + cost_spt <= cost_temp && min(num_decendants_perleaf) >= M-1
            cost_temp = cost_mst + cost_spt;
            cost = cost_mst * M + cost_spt;
            node_cand = node_test;
        end
    end
    
    if node_cand == 0
        break;
    end
    core_nodes = [core_nodes node_cand];
    
    core_neigh_nodes = [core_neigh_nodes grap_params.neighbor{node_cand}];
    core_neigh_nodes = setdiff(core_neigh_nodes, core_nodes);
    core_neigh_nodes = unique(core_neigh_nodes);
    node_cand = 0;
end

%
shell_nodes = 1:num_nodes;
shell_nodes = setdiff(shell_nodes, core_nodes);
[~, num_decendants_percore, dst_shell] = SPT_forest(core_nodes, sp_dist); % dst_shell represents the destination core node of each shell node;

for i_node = 1:length(core_nodes)
    this_src = core_nodes(i_node);
    [~, ~, pred_spt] = graphshortestpath(grap_params.adj_mtr, this_src, 'directed', false);
    pred_tree(shell_nodes(dst_shell == this_src)) = pred_spt(shell_nodes(dst_shell == this_src));
end
[~, leaf_nodes, pred_mst] = MST(core_nodes, grap_params);
pred_tree(core_nodes) = pred_mst;

for i_node = 2:num_nodes
    mst_spf_tree(pred_tree(i_node), i_node) = 1;
end

assert(nnz(mst_spf_tree == 1) == num_nodes - 1); % the number of edge is the number of sensor nodes except the sink;

dist_tree = graphshortestpath(sparse(mst_spf_tree + mst_spf_tree'), 1, 'directed', false);
deepth_tree = max(dist_tree);

bio_tree = biograph(mst_spf_tree);
set(bio_tree.nodes(core_nodes),'Color',[0.8 0.8 0.8]);
if initparams.showtree
    bio_tree.view;
end

for i = 1:num_nodes
    num_desc_nodes(i) = length(getdescendants(bio_tree.nodes(i), deepth_tree));
end
[~,leaf_idx] = ismember(leaf_nodes, core_nodes);

assert(nnz(num_desc_nodes(leaf_nodes) ~=  num_decendants_percore(leaf_idx) + 1) == 0, 'something wrong in calcualting the number of descendant nodes!');
loads = num_desc_nodes;
loads(core_nodes) = M;
loads(1) = 0;
assert(sum(loads) == cost);
return
