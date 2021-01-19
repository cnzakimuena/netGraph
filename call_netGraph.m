
function call_netGraph()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name - netGraph
% Creation Date - 17th January 2021
% Author - Charles Belanger Nzakimuena
% Website - https://www.ibis-space.com/
%
% Description - 
%   NETGRAPH 
%
% Example -
%		call_netGraph()
%
% License - MIT
%
% Change History -
%                   17th January 2021 - Creation by Charles Belanger Nzakimuena
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('./subfunctions'))

%% list names of folders inside the patients folder

currentFolder = pwd;
patientsFolder = fullfile(currentFolder, 'processed');
myDir = dir(patientsFolder);
dirFlags = [myDir.isdir] & ~strcmp({myDir.name},'.') & ~strcmp({myDir.name},'..');
nameFolds = myDir(dirFlags);

%% for each 3x3 subfolder, turn segmented data into network graph

% get table row count
rowCount = 0;
for g = 1:numel(nameFolds)
    folder2 = fullfile(patientsFolder, nameFolds(g).name);
    patientDir2 = dir(fullfile(folder2, 'Results'));
    dirFlags2 = [patientDir2.isdir] & ~strcmp({patientDir2.name},'.') & ~strcmp({patientDir2.name},'..');
    subFolders2 = patientDir2(dirFlags2);
    rowCount = rowCount + numel(subFolders2);
end

col = zeros(rowCount,1);
colc = cell(rowCount,1);
vnTable = table(colc,col,col,col,col,col,col,...
    'VariableNames',{'id' 'totalNodes' 'region1' 'region2' 'region3' 'region4'...
    'region5'});
vlTable = table(colc,col,col,col,col,col,col,...
    'VariableNames',{'id' 'totalLinks' 'region1' 'region2' 'region3' 'region4'...
    'region5'});

tableRow = 0;
for i = 1:numel(nameFolds) 
    
    % assemble patient folder string
    folder = fullfile(patientsFolder, nameFolds(i).name);
    
    try

        % add line to LOG
        disp(logit(folder, ['Initiating netGraph; ' nameFolds(i).name ' folder']))
        
        patientDir = dir(fullfile(folder, 'Results'));
        dirFlags = [patientDir.isdir] & ~strcmp({patientDir.name},'.') & ~strcmp({patientDir.name},'..');
        subFolders = patientDir(dirFlags);
        
        for k = 1:numel(subFolders)
            
            nameFold = subFolders(k).name;
            scanType = nameFold(1:2);
            if strcmp(scanType, '3m')
                
                load(fullfile(folder,'Results', nameFold, 'segmentation.mat'))
                load(fullfile(folder,'Results', nameFold,'scanInfo.mat'));
                load(fullfile(folder,'Results', nameFold, 'ETDRS_grid','2DregionsETDRS.mat'));
                load(fullfile(folder,'Results', nameFold, 'ETDRS_grid','3DregionsETDRS.mat'));
                sizeRed = scanTag{2};
                
                % visualise segmentation results
                %1- Without the segmentation
                %   figure;imshow3D(volumeStruc,[])
                %    %OR, for flow images
                %   figure;imshow3D(volumeFlow,[])
                %2- With the segmentation
                %   figure;imshow3D(volumeStruc,[],'plot',cat(3,RPEt,RPEb, RVIf, lBM),'LineWidth',2)
                %   %OR, for flow images
                %   figure;imshow3D(volumeFlow,[],'plot',cat(3,RPEt,RPEb, RVIf, lBM),'LineWidth',2)
                %3- If you want to see the volume in the nasal temporal direction (90degre
                %   rotation in the anteriot posterior direction)
                %   figure;imshow3D(permute(volumeStruc,[1,3,2]),[],'plot',permute(cat(3,RPEt,RPEb, RVIf, lBM),[2,1,3]),'LineWidth',2)

                % volume resize 
                % volume size reduction factor for RAM limitation
