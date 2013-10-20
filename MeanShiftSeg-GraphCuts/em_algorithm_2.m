function em_algorithm

data = load('annotation_data.mat');

an_id = data.annotator_ids;
img_id = data.image_ids;
scores = data.annotation_scores;

num_observations = numel(scores);
num_annotators = numel(unique(an_id)); %25
num_img = 150;
N = 5;

%retrieve all annotations for an image
images_info= zeros(5,2,num_img);

for i = 1:num_img
   entries =  img_id == i;
   images_info(:,:,i) =  [an_id(entries,:) scores(entries)];
end

%scores by annotators
ann_scores = zeros(30,num_annotators);
for i = 1:num_annotators
    ann_scores(:,i) = scores(an_id == i);
end

mu = zeros(num_img,1);
logp_j = 0.5*ones(5,2,num_img);

for i = 1:num_img
    sc = images_info(:,2,i);
   
    mu(i) = mean(sc);
    
    if (i==1)
        sigma = std(sc);
    end    
end

%mu(:) = 5;
%sigma = 2;

prior = 0.5;

ann_votes = zeros(num_annotators,1);
logp2 = zeros(num_observations,2);

maxiter = 300;
niter = 0;

pOld = 0.5*ones(num_observations,2);


while (any(abs(pOld - logp2))>0.01) 
   niter = niter +1;
   
   pOld = logpsum;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % E-Step
%    for i=1:num_img
%        logp_j(:,1,i) = log(normpdf(images_info(:,2,i),mu(i),sigma)) + log(prior);   
%        logp_j(:,2,i) = log(repmat(1/10,[5 1])) + log(1-prior);
% 
%        logsum = logsumexp([logp_j(:,1,i) logp_j(:,2,i)],2);
% 
%        logp_j(:,1,i) = logp_j(:,1,i)-logsum;
%        logp_j(:,2,i) = logp_j(:,2,i)-logsum;
%    end  
   
   for i = 1:num_observations
       imageId = img_id(i);
       %idx = img_id == imageId;
       logp2(i,1) = log(normpdf(scores(i),mu(imageId),sigma)) + log(prior);
       logp2(i,2) = log(1/10) + log(1-prior);
       
       totalLogsum = logsumexp([logp2(i,1) logp2(i,2)],2);
       logp2(i,1)  =  logp2(i,1)-totalLogsum;
       logp2(i,2)  =  logp2(i,2)-totalLogsum;
   end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % M-Step

     priorValNum = 0 ;
     sigmaValNum = 0 ;
     sigmaValDen = 0;

%  attempt1
%     for i=1:num_img
%        priorValNum = priorValNum + sum(exp(logp_j(:,1,i)),1); 
%        
%        mu(i) = sum(images_info(:,2,i).*exp(logp_j(:,1,i)))/(sum(exp(logp_j(:,1,i)),1));
%        
%        sigmaValNum = sigmaValNum + sum(exp(logp_j(:,1,i)).*(images_info(:,2,i) -  mu(i)).^2);
%        sigmaValDen = sigmaValDen + sum(exp(logp_j(:,1,i)));
%     end
%    
%     prior = priorValNum/(num_img*N);
%     sigma = sqrt(sigmaValNum/sigmaValDen);


%  attempt2
    for i=1:num_img   
       imIdx = img_id == i;
       priorValNum = priorValNum + sum(exp(logp2(imIdx,1))); 
       
       mu(i) = sum(scores(imIdx).*exp(logp2(imIdx,1)))/(sum(exp(logp2(imIdx,1))));
       
       sigmaValNum = sigmaValNum + sum(exp(logp2(imIdx,1)).*(scores(imIdx) -  mu(i)).^2);
       sigmaValDen = sigmaValDen + sum(exp(logp2(imIdx,1)));
    end
   
    prior = priorValNum/(num_img*N);
    sigma = sqrt(sigmaValNum/sigmaValDen);

end  


ann = zeros(num_annotators,1);

for i=1:num_annotators
    idx = an_id == i;    
    ann(i) = numel(logp2(idx,1) < logp2(idx,2));
end

mean_scores = zeros(num_img,1);
for i=1:num_img
    s = images_info(:,2,i);
    mean_scores(i) = mean(s);
end

plot(1:150,mean_scores(1:150));
