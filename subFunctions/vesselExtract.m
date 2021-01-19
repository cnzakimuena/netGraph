
function [skel, skel2, vess, PRinsitu] = vesselExtract(cube, size_red, saveFolder, saveName)

%volume orientation change to en-face direction
enFace_cube0 = [];
for ff = 1:size(cube,1)
    enFace_im = mat2gray(reshape(cube(ff,:,:), [size(cube, 2), size(cube, 3)]));
    enFace_cube0(:,:,ff) = enFace_im;
end

avgI_vec = zeros(size(enFace_cube0,3),1);
for k = 1:size(enFace_cube0,3)
    enFace_avgI = mean(mean(enFace_cube0(:,:,k)));
    avgI_vec(k) = enFace_avgI;
end
% look for and remove errors at back of volume
enFace_cube = enFace_cube0;
for kk = 1:10
    if avgI_vec(size(avgI_vec,1)) == avgI_vec(size(avgI_vec,1)-kk)
        enFace_cube(:,:,size(avgI_vec,1)-kk) = 0;
    end
end
enFace_cube(:,:,size(avgI_vec,1)) = 0;
%figure;imshow3D(enFace_cube,[])
PRinsitu = imrotate3(enFace_cube,-90,[0 0 1]); % for OS and OD orientation

% check data orientation integrity
maxFace = zeros(size(enFace_cube, 1),size(enFace_cube, 2));
for i = 1:size(enFace_cube, 1)
    for ii = 1:size(enFace_cube, 2)
        maxFace(i,ii) = max(enFace_cube(i,ii,:));
    end
end
%figure;imshow(maxFace,[])
maxFace_export = imrotate(maxFace,-90);
imwrite(maxFace_export, fullfile(saveFolder, 'Results', saveName, ...
                        'vess1_MaxFace.png'))

%en-face images processing
%*from code developed and copyrighted by Tyler L. Coye (2015)*

corrRatio = 1536/300*size_red;
out_cube = [];
for f = 1:size(enFace_cube, 3)
    I = enFace_cube(:,:,f);
    
    I(I < 0.2) = 0;
    
    I2 = imcomplement(I);
    im = im2double(I2);
    % Contrast Enhancment of gray image using CLAHE
    numSize1 = round(corrRatio*8); 
    J = adapthisteq(im,'numTiles',[numSize1 numSize1],'nBins',128);
    % Background Exclusion
    % Apply Average Filter
    numSize2 = round(corrRatio*9);
    h = fspecial('average', [numSize2 numSize2]);
    JF = imfilter(J, h);
    % Take the difference between the gray image and Average Filter
    Z = imsubtract(JF, J);
    
    % Threshold using the IsoData Method
    % (if there is very little pixels with any intensity in the
    % en-face image and the first rounded T(i) in isodata.m is 1, there
    % will be an error)
    try
        level = isodata(Z); % this is our threshold level
        
        % Convert to Binary
        BW = im2bw(Z, level-.008);
        
        % Remove small pixels (mask)
        BW2 = bwareaopen(BW, 300); % default 300 (formerly 150 vs 30)
        
        se = strel('disk',1);
        BW3 = imclose(BW2,se);
        % figure;imshow([BW2 BW4],[])

        % Overlay (final image)
        BW4 = imcomplement(BW3);
        out = imoverlay(I, BW4, [0 0 0]);
        
%         figure;
%         subplot(121);imshow(I);title('Input Image');
%         subplot(122);imshow(out);title('Extracted Blood Vessels');
%         BW_cube(:,:,f) = flip(BW3);
        BW_cube(:,:,f) = BW3;
        out = rgb2gray(out);
        out_cube(:,:,f) = out;
    catch
        BW_cube(:,:,f) = zeros(size(enFace_cube(:,:,f)));
        out_cube(:,:,f) = zeros(size(enFace_cube(:,:,f)));
    end
end
%figure;imshow3D(BW_cube, [])

BW_Face = zeros(size(BW_cube, 1),size(BW_cube, 2));
for i = 1:size(BW_cube, 1)
    for ii = 1:size(BW_cube, 2)
        BW_Face(i,ii) = max(BW_cube(i,ii,:));
    end
end
%figure;imshow(BW_Face,[])
BW_Face_export = imrotate(BW_Face,-90);
imwrite(BW_Face_export, fullfile(saveFolder, 'Results', saveName, ...
                        'vess2_BWFace.png'))

BW_cube = imrotate3(BW_cube,-90,[0 0 1]); % for OS and OD orientation

% *LARGEST VESSEL SKELETISATION, ERROR FIX*
cc = bwconncomp(BW_cube);
props = regionprops3(cc);
sortedVolumes = sort([props.Volume], 'descend');
% severalBiggest = sortedVolumes(3);
firstBiggest = sortedVolumes(1);
% Pull out biggest (or several biggest) into another 3-D logical image.
binaryVolume2 = bwareaopen(BW_cube, firstBiggest);
se = strel('sphere',4); % default 4
binaryVolume3 = imdilate(binaryVolume2,se);
binaryVolume3 = imfill(binaryVolume3,'holes');
BW_cube2 = BW_cube;
BW_cube2(binaryVolume2) = 0;
binarySkel1 = bwskel(logical(BW_cube2));
binarySkel2 = bwskel(logical(binaryVolume3));
binarySkel1(binarySkel2) = 1;

% %to see individual results execute the following commented lines:
% %opengl hardwarebasic
% % vVol = im2single(binaryVolume2);
% % volumeViewer(vVol)
% binarySkel = bwskel(logical(binaryVolume3));
% sBWVol = im2single(binarySkel);
% sBWVol = im2single(binarySkel1);
% volumeViewer(sBWVol)

% % check data orientation
% maxBW_cube = zeros(size(BW_cube, 1),size(BW_cube, 2));
% for i = 1:size(BW_cube, 1)
%     for ii = 1:size(BW_cube, 2)
%         maxBW_cube(i,ii) = max(BW_cube(i,ii,:));
%     end
% end
% %figure;imshow([maxFace maxBW_cube],[])

% % to recover true aspect ratio, 300/1536 = 0.195
% true = [];
% BW_cube2 = imrotate3(BW_cube,90,[1 0 0]);
% BW_cube3 = imrotate3(BW_cube2,90,[0 1 0]);
% for gg = 1:size(BW_cube3, 3)
%     backtoB = BW_cube3(:,:, gg);
%     trueB = logical(imresize(backtoB, [size(BW_cube3, 1)*0.195 size(BW_cube3, 2)]));
%     true(:,:,gg) = trueB;
% end
% %figure;imshow3D(true,[])

vess = BW_cube;
% vess = imrotate3(vess,180,[0 1 0]);
% vess = imrotate3(vess,180,[0 0 1]); % for OD orientation

skel = logical(binarySkel1); % for OS orientation

skel_Face = zeros(size(skel, 1),size(skel, 2));
for i = 1:size(skel, 1)
    for ii = 1:size(skel, 2)
        skel_Face(i,ii) = max(skel(i,ii,:));
    end
end
% % skeleton smoothing
% se = offsetstrel('ball',12,12);
% dilatedI = imbinarize(mat2gray(imdilate(skel_Face,se)));
% skel_Face2 = bwskel(dilatedI);
% figure;imshow([skel_Face skel_Face2],[])
%figure;imshow(BW_Face,[])
imwrite(skel_Face, fullfile(saveFolder, 'Results', saveName, ...
                        'vess3_skelFace.png'))

%3D morphological operation for skeleton validation
[xx,yy,zz] = ndgrid(-2:2);
nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= 2.0;
skel2 = imdilate(skel, nhood);

end