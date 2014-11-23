function [num_tran, cls_params, dist_n2c, idx_n2c] = cluster_hybridcs_distr(initparams, grap_params, num_cls)
%{
    @description: clustering with hybrid CS distributed algorithm
    @params: 
        @initparams: the initialization parameters 
        @grap_params: the parameters of graph
        @num_cls: the number of clusters required
    @return: 
        @num_tran: the number of transmissions
        @cls_params: information on cluster heads
        @dist_n2c: the distance (the number of hops) from each node to its closest cluster head
        @idx_n2c: the index of the cluster head that each node connects to
    @required: clshead_elect.m, backbone_tree.m, get_loads.m
    @author: Ruitao Xie, City University of Hong Kong
%}

%{
    first compute the geographic location of the central point of each cluster-area;
    second select the sensor node that is the closest to the central point as a CH;
    third compute a backbone tree that connect all CHs to the sink node.
%}

% compute the geographic location of the central point of each cluster-area
xloc = 1:initparams.length;
yloc = 1:initparams.width;
locs = combvec(xloc, yloc)';
[~, ctrs] = kmeans(locs, num_cls);
cls_params.locx = ctrs(:,1);
cls_params.locy = ctrs(:,2);

% select the sensor node that is the closest to the central point as a CH
[cls_params] = clshead_elect(initparams, grap_params, cls_params);

% compute a backbone tree that connect all CHs to the sink node 
[~, backbone_nodes, dist_backbone] = backbone_tree(grap_params, cls_params);

% compute loads and number of transmissions
[dist_n2c, idx_n2c, loads] = get_loads(initparams, grap_params, cls_params, backbone_nodes);
num_tran = dist_backbone * initparams.M + sum(dist_n2c) - dist_n2c(1);
assert(sum(loads) == num_tran);
