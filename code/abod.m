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

load('iris.mat', '-mat');

A=iris(:,[1;2]);
%A=iris(:,[1;2;5]);
B=A;
[A, ia, ic] = unique(A,'rows'); % enlever les répétitions
instance_number = size(ia, 1);
origin_instance_number = size(ic, 1);
var_array = zeros(instance_number, 1);

for i=1:instance_number % Pour chaque point
    M=[];
    for j=1:instance_number % B différent de A
        if j==i
            continue
        end
        for k=j+1:instance_number % C différent de A et b
            if k==i
                continue
            end
            vector1 = A(j,:) - A(i,:); % Tu prends toutes les pairs de points en calculant leurs vecteurs
            vector2 = A(k,:) - A(i,:);
            norm_vector1Xnorm_vector2 = (norm(vector1) *norm(vector2))^2; % Le produit de leur norme au carré
            vector1Xvector2T = vector1 * vector2';                        % Leur produit scalaire
            M=[M,vector1Xvector2T/norm_vector1Xnorm_vector2];             % Pour stocker tous les différents angles formé, avec toutes ces pairs, pour un point donné
        end                        
    end
    var_array(i) = var(M);                                                % puis tu calcul la variance de ses angles
end

min_var_array = min(var_array);                                                                                                                                       
abof = (var_array - min_var_array) / (max(var_array) - min_var_array);
origin_abof = zeros(origin_instance_number, 1);

for i=1:origin_instance_number
origin_abof(i, 1) = abof(ic(i, 1), 1);
end

abof = origin_abof;
[yepee, suspicious_index] = sort(abof);
A=B;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S=size(A);
if S(2)==2
figure; hold on;
scatter(A(:,1),A(:,2),'ob')
scatter(A(suspicious_index(1:10),1),A(suspicious_index(1:10),2),'or')
scatter(A(suspicious_index(end-10:end),1),A(suspicious_index(end-10:end),2),'og')

figure; hold on; grid;
scatter3(A(:,1),A(:,2),abof,'ob')
scatter3(A(suspicious_index(1:10),1),A(suspicious_index(1:10),2),yepee(1:10),'*r')
view(3);

elseif S(2)==3
figure; hold on; grid;
scatter3(A(:,1),A(:,2),A(:,3),'ob')
scatter3(A(suspicious_index(1:10),1),A(suspicious_index(1:10),2),A(suspicious_index(1:10),3),'*r')
view(3);
end