function [Wopt] = fisherfaces(train,c)
%   - train: the training set
%   Wopt : the 

%%%%%%%%%%%%%%%%%%%%%%%
%  break the data per person
[n dcount] =  size(train);
p = 10; % number of person;
m = dcount/10 ; % number of image per person in the data set

A = train;
Ni = m*ones(p,1);
Mui = zeros(n,1);

for i = 1:p
    
    %shift to images for person p.
    startIdx = (i-1)*m +1;
    endIdx = i*m;
    
    Mui(:,i) = mean(A(:,startIdx:endIdx),2);
end

mu = mean(Mui,2);

[U D] = eig(A'*A);

[~, orderDescIdx] =  sort(diag(D),'descend');

U = U(:,orderDescIdx);

V = A*U;

d = size(V,2) - c;
V = V(:,1:d);

Si = zeros(n,n,p);
Sw = zeros(n,n);
Sb = zeros(n,n);

for i = 1:p
    startIdx = (i-1)*m + 1;
    endIdx = i*7;
    
    B = A(:,startIdx:endIdx);
    
    for j=1:m
        Si(:,:,i) = Si(:,:,i) + (B(:,j) - mu(i))*(B(:,j) - mu(i))';
    end
end

for i = 1:p 
    Sw = Sw + Si(:,:,i);
    Sb = Sb + Ni(i)*((Mui(:,i) - mu(i))*(Mui(:,i) - mu(i))');
end

Sb_hat = V'*Sb*V;
Sw_hat = V'*Sw*V;

[Uf Df] = eig(Sb_hat,Sw_hat);
[~,uIdx] = sort(diag(Df),'descend');

Uf = Uf(:,uIdx);

Wopt = Uf'*V';

Wopt = Wopt';

for i = 1:size(Wopt,2)
    Wopt(:,i) = Wopt(:,i)/norm(Wopt(:,i));
end

d = c-1;
Wopt = Wopt(:,1:d);

