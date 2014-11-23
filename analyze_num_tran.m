function [num_tran_opt, num_tran_fn] = analyze_num_tran(initparams)
%{
    @description: compute the analytical value of number of transmissions
        by the clustering with hybrid cs
    @author: Ruitao Xie, City University of Hong Kong
%}
num_cls = 1:20;
num_nodes_pcls = initparams.N ./ num_cls;
diameter = sqrt(num_nodes_pcls ./ (initparams.lambda * initparams.unit^2));
cons1 = initparams.N/3 - initparams.M/2;
cons2 = initparams.N * initparams.M / (initparams.lambda * initparams.unit^2) - initparams.N/3;
num_tran_fn = cons1 .* diameter + cons2 ./ diameter;
diameter_opt = sqrt(cons2/cons1);
num_tran_opt = cons1 .* diameter_opt + cons2 ./ diameter_opt;
