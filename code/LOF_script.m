clear all;
close all;
clc;

% FAIRE F5 et ça marche
demo_matlab_cours_Outliers_partie3();

function [suspicious_index,lof,normal,outliers]=demo_matlab_cours_Outliers_partie3()
k = 10;
threshold = 2;
num_outlier = 10;

% 2D petale = [23,14,25,45,99,119,58,94,135,44]
% === si features de 2 à 4 : ABOD[119;118;132;42;123;106;61;110;16]

% LOF k = 5
%   14    23    25    42    65   107   110   118   119   132

% LOF k = 10
% 2 features petales :  14    23    25    44    45    58    94    99   119   135
%   16    23    25    42    69    99   118   119   123   132
% 4 features : 14    15    16    23    42    58    61    94    99   107

% LOF k = 15
% 15    16    23    34    42    99   118   119   123   132

% LOF k = 20
% 16    33    34    42    58    61    94    99   118   119


load('iris.mat', '-mat'); 
A=iris(:,3:4);
N = size(A,1);

[suspicious_index,lof] = LOF(A, k);

% outliers = test.data(lof>=threshold, :);         % si lof threshold
n_outliers = sort(suspicious_index(1:num_outlier))      % index 10 premiers lof

dim = size(A,2);

% if (dim==2)
% figure; hold on; grid;
% scatter3(A(:,1),A(:,2),A(:,3),'ob')
% scatter3(A(suspicious_index(1:num_outlier),1),A(suspicious_index(1:num_outlier),2),A(suspicious_index(1:num_outlier),3),'*r')
% title('Plot 3 features iris et 10 premiers outlier détectés');
% xlabel('largeur sepale (cm)'); ylabel('longuer petale (cm)'); zlabel('largeur petale (cm)');
% legend('Instances','Outlier detecté')
% view(3);
% end

figure; hold on;
plot(1:N ,lof,'o')
xlabel('Index du sample'); ylabel('LOF');
title('LOF de chacun des samples iris, 4 features');

if (dim==3)
figure; hold on; grid;
scatter3(A(:,2),A(:,3),A(:,4),'ob')
scatter3(A(suspicious_index(1:num_outlier),2),A(suspicious_index(1:num_outlier),3),A(suspicious_index(1:num_outlier),4),'*r')
title('Plot 4 features iris et 10 premiers outlier détectés, k=10');
xlabel('largeur sepale (cm)'); ylabel('longuer petale (cm)'); zlabel('largeur petale (cm)');
legend('Instances','Outlier detecté')
view(3);
end

figure; hold on; grid;                  
scatter3(A(:,1),A(:,2),lof,'ob')
scatter3(A(suspicious_index(1:num_outlier),1),A(suspicious_index(1:num_outlier),2),lof(suspicious_index(1:num_outlier)),'*r') % vision 3D en z le abof
title('LOF des iris en fonctions des features pétale');
xlabel('largeur petale (cm)'); ylabel('longuer petale (cm)'); zlabel('LOF');
legend('Instances','Outlier detecté')
view(3);

%test = load('TestData2_LOF.mat');
%[suspicious_index,lof] = LOF(test.data, k);
% outliers = test.data(lof>=threshold, :);
% normal = test.data(lof<threshold, :);
% figure;
% hold on;
% scatter(normal(:, 1), normal(:, 2), 'bo');
% scatter(outliers(:, 1), outliers(:, 2), 'r*');
% xlabel('test.data(:,1)');ylabel('test.data(:,2))');title('LOF')
% figure;
% hold on;grid;
% scatter3(test.data(:,1),test.data(:,2),lof);
% xlabel('test.data(:,1)');ylabel('test.data(:,2))');zlabel('LOF')
% scatter3(outliers(:,1),outliers(:,2),lof(lof>=threshold),'r*');
% view(3);

end

function [suspicious_index,lof] = LOF(A, k)
%
% Local Outlier Factor
% Authors: Markus M. Breunig, Hans-Peter Kriegel, % Raymond T. Ng, J?rg Sander
% Original paper : % LOF: Identifying Density-Based Local Outliers
% e-mail : { breunig | kriegel | sander } % @dbs.informatik.uni-muenchen.de rng@cs.ubc.ca
% Programmer: Yi-Ren Yeh(yirenyeh@gmail.com) % modified by: Zi-Wen Gui(evan176@hotmail.com)
%
%
% Inputs
%   A: the data matrix, each row represents an instance
%   k: the number of nearest neighbors, specified as an integer or
%   as a fraction of the total number of data points
%
% Outputs
%   lof: the local outlier factor for each instance
%   suspicious_index: the ranking of instances according to their suspicious score
%   For example, suspicious_index(i)=j means the

