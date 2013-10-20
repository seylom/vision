
function [clusters,ptassign] = kmeansClustering(k,data)
% -k number of clusters
%  -data matrix of data N * P for example where N
%  is the number of sample with p component each
%  ptassign cluster assignment for each point

%% permute the dataset

[rcount ccount] = size(data);
r = randperm(rcount);
ndata = data(r,:);

clusters = ndata(1:k,:);

niter = 1;
maxiter = 100;

%ptassign = zeros(rcount,1);

prev = 1000*ones(k,ccount);

while ((any(abs(prev-clusters))>0.01))
    prev = clusters;
    
%     for i=1:rcount
%         pt = data(i,:);
%         dist = sum((clusters - repmat(pt,[k 1])).^2,2);
%         
%         [~,idx] = min(dist);
%         ptassign(i) = idx;
%     end
  
    clusternorm = sum(clusters.^2, 2);
    dataNorm = sum((data').^2, 1);

    m = repmat(clusternorm,1, rcount) + repmat(dataNorm, k, 1) - 2*clusters*data';

    [~, ptassign] = min(m,[], 1);
    
    %compute new means
    for i = 1:k
        idp = ptassign == i;
        clusters(i,:) = mean(data(idp,:),1);
    end
end

%threshold = diff;

end

