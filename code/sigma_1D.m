close all
clc, clear

%% VAR

sigma_1D = 0;
sigma_1D_reel = 1;

datas_synth = load('PointAnomalySynthetic.data.csv'); %datas  (2010x50) (données 1D ou 2010 datas de 50 features chacune ?)
% load('PointAnomalySynthetic.label.csv')       %labels (0 or 1)

% Fichier texte délimité par espaces. 
%3 ensemble comptage horaire de la circulation, enregistré à 3 intersections différentes de la ville sur 24h.
%Chaque colonne représente les données d'une intersection
trafic = load('count.dat'); % [24 x 3] = [24h x 3 intersections]

%% TRAITEMENT

%% Simple ecart à la moyenne 1D sur données synthétiques
V = datas_synth(1:2010,40);     % 40eme colonne des datas

mean_V = mean(V);
sigma_V = std(V);

%% Simple ecart à la moyenne 1D sur données réelles
inter_3 = trafic(:,3);                              % Datas de la 3ème intersection (outlier = 20h 3eme intersection 257 vehicules ?)
mean_trafic_inter_3 = mean(inter_3);                % Moyenne trafic
sigma_trafic_inter_3 = std(inter_3);                % sigma trafic

seuil_sigma = 1;                                                                   % Threshold (pour + ou - seuil x sigma)
seuil_2sigma = 2;
seuil_3sigma = 3;
index_outliers_sigma = find(inter_3>mean_trafic_inter_3+seuil_sigma*sigma_trafic_inter_3);  % Outliers + ou - 1 sigma
index_outliers_2sigma = find(inter_3>mean_trafic_inter_3+seuil_2sigma*sigma_trafic_inter_3);% Outliers + ou - 2 sigma
index_outliers_3sigma = find(inter_3>mean_trafic_inter_3+seuil_3sigma*sigma_trafic_inter_3);% Outliers + ou - 3 sigma

%% FIGURES

if sigma_1D == 1
%Simple ecart à la moyenne 1D sur données réelles
figure;plot(V,'o');hold on
title('Plot des données et bornes + ou - n sigmas');
xlabel('Index') ; ylabel('Valeur'); hold on

plot(mean_V+3*sigma_V*ones(1,length(V)),'r');
plot(mean_V-3*sigma_V*ones(1,length(V)),'r');
plot(mean_V+2*sigma_V*ones(1,length(V)),'b');
plot(mean_V-2*sigma_V*ones(1,length(V)),'b');
plot(mean_V+sigma_V*ones(1,length(V)),'m');
plot(mean_V-sigma_V*ones(1,length(V)),'m');

legend('data','+-sigma','+-sigma','+-2sigma','+-2sigma','+-3sigma','+-3sigma')
end

if sigma_1D_reel == 1
%Simple ecart à la moyenne 1D
figure;plot(inter_3,'o'); title('Detection Outliers : Trafic en fonction heure'); xlabel('Heure') ; ylabel('Trafic'); hold on

plot(mean_trafic_inter_3+seuil_3sigma*sigma_trafic_inter_3*ones(1,length(inter_3)),'r', 'LineWidth',1); % écart + ou - 3 sigma
plot(index_outliers_3sigma,inter_3(index_outliers_3sigma),'rX','MarkerSize',10,'LineWidth',2)

plot(mean_trafic_inter_3+seuil_2sigma*sigma_trafic_inter_3*ones(1,length(inter_3)),'b', 'LineWidth',1); % écart + ou - 3 sigma
plot(index_outliers_2sigma,inter_3(index_outliers_2sigma),'bX','MarkerSize',10,'LineWidth',2)

plot(mean_trafic_inter_3+seuil_sigma*sigma_trafic_inter_3*ones(1,length(inter_3)),'m');                % écart + ou - 1 sigma
plot(index_outliers_sigma,inter_3(index_outliers_sigma),'mX','MarkerSize',10,'LineWidth',2)

legend('datas trafic','+-3sigma','+-2sigma','outliers 2sigma', '+-sigma','outliers sigma')
end