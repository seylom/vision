function recognize(train,test,rfaces,trainMap,subset,person)
%   - train: the preprocessed training set;
%            train is our subset of images. their ids are stored in
%            trainMap
%   - test: the test set
%   - mu: mean of training set
%   - rfaces: a set of reduced faces
%   - subset: subset id for each image data.
%   - trainMap: id of training set images in the global image data set

testcount = size(test,2);
traincount = size(train,2);
matchesMap = zeros(testcount,2);

matchesMap(:,1) = person';

mu = mean(train,2);

trainFaces = rfaces'*(train - repmat(mu,[1 traincount]));

testFaces = rfaces'*(test - repmat(mu,[1 testcount]));

for i = 1:testcount
    
    bdist = repmat(testFaces(:,i),[1 traincount]);
    
    %distance to all the training samples.
    dist = sqrt(sum((trainFaces - bdist).^2));  
    [~,id] = min(dist); 
    s1Idx = trainMap(id); 
    matchesMap(i,2) = person(s1Idx);
end

errorRates = zeros(1,5);

disp('Error rates:');
for i = 1:5   % 5 subsets
    %find all images ids in subset (i)
    imgIdx = find(subset == i);
    
    %find ids where persons are correctly recognized.
    matches = find(matchesMap(imgIdx,1) == matchesMap(imgIdx,2));
    errorRates(i) = 1 - numel(matches)/numel(imgIdx);
    disp(['subset ',num2str(i),': ',num2str(errorRates(i))]);
end

end