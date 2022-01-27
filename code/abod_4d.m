close all
clc, clear

% % Angle Based Outlier Detection
% % Authors: Hans-Peter, Kriegel Matthias, Schubert Arthur Zimek
% % Original paper :
% % Angle-Based Outlier Detection in High-dimensional Data In KDD2008
% % Website : http://www.dbs.ifi.lmu.de/
% % e-mail : {kriegel,schubert,zimek}@dbs.ifi.lmu.de

% DB : Iris Data Set https://archive.ics.uci.edu/ml/datasets/iris

% Multivariate, Real datas for classification, 150 instances, 4 attributes
% 1. sepal length in cm
% 2. sepal width in cm
% 3. petal length in cm
% 4. petal width in cm

% 3 classes iris, 50 instances chacunes.
% 5. class:
% -- Iris Setosa
% -- Iris Versicolour
% -- Iris Virginica

% 1 classe linéairement séparable des 2 autres, les autres non.
% On veut Predire la classe d'un iris

% The 35th sample should be: (4.9,3.1,1.5,0.2) "Iris-setosa" where the error is in the fourth feature
% Actual : (4.9,3.1,1.5,0.1)
% The 38th error too
% 50 premiers éléments de classe 1, voir si détecte le 35
% 50 2nd éléments de classe 2 voir si détecte le 38
% Tous, voir si 35 et 38 sont détectés
% pas nécessairement détecté car juste diff de un autre dataset similaire
% 4D : 118 132 119 136 123
% 3D : 118 132 119 42 61
%[118;132;119;42;61;]136;107;106;110;123] 10 premiers index

% clase 1 : 45 15 16 23 19
% clase 2 : 99 61 58 84 94
% clase 3 : 107 108 132 119 120

% === si features de 2 à 4 : [119;118;132;42;123;106;61;110;16]

load('iris.mat', '-mat');

A=iris(:,3:4);
mean_DB = mean(A)
std_DB = std(A)
max_DB = max(A)
min_DB = min(A)
%A=iris(:,[1;2;5]);

B=A;                                             % Data par défaut
[A, ia, ic] = unique(A,'rows');   %enlver sort               % enlever les répétitions (il en enlève + si en 2D
instance_number = size(ia, 1);
origin_instance_number = size(ic, 1);
var_array = zeros(instance_number, 1);           % Pour stocker, pour chacun des points la Variance des angles qu'il forme avec les vecteurs en direction des autres points

for i=1:instance_number % Pour chaque point
    M=[];
    for j=1:instance_number                      % Pour chaque point A
        if j==i                                  % Pour chaque 2eme point B différent de A
            continue
        end
        for k=j+1:instance_number 	             % Pour chaque 3eme point C différent de A et B
            if k==i
                continue
            end
            vector1 = A(j,:) - A(i,:);          % Calcul des vecteurs associé AB et AC
            vector2 = A(k,:) - A(i,:);
            norm_vector1Xnorm_vector2 = (norm(vector1) *norm(vector2))^2; % Le produit de leur norme au carré pour normaliser
            vector1Xvector2T = vector1 * vector2';                        % Leur produit scalaire
            M=[M,vector1Xvector2T/norm_vector1Xnorm_vector2];             % Pour stocker tous les différents angles formés, avec toutes ces pairs, pour un point donné
        end                        
    end
    var_array(i) = var(M);                                                % puis tu calcul la variance de ses angles
end

min_var_array = min(var_array);                                                                                                                                       
abof = (var_array - min_var_array) / (max(var_array) - min_var_array); % Enlever ça
%abof = var_array;
origin_abof = zeros(origin_instance_number, 1);

for i=1:origin_instance_number
origin_abof(i, 1) = abof(ic(i, 1), 1);
end

abof = origin_abof;
[yepee, suspicious_index] = sort(abof);                 % Ascending order
% suspicious_index(1:5)
% for i = 1:5
%     A(suspicious_index(i),:)
% end

A=B;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_outlier = 10
S=size(A);
if S(2)==2
figure; hold on;                         % plot 2D avec vrai valeurs et en rouge les outliers
scatter(A(:,1),A(:,2),'ob')
scatter(A(suspicious_index(1:num_outlier),1),A(suspicious_index(1:num_outlier),2),'or')
scatter(A(suspicious_index(end-num_outlier:end),1),A(suspicious_index(end-num_outlier:end),2),'og')

figure; hold on; grid;                  
scatter3(A(:,1),A(:,2),abof,'ob')
scatter3(A(suspicious_index(1:num_outlier),1),A(suspicious_index(1:num_outlier),2),yepee(1:num_outlier),'*r') % vision 3D en z le abof
title('ABOF des iris en fonctions des features pétale');
xlabel('largeur petale (cm)'); ylabel('longuer petale (cm)'); zlabel('abof');
legend('Instances','Outlier detecté')
view(3);

elseif S(2)==3                                  % plot 3D avec vrai valeurs en rouge les outliers
figure; hold on; grid;
scatter3(A(:,1),A(:,2),A(:,3),'ob')
scatter3(A(suspicious_index(1:num_outlier),1),A(suspicious_index(1:num_outlier),2),A(suspicious_index(1:num_outlier),3),'*r')
title('Plot 3 features iris et 20 premiers outlier détectés');
xlabel('largeur sepale (cm)'); ylabel('longuer petale (cm)'); zlabel('largeur petale (cm)');
legend('Instances','Outlier detecté')
view(3);
end