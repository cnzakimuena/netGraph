
clear
clc

%% Computer Assisted Retinal Blood Vessel Segmentation Algorithm
% Developed and Copyrighted by Tyler L. Coye (2015)

% Read Image
I = imread('CZMI200159246_19900324_Male_Angio (6mmx6mm)_20180524160250_OS_20180524171914_Angiography_Superficial.bmp');
I2 = imcomplement(I);
% I3 = imadjust(I2);

% Resize image for easier computation
O = imresize(I, [584 565]); 
B = imresize(I2, [584 565]);

% Read image
im = im2double(B);

% Convert RGB to Gray via PCA
% im2 = cat(3, im, im,im); % test for already grey image
lab = rgb2lab(im);
f = 0;
wlab = reshape(bsxfun(@times,cat(3,1-f,f/2,f/2),lab),[],3);
[C,S] = pca(wlab);
S = reshape(S,size(lab));
S = S(:,:,1);
gray = (S-min(S(:)))./(max(S(:))-min(S(:)));


%% Contrast Enhancment of gray image using CLAHE
J = adapthisteq(gray,'numTiles',[8 8],'nBins',128);


%% Background Exclusion

% Apply Average Filter
h = fspecial('average', [9 9]);
JF = imfilter(J, h);

% Take the difference between the gray image and Average Filter
Z = imsubtract(JF, J);


%% Threshold using the IsoData Method
level = isodata(Z); % this is our threshold level
%level = graythresh(Z)


%% Convert to Binary
BW = im2bw(Z, level-.008);


%% Remove small pixels
BW2 = bwareaopen(BW, 150); % mask


%% Overlay
BW3 = imcomplement(BW2); 
out = imoverlay(O, BW3, [0 0 0]); % final image

figure;
subplot(121);imshow(O);title('Input Image');
subplot(122);imshow(out);title('Extracted Blood Vessels');








