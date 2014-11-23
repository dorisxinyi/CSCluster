function [cost_spt, num_decendants_percore, dst_shell] = SPT_forest(core_nodes, dist)
num_nodes = size(dist,1);

shell_nodes = 1:num_nodes;
shell_nodes = setdiff(shell_nodes, core_nodes);
dist_shell = zeros(1, length(shell_nodes));
dst_shell = zeros(1, length(shell_nodes));

for k = 1:length(shell_nodes)
    this_src = shell_nodes(k);
    dist_src = dist(this_src, :);
    dist_2core = dist_src(core_nodes);
    [dist_shell(k), id] = min(dist_2core);
    dst_shell(k) = core_nodes(id);
end

cost_spt = sum(dist_shell);
num_decendants_percore = zeros(1, length(core_nodes));
for i = 1:length(core_nodes)
    num_decendants_percore(i) = nnz(dst_shell==core_nodes(i));
end

return