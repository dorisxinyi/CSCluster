function [dist_n2c, idx_n2c, loads, pred_n2c] = get_loads(initparams, grap_params, cls_params, backbone_nodes)
%{
    @description: compute the number of transmissions of each node
    @params: 
        @initparams, @grap_params, @cls_params, 
        @backbone_nodes: the nodes in the backbone tree
    @return: 
        @dist_n2c: the distance from each node to the nearest CH
        @idx_n2c: the index of nearest CH (in 1...num_cls) to which each node connects
        @loads: the number of transmissions of each node, including intra-cluster transmission and inter-cluster transmission
        @pred_n2c: the predecessor node to which each node connects in its cluster
    @required: NA
    @author: Ruitao Xie, City University of Hong Kong
%}

%{
    first compute load in intra-cluster transmission, that is the number of descendant 
    nodes of each node (including itself) in the intracluster tree;
    second add the inter-cluster transmission into load.
%}
CH = cls_params.head(:);
num_cls = length(CH);
dist_2allCHs = zeros(num_cls, initparams.N+1);
pred_2allCHs = zeros(num_cls, initparams.N+1);
pred_n2c = zeros(1, initparams.N+1);
num_desc_nodes = zeros(1, initparams.N+1);
intra_tree = zeros(initparams.N+1);

for i_cls = 1:num_cls
    [dist_2allCHs(i_cls,:), ~, pred_2allCHs(i_cls,:)] = graphshortestpath(grap_params.adj_mtr, CH(i_cls), 'directed', false);
end

[dist_n2c, idx_n2c] = min(dist_2allCHs, [], 1);

for i_node = 1:initparams.N+1
    pred_n2c(i_node) = pred_2allCHs(idx_n2c(i_node), i_node);
    if pred_n2c(i_node) ~= 0
        intra_tree(pred_n2c(i_node), i_node) = 1;
    end
end
bio_intra_tree = biograph(intra_tree);
set(bio_intra_tree.nodes(CH),'Color',[1 0.4 0.4]);
if initparams.showtree
    bio_intra_tree.view;
end

for i = 1:initparams.N+1
    num_generations = 1;
    while 1
        temp = length(getdescendants(bio_intra_tree.nodes(i), num_generations));
        if temp == num_desc_nodes(i)
            break;
        else
            num_desc_nodes(i) = temp;
            num_generations = num_generations + 1;
        end
    end
end

assert(sum(num_desc_nodes) - sum(num_desc_nodes(CH)) == sum(dist_n2c));
assert(sum(num_desc_nodes(CH)) == initparams.N+1);

loads = num_desc_nodes;
% the sink node has no data to transmit, so it incurrs no load for the
% predecessor nodes
this_pred = 1;
while 1
    if this_pred == CH(idx_n2c(1))
        break;
    else
        loads(this_pred) = loads(this_pred) - 1;
        this_pred = pred_n2c(this_pred);
    end
end
loads(CH) = 0;
assert( sum(loads) == sum(dist_n2c) - dist_n2c(1));
loads(backbone_nodes) = loads(backbone_nodes) + initparams.M;
loads(1) = 0; % 1 for sink node