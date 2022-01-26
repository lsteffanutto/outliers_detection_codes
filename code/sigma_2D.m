close all
clc, clear

%% VAR

sigma_2D_reel = 1;
mahala = 1;

% Fichier texte délimité par espaces. 
%3 ensemble comptage horaire de la circulation, enregistré à 3 intersections différentes de la ville sur 24h.
%Chaque colonne représente les données d'une intersection
trafic = load('count.dat'); % [24 x 3] = [24h x 3 intersections]
len_data = length(trafic);

%% TRAITEMENT

%% Simple ecart à la moyenne 2D sur données réelles
inter_1 = trafic(:,1);                              % Datas de la 3ème intersection (outlier = 20h 3eme intersection 257 vehicules ?)
inter_2 = trafic(:,2);
inter_3 = trafic(:,3);

x_trafic_2D = [inter_1 inter_2]'; %         [2x24]
x_trafic_3D = [inter_1 inter_2 inter_3]'; % [3x24]

% Moyennes de chaque intersections
%mu = [mean(inter_1);mean(inter_2);mean(inter_3)];
mu = [mean(inter_1); mean(inter_2)]

% Matrice de covariance de 2 intersections
sigma_cov=cov(inter_1,inter_2);
% sigma_cov3 = [var(inter_1) cov(inter_1,inter_2) cov(inter_1,inter_3);   
%               cov(inter_2,inter_1)  var(inter_2) cov(inter_2,inter_3);   
%               cov(inter_3,inter_1)  cov(inter_3,inter_2)  var(inter_3)];

%sigma_cov3 = cov(x_trafic_3D)

% Gaussienne 2D
N = @(x) exp(-(x-mu)'*inv(sigma_cov)*(x-mu)/2)/sqrt(det(sigma_cov*(2*pi)^2)); 

%% Get all the Mahalanobis Distances in a tab
Mahala_dist = @(x) sqrt((x-mu)'*inv(sigma_cov)*(x-mu)); % Mahalanobis Distance (2 variables)

tab_Mahala_dist = zeros(length(len_data));

for k = 1:len_data
    
    data_couple = x_trafic_2D(:,k);        % trafic des deux intersection pour une heure donnée
    tab_Mahala_dist(k) = Mahala_dist(data_couple);
    
end

%% Same with ~ Robust MCD
h = round((len_data + 2 + 1)/ 2) ;                          % Que un nombre d'éléments proche de la moyenne à prendre 
moy = mean(mean(trafic));                                   % generale moyenne
ecarts = mean(abs(x_trafic_2D - moy),1);
[smallestNElements smallestNIdx] = getNElements(ecarts, h)

mu_robust = zeros(1,h)
for l = 1:h
    
    element_robust = x_trafic_2D(:,smallestNIdx(l));
    mu_robust(l) = mean(element_robust); 
end
mu_robust = mean(mu_robust)

Mahala_dist_robust = @(x) sqrt((x-mu_robust)'*inv(sigma_cov)*(x-mu_robust)); % Mahalanobis distance

tab_Mahala_dist_robust = zeros(length(len_data));
for k = 1:len_data
    
    data_couple = x_trafic_2D(:,k);        % trafic des deux intersection pour une heure donnée
    tab_Mahala_dist_robust(k) = Mahala_dist_robust(data_couple);
    
end

%% FIGURES
%MD en fonction de l'index
if mahala == 1
    
figure,
plot(1:24,tab_Mahala_dist,'o');
title('MD Couples Intersections 1 et 2 pour chaque heure');
xlabel('Heure') ; ylabel('Robust Mahalanobis Distance');


figure,
plot(1:24,tab_Mahala_dist,'o'); hold on;    % MD
plot(1:24,tab_Mahala_dist_robust,'kx');
plot(1:24,3*ones(1,24),'r');        %Threshold

title('MD Couples Intersections 1 et 2 pour chaque heure');
xlabel('Heure') ; ylabel('Mahalanobis Distance');
legend('MD','"Robust MD"','Threshold')

figure,
plot(tab_Mahala_dist,tab_Mahala_dist_robust,'o'); hold on;    % MD
plot(0:0.5:5,3*ones(1,11),'r');
plot(3*ones(1,11),0:0.5:5,'r');                                %Threshold

title('Distance-Distance pour le trafic de chaque heure');
xlabel('Mahalanobis Distance') ; ylabel('Robust Mahalanobis Distance');
legend('Distance-Distance','Threshold','Threshold')

end


if sigma_2D_reel == 1
%Simple ecart à la moyenne 2D sur données réelles

xMin = -100;
xMax = 250;
step = 1;

X1 = xMin:step:xMax;
X2 = xMin:step:xMax;
[X1aff,X2aff]=meshgrid(xMin:step:xMax,xMin:step:xMax);
L = zeros(length(X2),length(X1));
MD = zeros(length(X2),length(X1));
for i = 1:length(X1)
    for j = 1:length(X2)
    x = [X1(i) X2(j)]';
    L(j,i) = N(x);
    
    end
end

figure;hold on;
contour(X1,X2,L);

end