%                 sizeRed = 600/1536;
                disp('begin dimAdjustAll')
                [vol_flow,vol_struc,BM,RVI] = dimAdjustAll(volumeFlow,volumeStruc,lBM,RVIf,sizeRed);
                disp('end dimAdjustAll')

                % full structural and flow volumes cropping
                disp('begin full_volROI')
                [volStruc, volFlow, ROIMask] = full_volROI(vol_struc, vol_flow, RVI, BM, sizeRed);
                disp('end full_volROI')                
              
                % correction to projection-resolved flow volume
                disp('begin PRcorr')
                [corr_cube] = PRcorr(volStruc, volFlow, sizeRed, BM);
                disp('end PRcorr')

                % en-face vessel extraction
                disp('begin vesselExtract')
                [skelVol, skelVol2, vessVol, vessPR] = vesselExtract(corr_cube, sizeRed, folder, nameFold);
                disp('end vesselExtract')
                %to see individual results execute the following commented lines:
                %opengl hardwarebasic
                %sVol = im2single(skelVol);
                %volumeViewer(sVol) % skeletonized vessels
                %vVol = im2single(vessVol);
                %volumeViewer(vVol) % vessels at orignal 1536px A-scan aspect ratio
                %tVol = im2single(trueVol);
                %volumeViewer(tVol) % vessels at true A-scan aspect ratio

                % data export (skelVol2, vessVol, volStruc, volFlow)
                dataExport(folder, nameFold, skelVol2, vessVol, volStruc, volFlow, vessPR)

%                 %vessel volume density (VVD)
%                 %calculation of the percentage of volume occupied by vessels on an OCTA volume
%                 %VVD_index = nnz(vessVol)/(nnz(~vessVol)+nnz(vessVol))*100 
%                 VVD_index = nnz(vessVol)/nnz(ROIMask)*100;
%                 
%                 %vessel skeleton density (VSD)
%                 %calculation of the percentage of vessel length occupied by vessels on an OCTA volume
%                 %VSD_index = nnz(skelVol)/(nnz(~skelVol)+nnz(skelVol))*100
%                 VSD_index = nnz(skelVol)/nnz(ROIMask)*100;
                
                if ~exist(fullfile(folder,'Results'), 'dir')
                    mkdir(fullfile(folder,'Results'));
                end
                if ~exist(fullfile(folder,'Results', nameFold), 'dir')
                    mkdir(fullfile(folder,'Results', nameFold));
                end

                disp('begin vessProfile_3D')
                % vessels skeleton to 3D graphs  
                [vnProfile, vlProfile] = vessProfile_3D(skelVol, ...
                    structETDRS, folder, nameFold);
                %save(fullfile(folder,'Results', nameFold, ['vessels_' nameFold '.mat']),'skelVol','vessVol', 'nodes', 'links')
                %load(fullfile(folder,'Results', nameFold, ['vessels_' nameFold '.mat']))
                disp('end vessProfile_3D')

                % For left eye, ETDRS regions must be modified from OD nomenclature
                % to OS nomenclature
                if contains(nameFold, '_OS_')
                    vnRegion3 = vnProfile(6);
                    vnRegion5 = vnProfile(4);
                    vnProfile(4) = vnRegion3;
                    vnProfile(6) = vnRegion5;
                    
                    vlRegion3 = vlProfile(6);
                    vlRegion5 = vlProfile(4);
                    vlProfile(4) = vlRegion3;
                    vlProfile(6) = vlRegion5;
                    
                end
                
                tableRow = tableRow + 1;
                
                vnTable{tableRow,'id'} = {nameFold};
                vnTable{tableRow,'totalNodes'} = vnProfile(1);
                vnTable{tableRow,'region1'}  = vnProfile(2);
                vnTable{tableRow,'region2'} = vnProfile(3);
                vnTable{tableRow,'region3'} = vnProfile(4);
                vnTable{tableRow,'region4'} = vnProfile(5);
                vnTable{tableRow,'region5'} = vnProfile(6);
                
                vlTable{tableRow,'id'} = {nameFold};
                vlTable{tableRow,'totalLinks'} = vlProfile(1);
                vlTable{tableRow,'region1'}  = vlProfile(2);
                vlTable{tableRow,'region2'} = vlProfile(3);
                vlTable{tableRow,'region3'} = vlProfile(4);
                vlTable{tableRow,'region4'} = vlProfile(5);
                vlTable{tableRow,'region5'} = vlProfile(6);
                
            end
        end
        
    catch exception
        errorString = ['Error in netGraph. Message:' exception.message buildCallStack(exception)];
        if ~exist(fullfile(pwd,'error'), 'dir')
            mkdir(fullfile(pwd,'error'));
        end
        disp(logit(fullfile(pwd, 'error'),errorString));
        continue 
    end
    
end

fileName1 = fullfile(patientsFolder,'vnTable.xls');
fileName2 = fullfile(patientsFolder,'vlTable.xls');
writetable(vnTable,fileName1)
writetable(vlTable,fileName2)

disp(logit(folder,'Done netGraph'))            
                
                
