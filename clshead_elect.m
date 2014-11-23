function cls_params = clshead_elect(initparams, grap_params, cls_params)
%{
    @description: Given the geographic location of the central point of a 
        cluster-area, the sensor node that is the closest to the central
        point will become the CH.
    @author: Ruitao Xie, City University of Hong Kong
%}
[i_max j_max] = size(cls_params.locx);
head = zeros(i_max, j_max);

for i = 1:i_max
    for j = 1: j_max
        [~, id] = min((grap_params.locationx - cls_params.locx(i, j)).^2 + (grap_params.locationy - cls_params.locy(i, j)).^2);
        head(i, j) = id;
    end
end
cls_params.head = head;
