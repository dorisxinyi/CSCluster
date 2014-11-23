function [con unconnodes] = connectivity(costMatrix)
[n,n]=size(costMatrix);

for i = 1:n
    for j = 1:n
        if costMatrix(i,j) == 0
            costMatrix(i,j) = inf;
        end
    end
end

% all the nodes are un-visited;
visited(1:n) = 0;

distance(1:n) = inf;    % it stores the shortest distance between each node and the source node;
parent(1:n) = 0;

distance(1) = 0;
for h = 1:(n-1)
    temp = [];
    for j = 1:n
        if visited(j) == 0   % in the tree;
            temp = [temp distance(j)];
        else
            temp = [temp inf];
        end
    end
    [t, u] = min(temp);    % it starts from node with the shortest distance to the source;
    
    visited(u) = 1;        % mark it as visited;
    for v = 1:n           % for each neighbors of node u;
         if ( ( costMatrix(u, v) + distance(u)) < distance(v) )
            distance(v) = distance(u) + costMatrix(u, v);   % update the shortest distance when a shorter path is found;
            parent(v) = u;                                     % update its parent;
        end
    end
end

parent(1) = 1;
unconnodes = [];
for i = 2:n
    if parent(i) == 0
        unconnodes = [unconnodes i];
    end
end
if min(parent) == 0
    con = 0;
else
    con = 1;
end

return