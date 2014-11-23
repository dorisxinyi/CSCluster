function [cost_mst, leaf_nodes, pred_nodes] = MST(core_nodes, grap_params)

num_core_nodes = length(core_nodes);
core_adj = zeros(num_core_nodes);
for h = 1:num_core_nodes-1
    for g = h+1:num_core_nodes
    core_adj(h, g) = grap_params.adj_mtr(core_nodes(h), core_nodes(g));
    end
end
core_adj = core_adj + core_adj';

[tree, pred_idx] = graphminspantree(sparse(core_adj));
[src dst] = find(tree > 0);

leaf_id = setdiff(src, dst);
leaf_nodes = core_nodes(leaf_id);

cost_mst = num_core_nodes - 1;

pred_nodes = [0 core_nodes(pred_idx(2:num_core_nodes))];
return