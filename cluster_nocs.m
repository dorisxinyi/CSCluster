function num_tran = cluster_nocs(initparams, grap_params, cls_params, dist_n2c, idx_n2c)
%{
    @description: clustering without CS
    @params: 
        @initparams: the initialization parameters 
        @grap_params: the parameters of graph
        @cls_params: information on cluster heads
        @dist_n2c: the distance (the number of hops) from each node to its closest cluster head
        @idx_n2c: the index of the cluster head that each node connects to
    @return: 
        @num_tran: the number of transmissions
    @author: Ruitao Xie, City University of Hong Kong
%}

[dist_2sink, ~, ~] = graphshortestpath(grap_params.adj_mtr, 1, 'directed', false);
[i_max j_max] = size(cls_params.head);

num_nodes_percls = zeros(1, i_max*j_max);
for i = 1: i_max
    for j = 1:j_max
        id = sub2ind([i_max j_max], i, j);
        num_nodes_percls(id) = nnz(idx_n2c == id); % the cluster head itself is counted
    end
end
assert(sum(num_nodes_percls) == initparams.N+1, 'something wrong in calculation of the number of nodes per cluser!');
dist_CH2sink = dist_2sink(cls_params.head(:));

%{
    the first term is for transmitting the data of all nodes from cluster heads to the sink;
    the second term is for transmitting the data of member nodes from member nodes to the cluster heads.
%}

num_tran = dist_CH2sink * num_nodes_percls' + sum(dist_n2c) - dist_n2c(1);

