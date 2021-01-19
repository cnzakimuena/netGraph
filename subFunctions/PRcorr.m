
function [PRflowVol2] = PRcorr(strucVol, flowVol, size_red, fBM)

PRflowVol = zeros(size(strucVol));
PRflowVol2 = zeros(size(strucVol));
% A-scans extraction

volMax = max(max(max(strucVol)));

fSize = 40;
fSize2 = 20;
fSize3 = 15;
lSize = 4;
lSize2 = 2;
        
for pp = 1:size(strucVol, 3)
    
    im1 = flowVol(:, :, pp);
    im2 = strucVol(:, :, pp);

    corrB_scan0 = zeros(size(im1));
    
    for kk = 1:size(im1, 2)
        
        A_scan1 = im1(:,kk);
        
        % arbitrary very small constant (in proportion, i.e., 0.0001*x) 
        % added to avoid division by 0
        A_scan2 = im2(:,kk)+round(50*size_red);
%         A_scan2 = im2(:,kk)+0.0001*volMax;
        
        x = 1:1:size(A_scan1);
        
        % normalised decoloration
        norm = double(A_scan1)./double(A_scan2);
        A1 = A_scan1;
        
        for fff = 1:numel(norm)
            c_ind = norm(fff); % current location along normalised A-scan
            if c_ind < max(norm(1:fff))
                A1(fff) = 0;
            end
        end
        
%         figure;
%         % get(f1,'Position')
%         % move right | move up | expand right | expand up
%         set(gcf, 'Position',  [450, 1050, 1200, 800])
%         subplot(141); % flow A-scan data
%         plot(A_scan1(180:280), x(180:280),'color',rgb('Black'),'LineWidth',lSize2)
%         xlim([0 0.4])
%         set(gca,'XTick',(0:0.2:0.4))
%         set(gca, 'YDir','reverse')
%         set(gca,'linewidth',lSize2)
%         a1 = get(gca,'XTickLabel');
%         set(gca,'XTickLabel',a1,'fontsize',fSize3)
%         xlabel('D','fontweight','bold','FontSize',fSize2)
%         ylabel('A-scan location (px)','fontweight','bold','FontSize',fSize2)
%         
%         subplot(142); % structural A-scan data
%         plot(A_scan2(180:280), x(180:280),'color',rgb('Black'),'LineWidth',lSize2)
%         xlim([20 20.8])
%         set(gca,'XTick',(20:0.4:20.8))
%         set(gca, 'YDir','reverse')
%         set(gca,'linewidth',lSize2)
%         a1 = get(gca,'XTickLabel');
%         set(gca,'XTickLabel',a1,'fontsize',fSize3)
%         xlabel('S+k','fontweight','bold','FontSize',fSize2)
%         
%         subplot(143); % normalised A-scan data
%         plot(norm(180:280), x(180:280),'color',rgb('Black'),'LineWidth',lSize2)
%         xlim([0 0.02])
%         set(gca,'XTick',(0:0.01:0.02))
%         set(gca, 'YDir','reverse')
%         set(gca,'linewidth',lSize2)
%         a1 = get(gca,'XTickLabel');
%         set(gca,'XTickLabel',a1,'fontsize',fSize3)
%         xlabel('F','fontweight','bold','FontSize',fSize2)
%         
%         subplot(144); % normalised A-scan data
%         plot(A1(180:280), x(220:320),'color',rgb('Black'),'LineWidth',lSize2)
%         xlim([0 0.4])
%         set(gca,'XTick',(0:0.2:0.4))
%         set(gca, 'YDir','reverse')
%         set(gca,'linewidth',lSize2)
%         a1 = get(gca,'XTickLabel');
%         set(gca,'XTickLabel',a1,'fontsize',fSize3)
%         xlabel('C','fontweight','bold','FontSize',fSize2)    
% %         suptitle('I am a super title')
% %         figure
% %         imtool([im1 im2])
        
        % corrB_scan0 = [corrB_scan0 A1];
        corrB_scan0(:,kk) = A1;
    end
    % imshow(corrB_scan0,[])
    % B-scan dilation according to known average diameter of maximum
    % vessels size
    disk_size = round(size_red*8);
    SE = strel('line',disk_size,90);
    corrB_scan = imdilate(corrB_scan0,SE);
    
    % *outer retina artifact removal*
    wt = 20;
    % chartColors1.c2 = rgb('MediumPurple'); 
    % chartColors2.c2 = rgb('Orange');
    % fBM2 = fBM - wt;
    % figure;
    % imshow(corrB_scan);
    % hold on;
    % plot(fBM(pp,:),'color',chartColors1.c2,'LineWidth',2);
    % plot(fBM2(pp,:),'color',chartColors2.c2,'LineWidth',2);
    cropMask = zeros(size(corrB_scan));
    for rr = 1:size(cropMask, 2)
        cropMask(1:fBM(pp,rr)-wt,rr) = 1;
    end
    corrB_scan2 = cropMask.*corrB_scan;
    % figure;
    % imshow([corrB_scan corrB_scan2],[])
    
    % imshow([corrB_scan0 corrB_scan],[])
    % imshow([im1 corrB_scan],[])
    PRflowVol(:,:,pp) = corrB_scan;
    PRflowVol2(:,:,pp) = corrB_scan2;
    
end

% figure;imshow(PRflowVol2(:,:,300),[]),hold on,plot(fBM(150,:),'Color',rgb('White'),'LineWidth',2)
% figure;
% imshow3D(flowVol,[])
% figure;
% imshow3D(PRflowVol,[])
% figure;
% imshow3D(PRflowVol2,[])

    