function [im, person, number, subset] = readFaceImages(imdir)

files = dir(fullfile(imdir, '*.png'));
for f = 1:numel(files)
  fn = files(f).name;
  person(f) = str2num(fn(7:8));
  number(f) = str2num(fn(10:11));
  if number(f) <= 7
    subset(f) = 1;
  elseif number(f) <= 19
    subset(f) = 2;
  elseif number(f) <= 31
    subset(f) = 3;
  elseif number(f) <= 45
    subset(f) = 4;
  elseif number(f) <= 64
    subset(f) = 5;
  end
  im{f} = im2single(imread(fullfile(imdir, fn)));
end


% files = dir(fullfile(imdir, '*.gif'));
% for f = 1:numel(files)
%   fn = files(f).name;
%   id(f) = str2num(fn(8:9));
%   im{f} = imread(fullfile(imdir, fn));
% end