% Nombre de samples
N = size(A,1);

% On stock les indices des k voisins de chaque point
index_knn_chaque_point = zeros(N,k);

% On calcul la lrd de chaque point
lrd_data = zeros(1,N);

% Pour chaque point :
for i = 1:N

% On choisit un point
point = A(i,:);

%% Find the k nearest neighbors
[knn, knn_idx, dist] = myKNN(point, A, k);
index_knn_chaque_point(i,:) = knn_idx;

%% Get k-distance (distance entre le point et son k-ème voisin, on prend la k-ème distance donc lol)
k_dist = dist(k);

%% RD-Distance pour chaque voisin (max entre K-Distance du voisin et la distance avec le voisin)

% On stock les RD-Distance du point en question avec chacun de ses voisins
RDs_point_avec_ses_voisins = zeros(1,k);
for num_voisin = 1:k
    index_voisin = knn_idx(num_voisin);
    voisin = A(index_voisin,:);
    [RD_dist_avec_voisin] = RD_k_distance(A,point,voisin,k);  
    RDs_point_avec_ses_voisins(num_voisin) = RD_dist_avec_voisin;
end

%% LRD du point (moyenne des RDs avec ses voisins, puis on prend l'inverse)
mean_RDs = mean(RDs_point_avec_ses_voisins);
LRD_point = 1/mean_RDs;

% On stock la lrd du point
lrd_data(i) = LRD_point;

end %%% FIN CALCUL LRD POUR CHAQUE POINTS

%% CALCUL LOF (Moyenne des k Rapports (LRD_point / LRD_voisin) avec ses k voisins)
lof_data = zeros(1,N);

for i = 1:N         % Pour chaque point
    
    indice_point = i;
    lrd_voisins = zeros(1,k);   % On va stocker la lrd de ses k voisins
    
    for j=1:k                   % Pour chacun de ses voisins
        num_du_voisin = j;
        index_general_voisin = index_knn_chaque_point(indice_point,num_du_voisin);
        lrd_voisins(num_du_voisin) = lrd_data(index_general_voisin);   % On prend la lrd de chacun de ses voisins, en cherchant la lrd dans les datas avec l'index du voisin en question
    end
    
    rapports_lrd_voisins_lrd_point = lrd_voisins / lrd_data(indice_point); % On calcul les rapport lrd des voisins avec lrd du point
    
    lof_data(i) = mean(rapports_lrd_voisins_lrd_point); % La moyenne des rapports (lrd_voisin/lrd_point = LOF)
    
end %%% FIN DU CALCUL DU LOF POUR TOUS LES POINTS

lof = lof_data;

% On trie les LOFs de chaque point
[~,suspicious_index]=sort(lof_data,'descend');


% %Get row length of matrix A
% n = length(A(:,1));
% %Initialize lrd_value vector
% lrd_value = zeros(n,1);
% %Calculate lrd for each elements
% 
% 
% for i = 1:n
%     lrd_value(i) = lrd(A, i, k_dist, k_index, numneigh(i));
% end
% %Initialize lof vector
% lof = zeros(n,1);
% %Calculate LOF
% for i = 1:n
%     lof(i) = sum(lrd_value(k_index{i})/lrd_value(i))/numneigh(i);
% end
% %Indices from sorting lof are the suspicious score rankings
% [~,suspicious_index]=sort(lof,'descend');


end
%=========================================================================
function lrd_value = lrd(A, index_p, k_dist,k_index, numneighbors)
%Calculate the reachability distance for nearest neighbors
Temp = repmat(A(index_p,:), numneighbors, 1) - A(k_index{index_p}, :);
Temp = sqrt(sum(Temp.^2,2));
reach_dist = max([Temp k_dist(k_index{index_p})],[],2);
%Calculate the local reachability density for each elements 

lrd_value = numneighbors/sum(reach_dist);
end

