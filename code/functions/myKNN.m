function [knn, knn_idx, d] = myKNN(point ,x, k)
% INPUT :
%   x : data_matrix (N rows, M columns = features/dim)
%   k : number of nearest neighboors desired
% OUTPUT :
%   knn : the k nearest neighboors desired 
%   knn_idx : leurs index
%   d : leurs distances



% Algo
% Find the Euclidean or Manhattan distance between newpoint and every point in x.
% Sort these distances in ascending order.
% Return the k data points in x that are closest to newpoint.

% Nombre de points
N = size(x,1); 

% Stock la distance de chaque point à mon point (Euclidienne)
dists = sqrt(sum(bsxfun(@minus, x, point).^2, 2));

% TRADUCTION DE LA LIGNE PRECEDENTE %
% dists = zeros(N,1);
% for idx = 1 : N
%     dists(idx) = sqrt(sum((x(idx,:) - newpoint).^2));
% end

% On ordonne les distances ( d = distances ; ind = index)
[d,ind] = sort(dists);
d = d(2:end,:);

% On prend l'indice des k plus proches voisins (on en prend un de plus et on supprime lke point lui même)
knn_idx = ind(2:k+1);
knn = x(knn_idx,:);

% manhattan dist
%dists = sum(abs(bsxfun(@minus, x, newpoint)), 2);
% N = size(x,1);
% dists = zeros(N,1);
% for idx = 1 : N
%     dists(idx) = sum(abs(x(idx,:) - newpoint));
% end


end

