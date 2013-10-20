function FaceRecognition(path,method,maxeigen,maxfisher)
%  - path: path to file
%  - method : 0-eigen  1-fisher
%  - maxeigen : max number of eigenvalues
%  - maxfisher: max number of components;

imageFile = fullfile(path,'imagedata.mat');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    data preprocesssing

if(~exist(imageFile,'file'))
    [images,person,number,subset] = readFaceImages([path '\faces']);

    [h,w] = size(images{1});

    q = 10;
    dataCount = 64*q;

    test = zeros(h*w,dataCount);
    
    ix = 1;

    for i= 1:10
        idp = find(person == i);

        for j = 1:64
            id = idp(j);
            im = im2double(images{id});
            im = reshape(im,[h*w,1]);
              
            im = (im - mean(im))/std(im);

            test(:,ix) = im;
            
            ix = ix+1;
        end       
    end
    
    idxS1 = subset == 1;
    idxS15 =  subset == 1| subset == 5;
    
    data = [];
    
    train1 = test(:,idxS1);
    train15 = test(:,idxS15);
    
    imageSize = [h w];
    data.imageSize = imageSize;
    data.train1 = train1;
    data.test = test;
    data.train15 = train15;
    data.person = person;
    data.number = number;
    data.subset = subset;
    
    save(imageFile,'train1','train15','test','person','number','subset','imageSize');
else
   data = load(imageFile);
end

if (method == 0)
     disp('===========================================');
     disp(['Recognition results for eigenfaces: c = ',num2str(maxeigen),'']);
     
     rfaces1 = eigenfaces(data.train1,maxeigen);
     rfaces15 = eigenfaces(data.train15,maxeigen);
     
     for i=1:9
         img = reshape(rfaces1(:,i),data.imageSize);
         subplot(3,3,i);imagesc(img);colormap gray; axis image ;axis off
     end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   perform reconstruction on a couple of images

    muTrain = mean(data.train1,2);

    imIds = [1 8 20 32 46];

    samples = data.test(:,imIds);
    nFaces = rfaces1'*(samples - repmat(muTrain,[1 5]));


    for i=1:5
        img = reshape(samples(:,i),data.imageSize);

        imrec = muTrain + rfaces1*nFaces(:,i);

        imrec = reshape(imrec,data.imageSize);

        subplot(2,5,i);imagesc(img);colormap gray;axis image ;axis off
        subplot(2,5,i+5);imagesc(imrec);colormap gray; axis image ;axis off
    end

else
     disp('===========================================');
     disp(['Recognition results for fisherfaces: c = ',num2str(maxfisher),'']);
     
     rfaces1 = fisherfaces(data.train1,maxfisher);
     rfaces15 = fisherfaces(data.train1,maxfisher);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    perform recognition on results;

disp('traning subset: 1  ------------------------');

recognize(data.train1,data.test,rfaces1,find(data.subset == 1), ...
    data.subset,data.person)

disp('-------------------------------------------');
disp('traning subset: 1 and 5 -------------------');

recognize(data.train15,data.test,rfaces15,find(data.subset == 1 | data.subset == 5), ...
    data.subset,data.person)

disp('===========================================');



