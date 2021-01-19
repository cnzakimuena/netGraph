
function [vol1, vol2, cropVol] = full_volROI(Volume1, Volume2, h_lim, l_lim, sizeRed)

    vol1 = zeros(size(Volume1));
    vol2 = zeros(size(Volume1));
    cropVol = zeros(size(Volume1));
    
    for vv = 1:size(Volume1, 3)     
        im1 = Volume1(:,:,vv);
        im2 = Volume2(:,:,vv);
        
        % create a mask with ones in the area of interest
        cropMask = zeros(size(im1));
        wt = round(10*sizeRed); 
        wb = round(10*sizeRed);
        for rr = 1:size(cropMask, 2)
            cropMask(h_lim(vv,rr)-wt:l_lim(vv,rr)-wb,rr) = 1;
        end
        
        im1 = cropMask.*im1;
        im2 = cropMask.*im2; 
        vol1(:,:,vv) = im1;
        vol2(:,:,vv) = im2;
        cropVol(:,:,vv) = cropMask;  
    end 
    
    vol_t = min(min(h_lim));
    vol_b = max(max(l_lim));
%     wt = 10; wb = 10;
%     vol2 = uint8(mat2gray(vol2(vol_t-wt:vol_b+wb,:,:))*255);
%     vol1 = uint8(mat2gray(vol1(vol_t-wt:vol_b+wb,:,:))*255);
%     vol1 = uint8(mat2gray(vol1(vol_t:vol_b,:,:))*255);
%     vol2 = uint8(mat2gray(vol2(vol_t:vol_b,:,:))*255);
    cropVol = uint8(mat2gray(cropVol(vol_t:vol_b,:,:))*255);
    
end 