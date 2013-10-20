function [Eigen] = eigenfaces(train,d)
%   - train: the raining set
%            each vector of 'train' is a reshaped and mean normalized image
%   - d : number of components to keep
%   Eigen => the eigenvectors

mu = mean(train,2);

B = train - repmat(mu,[1 size(train,2)]);

[U,Diag] = eig(B'*B);
[~, idx] = sort(diag(Diag),'descend');

U = U(:,idx);

V = B*U;

for i=1:size(U,2);
    V(:,i) = V(:,i)/sqrt(sum(V(:,i).^2));
end

if (d >size(V,2))
    d = size(V,2);
end

Eigen = V(:,1:d);

end