%{
    @description: a simulation script
    @required: topology.m, cluster_hybridcs.m, cluster_hybridcs_distr.m,
        cluster_nocs.m, optimal_tree_hybridcs.m, spt_wo_cs.m
    @author: Ruitao Xie City University of Hong Kong
%}

%% 
fileuid = randi(1e7,1);     % a random number to generate a filename
scales = 4:2:4;     % the number of nodes = scales * 100
num_scales = length(scales);
num_tran_mean = zeros(GC.ALGTYPE, num_scales);   % the number of transmissions averaged over multiple simulation rounds
num_iter_mean = zeros(GC.ITERTYPE, num_scales);  % the number of iterations to compute cluster heads averaged over multiple simulation rounds  
CI_lower = zeros(num_scales, GC.ALGTYPE);        % the confidence interval of the number of transmissions over multiple simulation rounds
CI_upper = zeros(num_scales, GC.ALGTYPE);
iter_CI_lower = zeros(num_scales, GC.ITERTYPE);  % the confidence interval of the number of iterations over multiple simulation rounds
iter_CI_upper = zeros(num_scales, GC.ITERTYPE);

%% simulation in various scales of networks
for i_scale = 1:num_scales
    % initialize simulation parameters, the meanings of parameters refer to initparams.txt
    initparams.fig = 1;
    initparams.showtree = 0;
    initparams.length = 20;
    initparams.width = 10;
    initparams.N = scales(i_scale) * 100;
    initparams.rho = 10;
    initparams.unit = 1;
    initparams.range = initparams.unit * sqrt(2);
    initparams.M = round(initparams.N / initparams.rho);
    initparams.lambda = initparams.N / (initparams.length * initparams.width);
    initparams.num_sim = 1;
    
    % initialize variables to store results
    num_tran = zeros(GC.ALGTYPE, initparams.num_sim);
    num_tran_2cls = zeros(20, initparams.num_sim);
    num_iter = zeros(GC.ITERTYPE, initparams.num_sim);
    loads = cell(GC.LOADTYPE, initparams.num_sim);
    
    for i_sim = 1:initparams.num_sim
        fprintf(1,'%d th instance\n',i_sim);
        grap_params = topology(initparams);
        sp_dist = graphallshortestpaths(grap_params.adj_mtr);
        
        % compute the optimal number of clusters by analytical model
        num_nodes_pcls = (3*initparams.M - initparams.lambda)/(1-3/(2*initparams.rho));
        num_cls_opt = round(initparams.N/num_nodes_pcls);
               
        % simulate various methods
        % clustering with hybrid CS centralized algorithm
        [num_tran(GC.ALG_CLS_HYBCS, i_sim), loads{GC.LOAD_CLS_HYBCS, i_sim}, num_iter(GC.ITER_CLS_HYBCS, i_sim), cls_params] = cluster_hybridcs(initparams, grap_params, sp_dist, num_cls_opt);
        
        % clustering with hybrid CS distributed algorithm
        [num_tran(GC.ALG_CLS_HYBCS_DISTR, i_sim), ~, dist_n2c, idx_n2c] = cluster_hybridcs_distr(initparams, grap_params, num_cls_opt);
          
        % clustering without CS
        num_tran(GC.ALG_CLS, i_sim) = cluster_nocs(initparams, grap_params, cls_params, dist_n2c, idx_n2c);
        
        % optimal tree with hybrid CS
        [num_tran(GC.ALG_OPTTREE_CS, i_sim), loads{GC.LOAD_OPTTREE_CS, i_sim}, num_iter(GC.ITER_OPTTREE_CS, i_sim)] = optimal_tree_hybridcs(grap_params, initparams, sp_dist);
        
        % SPT without CS and SPT with hybrid CS
        [num_tran(GC.ALG_SPT, i_sim), num_tran(GC.ALG_SPT_CS, i_sim)] = spt_wo_cs(initparams, grap_params, sp_dist);  
        
    end
    % postprocessing 1: compute mean of the number of transmissions as well as the analytical value of number of transmissions
    num_tran_mean(:, i_scale) = mean(num_tran, 2);
    [num_tran_opt, num_tran_fn] = analyze_num_tran(initparams);
    num_tran_mean(GC.ALG_ANALY, i_scale) = num_tran_opt; 
    
    % postprocessing 2: compute the confidence interval
    [~,~,muci,~] = normfit(num_tran');
    CI_lower(i_scale, :) = muci(1, :);
    CI_upper(i_scale, :) = muci(2, :);  
    
    % postprocessing 3: compute mean and confidence interval of the number of iterations
    num_iter_mean(:, i_scale) = mean(num_iter, 2);
    [muhat,~,muci,~] = normfit(num_iter');
    iter_CI_lower(i_scale, :) = muci(1, :);
    iter_CI_upper(i_scale, :) = muci(2, :);  
    
    % postprocessing 4: compute the reduction ratio of the number of transmissions
    num_temp = num_tran_mean - repmat(num_tran_mean(1,:),size(num_tran_mean,1),1);
    num_tran_ratio = num_temp./num_tran_mean * 100;
    
    % postprocessing 5: write the results in a file
    filename = sprintf('%d_len%d_wide%d_RHO%d_N%d', fileuid, initparams.length, initparams.width,...
        initparams.rho, initparams.N);
    save(filename);
end