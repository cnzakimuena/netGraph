
function dataExport(exportFolder, folderName, skelVol2, vessVol, volStruc, volFlow, PRinsitu)

if ~exist(fullfile(exportFolder,'ExportFiles'), 'dir')
    mkdir(fullfile(exportFolder,'ExportFiles'));
end
if ~exist(fullfile(exportFolder,'ExportFiles', folderName), 'dir')
    mkdir(fullfile(exportFolder,'ExportFiles', folderName));
end

% 'skelVol2', 'vessVol' and 'PRinsitu' volume data export
for d = 1:size(PRinsitu,3)
    imID = 'PRinsitu';
    im = PRinsitu(:,:,d);
    if ~exist(fullfile(exportFolder,'ExportFiles', folderName, imID), 'dir')
        mkdir(fullfile(exportFolder,'ExportFiles', folderName, imID));
    end
    imwrite(im, fullfile(exportFolder,'ExportFiles', folderName, imID, [imID '_' num2str(d, '%03.0f') '.png']))
end
for i = 1:size(skelVol2,3)
    imID = 'skelVol2';
    im = skelVol2(:,:,i);
    if ~exist(fullfile(exportFolder,'ExportFiles', folderName, imID), 'dir')
        mkdir(fullfile(exportFolder,'ExportFiles', folderName, imID));
    end
    imwrite(im, fullfile(exportFolder,'ExportFiles', folderName, imID, [imID '_' num2str(i, '%03.0f') '.png']))
end
for ii = 1:size(vessVol,3)
    imID = 'vessVol';
    im = vessVol(:,:,ii);
    if ~exist(fullfile(exportFolder,'ExportFiles', folderName, imID), 'dir')
        mkdir(fullfile(exportFolder,'ExportFiles', folderName, imID));
    end
    imwrite(im, fullfile(exportFolder,'ExportFiles', folderName, imID, [imID '_' num2str(ii, '%03.0f') '.png']))
end

% adjustment of 'volStruc' and 'volFlow' orientation
enfaceStruc0 = [];
for f = 1:size(volStruc,1)
    volStruc_im = mat2gray(reshape(volStruc(f,:,:), [size(volStruc, 2), size(volStruc, 3)]));
%     volStruc_im = flip(volStruc_im);
    enfaceStruc0(:,:,f) = volStruc_im;
end
% enfaceStruc0 = imrotate3(enfaceStruc0,180,[0 1 0]);
enfaceStruc = imrotate3(enfaceStruc0,-90,[0 0 1]); % for OS orientation
%enfaceStruc = imrotate3(enfaceStruc0,180,[0 0 1]); % for OD orientation
enfaceFlow0 = [];
for ff = 1:size(volFlow,1)
    volFlow_im = mat2gray(reshape(volFlow(ff,:,:), [size(volFlow, 2), size(volFlow, 3)]));
%     volFlow_im = flip(volFlow_im);
    enfaceFlow0(:,:,ff) = volFlow_im;
end
% enfaceFlow0 = imrotate3(enfaceFlow0,180,[0 1 0]);
enfaceFlow = imrotate3(enfaceFlow0,-90,[0 0 1]); % for OS orientation
%enfaceFlow = imrotate3(enfaceFlow0,180,[0 0 1]); % for OD orientation

% 'enfaceStruc' and 'enfaceFlow' volume data export
for k = 1:size(enfaceStruc,3)
    imID = 'enfaceStruc';
    im = enfaceStruc(:,:,k);
    if ~exist(fullfile(exportFolder,'ExportFiles', folderName, imID), 'dir')
        mkdir(fullfile(exportFolder,'ExportFiles', folderName, imID));
    end
    imwrite(im, fullfile(exportFolder,'ExportFiles', folderName, imID, [imID '_' num2str(k, '%03.0f') '.png']))
end
for kk = 1:size(enfaceFlow,3)
    imID = 'enfaceFlow';
    im = enfaceFlow(:,:,kk);
    if ~exist(fullfile(exportFolder,'ExportFiles', folderName, imID), 'dir')
        mkdir(fullfile(exportFolder,'ExportFiles', folderName, imID));
    end
    imwrite(im, fullfile(exportFolder,'ExportFiles', folderName, imID, [imID '_' num2str(kk, '%03.0f') '.png']))
end

end
