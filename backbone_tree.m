function [pred_c2c, backbone_nodes, dist_backbone, dist_c2c, path_c2c] = backbone_tree(grap_params, cls_params)
%{
    @description: build a backbone routing tree to connect all cluster heads to a sink node
    @params: @grap_params, @cls_params
    @return: 
        @pred_c2c: predecessor cluster head of each cluster head
        @backbone_nodes: the nodes in the backbone tree
        @dist_backbone: distance (i.e., the number of hops) along the backbone tree
        @dist_c2c: distance (i.e., the number of hops) from a CH to its predecessor CH
        @path_c2c: path from a CH to its predecessor CH
    @library func: graphshortestpath, graphminspantree
    @author: Ruitao Xie, City University of Hong Kong
%}

%{
    first build a complete graph, where nodes are cluster heads, and edges between any pair of cluster heads are
    their shortest paths;
    second compute a minimum spanning tree (MST) on this complete graph;
    third build a backbone tree from the MST
%}

CH = cls_params.head(:);
num_cls = length(CH);
core_nodes = [1 CH'];
num_CN = length(core_nodes); % the sink node is included
dist_CN2CN_all = inf(num_CN, num_CN);
path_CN2CN_all = cell(num_CN, num_CN);
path_c2c = cell(1, num_cls);
dist_c2c = zeros(1, num_cls);
backbone_nodes = [];

% build a complete graph 
for i_cn = 1 : num_CN-1
    for j_cn = i_cn + 1 : num_CN
        [dist_CN2CN_all(i_cn, j_cn) path_CN2CN_all{i_cn, j_cn}] = graphshortestpath(grap_params.adj_mtr, core_nodes(i_cn), core_nodes(j_cn), 'directed', false);
    end
end
adj_CN2CN = triu(dist_CN2CN_all, 1) + triu(dist_CN2CN_all, 1)';

% compute a mst
[~, pred] = graphminspantree(sparse(adj_CN2CN), 1);
pred_c2c = core_nodes(pred(2:num_CN));

% build a backbone tree from the mst
for i_cn = 2 : num_CN
    if i_cn < pred(i_cn)
        this_path = path_CN2CN_all{i_cn, pred(i_cn)};
    else
        this_path = path_CN2CN_all{pred(i_cn), i_cn};
    end
    path_c2c{i_cn-1} = this_path;
    dist_c2c(i_cn-1) = length(this_path) - 1;
    assert( dist_c2c(i_cn-1) == adj_CN2CN(i_cn, pred(i_cn)) );
    backbone_nodes = [backbone_nodes this_path];
end
backbone_nodes = unique(backbone_nodes);
dist_backbone = length(backbone_nodes)-1;
assert(dist_backbone <= sum(dist_c2c), 'something wrong in calculation of dist between CHs!');
