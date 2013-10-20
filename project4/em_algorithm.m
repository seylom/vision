function em_algorithm

data = load('annotation_data.mat');

an_id = data.annotator_ids;
img_id = data.image_ids;
scores = data.annotation_scores;

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

maxiter = 200;
mu = zeros(num_img,1);
%sigma = 1;

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

prior = 0.5*ones(1,2);

ann_votes = zeros(num_annotators,1);

for i=1:num_img

    im_scores = images_info(:,2,i);
    prev_p = zeros(5,2);

    while any(abs(logp_j(:,:,i)-prev_p))>0.001
        
       prev_p = logp_j(:,:,i);

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % E-Step
       
       logp_j(:,1,i) = log(normpdf(im_scores,mu(i),sigma)) + log(prior(1));   
       logp_j(:,2,i) = log(repmat(1/10,[5 1])) + log(1-prior(1));
             
       logsum = logsumexp([logp_j(:,1,i) logp_j(:,2,i)],2);
                           
       logp_j(:,1,i) = logp_j(:,1,i)-logsum;
       logp_j(:,2,i) = logp_j(:,2,i)-logsum;

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % M-Step
       if (i == 1)
          prior(1) = sum(exp(logp_j(:,1,i)),1)/N;     
       end
       
       mu(i) = sum(im_scores.*exp(logp_j(:,1,i)))/(sum(exp(logp_j(:,1,i)),1));
       
       if (i==1)     
         sigma = sqrt(sum(exp(logp_j(:,1,i)).*(im_scores -  mu(i)).^2)/sum(exp(logp_j(:,1,i))));
       end 
    end  
end

for i=1:num_img
    d = [images_info(:,1,i) exp(logp_j(:,1,i))];
    idx = d(d(:,2) >= 0.5,1);
    
    ann_votes(idx) = ann_votes(idx)+1;
end

bad_ann_ids = find(ann_votes < 15);

mean_scores = zeros(num_img,1);
for i=1:num_img
    s = images_info(:,2,i);
    mean_scores(i) = mean(s);
end

plot(1:150,mean_scores(1:150));
