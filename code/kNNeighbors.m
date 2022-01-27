classdef kNNeighbors
%k-Nearest Neighbors (kNN)
%
% Author: M.Sc. David Ferreira - Federal University of Amazonas
% Contact: ferreirad08@gmail.com
% Date: October 2020
properties
    k = 5
    metric = 'euclidean'
    X
    name_labels
    Y
end
methods
    function obj = kNNeighbors(k,metric)
        if nargin > 0
            obj.k = k;
        end
        if nargin > 1
            obj.metric = metric;
        end
    end
    function obj = fit(obj,X,Y)
        obj.X = X;
        [obj.name_labels,~,obj.Y] = unique(Y); % Numeric labels
    end
    function [distances,indices] = find(obj,Xnew)
        distances = pdist2(obj.X,Xnew,obj.metric); % Euclidean distance matrix
        [distances,indices] = sort(distances); % Ordered distances
        distances = distances(1:obj.k,:);
        indices = indices(1:obj.k,:);
    end
    function Ypred = predict(obj,Xnew)
        [~,indices] = find(obj,Xnew);
        Ynearest = obj.Y(indices); % k-nearest labels
        dim = 2 - (obj.k > 1); % dimension for the mode function
        Ypred = obj.name_labels(mode(Ynearest,dim)); % Most frequent label
    end
end
end
