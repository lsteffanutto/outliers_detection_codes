function [RD_dist] = RD_k_distance(x,point_depart,point_arrive,k)
%RD_K_DISTANCE
% On veut la Reachability Distance d'un point de départ, par rapport à un de ces
% voisins, point d'arrivé
% Return le max entre la k-distance du point d'arrivé et la distance entre
% les deux points

% INPUT :
%   x : matrice de données
%   point_depart : Point dont on veut la Reachability Distance avec le point d'arrivé
%   point_arrivée : Point voisin
%   k : nombre de voisin à prendre en compte pour le point d'arrivé

%% Distance entre les deux points
distance_arrive_depart = sqrt(sum((point_arrive - point_depart).^2));

%% K-Distance du point d'arrivé (KNN sur le point arrivé)

% Nombre de points
N = size(x,1); 

% Stock la distance de chaque point voisin à mon point d'arrivé (Euclidienne)
dists = sqrt(sum(bsxfun(@minus, x, point_arrive).^2, 2));

% TRADUCTION DE LA LIGNE PRECEDENTE %
% dists = zeros(N,1);
% for idx = 1 : N
%     dists(idx) = sqrt(sum((x(idx,:) - newpoint).^2));
% end

% On ordonne les distances ( d = distances ; ind = index)
[k_distances_point_arrive,ind] = sort(dists);
k_distances_point_arrive = k_distances_point_arrive(2:end,:);

% On prend l'indice des k plus proches voisins (on en prend un de plus et on supprime lke point lui même)
knn_idx = ind(2:k+1);
knn = x(knn_idx,:);

%% RD_k-Distance
keme_distance_du_point_arrive_egal_distance_de_son_keme_voisin = k_distances_point_arrive(k);
distance_point_arrive_a_point_depart = distance_arrive_depart;
RD_dist = max(distance_arrive_depart, k_distances_point_arrive(k));

end

