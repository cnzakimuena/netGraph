
function [node2,link2] = vessNetwork2(skeleton, saveFolder, saveName, graphID)

% node/link are the structures describing node and link properties
% the nodes and links are numbered
%
% A node has the following properties:
% 	idx List of voxel indices of this node (single or multiple indexes of voxels that were used to define the current node)
% 	links List of links connected to this node (links which are connected to the current node; identified by their assigned link number)
% 	conn List of destinations of links of this node (destination nodes of the links connected to the current node; identified by their assigned node number)
% 	comX,comY,comZ Center of mass of all voxels of this node
% 	ep 1 if node is endpoint (degree 1), 0 otherwise
% 	label (section of the whole skeleton to which the current node belongs; identified by its assigned section number)
%
% A link has the following properties:
% 	n1 Node where link starts
% 	n2 Node where link ends
% 	point List of voxel indices of this link
% 	label %section of the whole skeleton to which the current link belongs (identified by its assigned section number)

w = size(skeleton,1);
l = size(skeleton,2);
h = size(skeleton,3);

% initial step: condense, convert to voxels and back, detect cells
[~,node,link] = Skel2Graph3D(skeleton,0);

% total length of network
wl = sum(cellfun('length',{node.links}));

skel2 = Graph2Skel3D(node,link,w,l,h);
[~,node2,link2] = Skel2Graph3D(skel2,0);

if graphID == 0
    % COMMENT (disable with '%') ALL CODE BELOW FOR NETWORK DATA ONLY
    
    % calculate new total length of network
    wl_new = sum(cellfun('length',{node2.links}));
    
    % iterate the same steps until network length changed by less than 0.5%
    while(wl_new~=wl)
        
        wl = wl_new;
        
        skel2 = Graph2Skel3D(node2,link2,w,l,h);
        [~,node2,link2] = Skel2Graph3D(skel2,0);
        
        wl_new = sum(cellfun('length',{node2.links}));
        
    end
    
    if ~exist(fullfile(saveFolder,'Results'), 'dir')
        mkdir(fullfile(saveFolder,'Results'));
    end
    if ~exist(fullfile(saveFolder,'Results', saveName), 'dir')
        mkdir(fullfile(saveFolder,'Results', saveName));
    end
    
    set(0,'DefaultFigureVisible','off');
    
    % display result
    fig = figure; %figure();
    
    hold on;
    for i=1:length(node2)
        x1 = node2(i).comx;
        y1 = node2(i).comy;
        z1 = node2(i).comz;
        
        if(node2(i).ep==1)
            
%             ncol = 'm'; % end nodes are majenta
            ncol = rgb('MediumPurple'); % end nodes are majenta
        else
%             ncol = 'y'; % nodes are yellow
            ncol = rgb('MediumPurple'); % nodes are yellow
        end
        
        for j=1:length(node2(i).links)    % draw all connections of each node
            if(node2(node2(i).conn(j)).ep==1)
%                 col='c'; % branches are cyan
                col = rgb('Orange'); % branches are cyan
            else
%                 col='g'; % links are green
                col = rgb('Orange'); % links are green
            end
            if(node2(i).ep==1)
%                 col = 'c';
                col = rgb('Orange');
            end
            
            
            % draw edges as lines using voxel positions
            for k=1:length(link2(node2(i).links(j)).point)-1
                [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k));
                [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1));
                line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
            end
        end
        
        % draw all nodes as yellow circles
%         plot3(y1,x1,z1,'o','Markersize',3,...
%             'MarkerFaceColor',ncol,...
%             'Color','w');
        plot3(y1,x1,z1,'o','Markersize',3,...
            'MarkerFaceColor',ncol,...
            'Color',ncol);
        xlabel('Volume');
        ylabel('B-Scan');
        zlabel('A-Scan');
        
%         title('Vessels Network')
        a1 = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a1,'fontsize',14)
        
    end
    
    axis([0 size(skeleton,1) 0 size(skeleton,2) 0 size(skeleton,3)])
    
    xlim([0 size(skeleton,3)])
    ylim([0 size(skeleton,3)])
    set(gca,'XTick',[0 150 300 450 600]); %This are going to be the only values affected.
    set(gca,'XTickLabel',[0 0.75 1.5 2.25 3.0]); %This is what it's going to appear in those places.
    set(gca,'YTick',[0 150 300 450 600]); %This are going to be the only values affected.
    set(gca,'YTickLabel',[0 0.75 1.5 2.25 3.0]); %This is what it's going to appear in those places.
    set(gca,'ZTick',[0 300 600]); %This are going to be the only values affected.
    set(gca,'ZTickLabel',[0 1500 3000]); %This is what it's going to appear in those places.
    
    %axis image;%axis off;
    set(gcf,'Color','white');
    drawnow;
    darkBackground(fig,[0 0 0],[1 1 1])   
    
    % view can be changed after the graph has been displayed
    az = 50;el = -70;view(az, el); %angled view
    saveas(fig, fullfile(saveFolder,'Results', saveName, 'network_angledView'), 'jpeg');
    az = -70;el = -10;view(az, el); %side view
    saveas(fig, fullfile(saveFolder,'Results', saveName, 'network_sideView'), 'jpeg');
    az = 0;el = -90;view(az, el); %top view
    saveas(fig, fullfile(saveFolder,'Results', saveName, 'network_topView'), 'jpeg');
    
    set(0,'DefaultFigureVisible','on');
    
end

end