function [num_tran_spt, num_tran_sptcs] = spt_wo_cs(initparams, grap_params, sp_dist)
%{
    @description: SPT without CS and SPT with hybrid CS
    @params: 
        @initparams, @grap_params, @sp_dist
    @return: 
        @num_tran_spt: the number of transmissions of SPT without CS
        @num_tran_sptcs: the number of transmissions of SPT with hybrid CS
    @author: Ruitao Xie, City University of Hong Kong
%}

% SPT without CS
num_tran_spt = sum(sp_dist(:,1));
[~, ~, pred] = graphshortestpath(grap_params.adj_mtr, 1, 'directed', false);
spt_tree = zeros(initparams.N+1);
for i = 2:initparams.N+1
    spt_tree(pred(i), i) = 1;
end
bio_spt_tree = biograph(spt_tree);
if initparams.showtree
    bio_spt_tree.view;
end

% SPT with hybrid CS
num_desc_nodes = zeros(1, initparams.N+1); % num of descendants: the node itself is included
for i = 1:initparams.N+1
    num_generations = 1;
    while 1
        temp = length(getdescendants(bio_spt_tree.nodes(i), num_generations));
        if temp == num_desc_nodes(i)
            break;
        else
            num_desc_nodes(i) = temp;
            num_generations = num_generations + 1;
        end
    end
end
num_desc_nodes(1) = 0;
assert(sum(num_desc_nodes) == num_tran_spt);
num_tran_nodes = num_desc_nodes;
num_tran_nodes(num_desc_nodes >= initparams.M) = initparams.M;

num_tran_sptcs = sum(num_tran_nodes);
if initparams.showtree
    set(bio_spt_tree.nodes(num_desc_nodes >= initparams.M),'Color',[1 0.4 0.4]);
    view(bio_spt_tree);
end
