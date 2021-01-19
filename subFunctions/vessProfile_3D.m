
function [nodesProfile, linksProfile]  = vessProfile_3D(skelVolume, ...
    sETDRS, folder, nameFold)

[totalNodes_Struc, totalLinks_Struc] = vessNetwork2(skelVolume, folder, ...
    nameFold, 0);
totalNodes = size(totalNodes_Struc,2);
totalLinks = size(totalLinks_Struc,2);

vnGR = zeros(1, size(sETDRS.regionsETDRS_3D, 2));
vlGR = zeros(1, size(sETDRS.regionsETDRS_3D, 2));

for k = 1:size(sETDRS.regionsETDRS_3D, 2)
    
    tempSkel = skelVolume;
    tempSkel(~sETDRS.regionsETDRS_3D{k}) = 0;
    
    [currNodes_Struc, currLinks_Struc] = vessNetwork2(tempSkel, folder, ...
        nameFold, 1);
    currNodes = size(currNodes_Struc,2);
    currLinks = size(currLinks_Struc,2);
    
    vnGR(:, k) = currNodes; 
    vlGR(:, k) = currLinks;
    
end

nodesProfile = [totalNodes vnGR]; 
linksProfile = [totalLinks vlGR]; 


% figure;imshow3D(volBW,[])

end

