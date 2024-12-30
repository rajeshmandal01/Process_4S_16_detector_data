%% data set reading
clear all;
data=readmatrix('org_bh_5.txt'); % intensity data [S-D-WL]
data=data(5:39,:);
%data=data(1:40,:);
%% calculating OD
[r,c]=size(data);
od_data=zeros([(r-1),c]); 
for i=1:(r-1)
    for j=1:c
        od_data(i,j)=log(data(i,j)/data((i+1),j));
    end 
end

ext=[GetExtinctions(670);GetExtinctions(740);GetExtinctions(770);GetExtinctions(810);GetExtinctions(850);GetExtinctions(950)]; 
%Returns the extinction coefficients for [HbO Hb H2O lipid aa3]
hbo_hb=ext(:,1:2)/1000;

wl_ext=[670,5.37,2.75;...
740,3.32,1.99;
770,3.66,1.83;...
810,3.93,1.64;...
850,3.85,1.57;...
950,2.6,1.53];
E=[wl_ext,hbo_hb]; %[oxCCO redCCo HbO Hb]

%% split and index the combinations
nsrc=4;
ndet=16;
nwL=6;


dataS = cell(1,nsrc);
for i = 1:nsrc
    dataS{i} = cell(1,ndet);    
    for j = 1:ndet
        dataS{i}{j} = cell(1,nwL);
        for k = 1:nwL
            dataS{i}{j}{k} = []; 
        end
    end
end

for i = 1:nsrc      
    for j = 1:ndet        
        for k = 1:nwL
            dataS{i}{j}{k} = data(:,i*j*k); 
        end
    end
end
% data is in this form now dataS{source index}{detectot index}{wave length index ([tx data])}

%% calaculating OD : log10 (V at t1/ V at t2)
od= cell(1,nsrc);
for i = 1:nsrc
    od{i} = cell(1,ndet);    
    for j = 1:ndet
        od{i}{j} = cell(1,nwL);
        for k = 1:nwL
            od{i}{j}{k} = []; 
        end
    end
end

[r,~]=size(dataS{1}{1}{1});

for i = 1:nsrc      
    for j = 1:ndet        
        for k = 1:nwL
            for p=1:r-1
            od{i}{j}{k}(p) = log10((dataS{i}{j}{k}(p))/(dataS{i}{j}{k}(p+1))); 
            end
        end
    end
end

%% Calculating the hbo hb hbt concentration change.
nMols=3;
conData= cell(1,nsrc);
for i = 1:nsrc
    conData{i} = cell(1,ndet);    
    for j = 1:ndet
        conData{i}{j} = cell(1,nMols);
        for k = 1:nMols
            conData{i}{j}{k} = []; 
        end
    end
end

E_hbOHb=E(:,4:5);   % row : 1-670nm, 2-740nm,3-770nm, 4-810nm, 5-850nm,6-950nm, column: 1-WL 2-oxcco,3-red cco, 4-hbo, 5-hb
E_hbOHb1=[E_hbOHb(2,:);E_hbOHb(4,:)];
ext=inv(E_hbOHb1);


wl1=2;wl2=5;
DPF=5;
for i = 1:nsrc      
    for j = 1:ndet
        for idx=1:length(od{1}{1}{1})
            R=sd_distance(i,j);
            temp=(1/R*DPF)*ext.*[od{i}{j}{wl1}(idx),od{i}{j}{wl2}(idx)];
            conData{i}{j}{1} =[conData{i}{j}{1};temp(1)];
            conData{i}{j}{2} = [conData{i}{j}{2};temp(2)];
            conData{i}{j}{3} = [conData{i}{j}{3};(temp(1)+temp(2))];

         end
    end
end


%% plotting data

windowSize = 5;                     % Size of the smoothing window
sigma = 3;                          % Standard deviation of the Gaussian kernel
x = -floor(windowSize/2):floor(windowSize/2); % Kernel range
gaussianKernel = exp(-x.^2 / (2*sigma^2));
gaussianKernel = gaussianKernel / sum(gaussianKernel);

s = 4;  % Moving average window size
t = 0:120/(r-2):120;  % Example time vector, replace with your actual data
% weights = [0.08, 0.3, 0.2];%[1.74, 2.18, 2.05, 1.92]; %[0.08, 0.3, 0.2, 0.02];
% weights = weights / sum(weights); % Normalize weights
% Create a new figure
for i=1:nsrc
figure(i);
% Loop through d from 1 to 16
for d = 1:16
    
    % Select the subplot position
    if d == 1
        m = 1;
    elseif d == 2
        m = 2;
    elseif d == 3
            m = 5;
    elseif d == 4
        m = 6;
    elseif d == 5 
            m = 3;
    elseif d == 6
        m = 4;
    elseif d == 7
            m = 7;
    elseif d == 8
        m = 8;
    elseif d == 9 
            m =9;
    elseif d == 10
        m = 10;
    elseif d == 11
            m = 13;
    elseif d == 12
        m = 14;
    elseif d == 13
        m = 11;
    elseif d == 14
            m = 12;
    elseif d == 15
        m = 15;
     elseif d == 16
        m = 16;
    end

    subplot(4, 4, m);  % Arrange subplots in a 4x4 grid
    
    % Plot the data for the current d
   
    plot(t, movmean(conData{i}{d}{1},s), 'r', 'LineWidth', 2); hold on;
    plot(t, movmean(conData{i}{d}{2},s), 'b', 'LineWidth', 2); hold on;
    plot(t, movmean(conData{i}{d}{3},s), 'k', 'LineWidth', 2); hold on
% plot(t, conv(conData{i}{d}{1},gaussianKernel,'same'), 'r', 'LineWidth', 2); hold on;
%     plot(t, conv(conData{i}{d}{2},gaussianKernel,'same'), 'b', 'LineWidth', 2); hold on;
%     plot(t, conv(conData{i}{d}{3},gaussianKernel,'same'), 'k', 'LineWidth', 2); hold on
    % Add title and labels for each subplot
    title(['d = ' num2str(d)]);
    xlabel('time (s)');
    ylabel('\Delta C (mM)');
    xline(40, 'k--', 'LineWidth', 1.5); % Red dashed line
    xline(50, 'k--', 'LineWidth', 1.5); % Green dash-dot line
    xline(90, 'k--', 'LineWidth', 1.5); % Black solid line
    xline(100, 'k--', 'LineWidth', 1.5); % Magenta dotted line
    grid on;
    if i==1
    ylim([-.035, 0.035]);
    elseif i==2
          ylim([-.025, 0.025]);
    elseif i==3
          ylim([-.035, 0.035]);
    elseif i==4
          ylim([-.0152, 0.0152]);
    end

    
    % Add legend for the first subplot only
    if d == 1
        legend('hbo', 'hb', 'hbT');
    end
end
end


%% Calculating the HbO Hb and oxCCO considering 6 wavelengths


Ediff= [E(3:6,2:3),E(3:6,4)-E(3:6,5)];
nMols=4;
conDataAll= cell(1,nsrc);
for i = 1:nsrc
    conDataAll{i} = cell(1,ndet);    
    for j = 1:ndet
        conDataAll{i}{j} = cell(1,nMols);
        for k = 1:nMols
            conDataAll{i}{j}{k} = []; 
        end
    end
end

% Calculate chromophore concentration changes
E_pinv = pinv(Ediff); 
%Delta_C = (E_pinv * Delta_OD') / R;  


DPF=5;
for i = 1:nsrc      
    for j = 1:ndet
        for idx=1:length(od{1}{1}{1})
            R=sd_distance(i,j);
%             temp1=[[od{i}{j}{2}]',[od{i}{j}{3}]',[od{i}{j}{4}]',[od{i}{j}{5}]',[od{i}{j}{6}]']; % 5 wave length excluding 670 nm
          temp1=[[od{i}{j}{3}]',[od{i}{j}{4}]',[od{i}{j}{5}]',[od{i}{j}{6}]']; % 4 wave length excluding 670 and 740 nm
          % temp1=[[od{i}{j}{1}]',[od{i}{j}{2}]',[od{i}{j}{3}]',[od{i}{j}{4}]',[od{i}{j}{5}]',[od{i}{j}{6}]'];
           temp= (E_pinv * temp1') / (R*DPF);
            conDataAll{i}{j}{1} =temp(1,:)';
            conDataAll{i}{j}{2} = temp(2,:)';
            conDataAll{i}{j}{3} = (temp(1,:)+temp(2,:))';
            conDataAll{i}{j}{4} = (temp(3,:))';

         end
    end
end

%% plotting data

windowSize = 5;                     % Size of the smoothing window
sigma = 3;                          % Standard deviation of the Gaussian kernel
x = -floor(windowSize/2):floor(windowSize/2); % Kernel range
gaussianKernel = exp(-x.^2 / (2*sigma^2));
gaussianKernel = gaussianKernel / sum(gaussianKernel);

s = 4;  % Moving average window size
t = 0:120/(r-2):120;  % Example time vector, replace with your actual data
% weights = [0.08, 0.3, 0.2];%[1.74, 2.18, 2.05, 1.92]; %[0.08, 0.3, 0.2, 0.02];
% weights = weights / sum(weights); % Normalize weights
% Create a new figure
for i=1:nsrc
figure(i);
% Loop through d from 1 to 16
for d = 1:16
    
    % Select the subplot position
    if d == 1
        m = 1;
    elseif d == 2
        m = 2;
    elseif d == 3
            m = 5;
    elseif d == 4
        m = 6;
    elseif d == 5 
            m = 3;
    elseif d == 6
        m = 4;
    elseif d == 7
            m = 7;
    elseif d == 8
        m = 8;
    elseif d == 9 
            m =9;
    elseif d == 10
        m = 10;
    elseif d == 11
            m = 13;
    elseif d == 12
        m = 14;
    elseif d == 13
        m = 11;
    elseif d == 14
            m = 12;
    elseif d == 15
        m = 15;
     elseif d == 16
        m = 16;
    end

    subplot(4, 4, m);  % Arrange subplots in a 4x4 grid
    
    % Plot the data for the current d
  
    plot(t, movmean(conDataAll{i}{d}{1},s),  'Color', [1, 0, 0], 'LineWidth', 2); hold on;
    plot(t, movmean(conDataAll{i}{d}{2},s), 'Color', [0, 0, 1],'LineWidth', 2); hold on;
    plot(t, movmean(conDataAll{i}{d}{3},s), 'Color', [0, 0, 0], 'LineWidth', 2); hold on
    plot(t, movmean(conDataAll{i}{d}{4},s),'Color', [.2, 0.7, 0],  'LineWidth', 2); hold on

% plot(t, conv(conData{i}{d}{1},gaussianKernel,'same'), 'r', 'LineWidth', 2); hold on;
%     plot(t, conv(conData{i}{d}{2},gaussianKernel,'same'), 'b', 'LineWidth', 2); hold on;
%     plot(t, conv(conData{i}{d}{3},gaussianKernel,'same'), 'k', 'LineWidth', 2); hold on
    % Add title and labels for each subplot
    title(['d = ' num2str(d)]);
    xlabel('time (s)');
    ylabel('\Delta C (mM)');
    xline(40, 'k--', 'LineWidth', 1.5); % Red dashed line
    xline(50, 'k--', 'LineWidth', 1.5); % Green dash-dot line
    xline(90, 'k--', 'LineWidth', 1.5); % Black solid line
    xline(100, 'k--', 'LineWidth', 1.5); % Magenta dotted line
    grid on;
%     if i==1
%     ylim([-.0045, 0.0045]);
%     elseif i==2
%           ylim([-.0045, 0.0045]);
%     elseif i==3
%           ylim([-.0045, 0.0045]);
%     elseif i==4
%           ylim([-.0045, 0.0045]);
%     end

    
    % Add legend for the first subplot only
    if d == 1
        legend('hbo', 'hb', 'hbT','oxCCO','Location','best');
    end
end
end










% Extract Δ[oxCCO]
% Delta_oxCCO1 = Delta_C(1, :);
% Delta_oxCCO2 = Delta_C(2, :);
% Delta_oxCCO3 = Delta_C(3, :);
% % Delta_oxCCO1=Delta_oxCCO1-mean(Delta_oxCCO1);
% % Delta_oxCCO2=Delta_oxCCO2-mean(Delta_oxCCO2);
% % Delta_oxCCO3=Delta_oxCCO3-mean(Delta_oxCCO3);
% 
% % [upperEnv1, lowerEnv1] = envelope(Delta_oxCCO1, 10 , 'peak');
% % [upperEnv2, lowerEnv2] = envelope(Delta_oxCCO2, 10, 'peak');
% % [upperEnv3, lowerEnv3] = envelope(Delta_oxCCO3,10, 'peak');
% 
% % Plot oxCCO changes
% s=4;
% time = 1:120/46:120;
% %  plot(time, movmean(Delta_oxCCO1,1), 'LineWidth', 2);
% % % hold on;
% % % plot(time, upperEnv1, 'LineWidth', 2); 
% % 
% % hold on,
% % 
% % plot(time, movmean(Delta_oxCCO2,s), 'LineWidth', 2);
% % % hold on;
% % % plot(time, upperEnv2, 'LineWidth', 2); hold on;
% % hold on;
% % plot(time, movmean(Delta_oxCCO3,s), 'LineWidth', 2); 
% % hold on,
% plot(time, abs(hilbert(Delta_oxCCO1))-mean(abs(hilbert(Delta_oxCCO1))), 'LineWidth', 2);
% hold on,
% plot(time, abs(hilbert(Delta_oxCCO2))-mean(abs(hilbert(Delta_oxCCO2))), 'LineWidth', 2);
% hold on;
% plot(time, abs(hilbert(Delta_oxCCO3))-mean(abs(hilbert(Delta_oxCCO3))), 'LineWidth', 2);
% xlabel('Time');
% ylabel('\Delta[oxCCO]');
% title('Changes in oxCCO');
% legend('hbo','hb','oxCC')
% 
% end
% 
% 
% 
% 
% % wl1=2;wl2=5;
% % DPF=5;
% % for i = 1:nsrc      
% %     for j = 1:ndet
% %         for idx=1:length(od{1}{1}{1})
% %             R=sd_distance(i,j);
% %             temp=(1/R*DPF)*ext.*[od{i}{j}{wl1}(idx),od{i}{j}{wl2}(idx)];
% %             conData{i}{j}{1} =[conData{i}{j}{1};temp(1)];
% %             conData{i}{j}{2} = [conData{i}{j}{2};temp(2)];
% %             conData{i}{j}{3} = [conData{i}{j}{3};(temp(1)+temp(2))];
% % 
% %          end
% %     end
% % end
%%
% windowSize = 6;                     % Size of the smoothing window
% sigma = 2;                          % Standard deviation of the Gaussian kernel
% x = -floor(windowSize/2):floor(windowSize/2); % Kernel range
% gaussianKernel = exp(-x.^2 / (2*sigma^2));
% gaussianKernel = gaussianKernel / sum(gaussianKernel);
% for k=1:2
%     
%  % Normalize kernel
%  %conv(data, gaussianKernel, 'same');
%     plot(t, conData{1}{1}{k}, 'LineWidth', 2);
%     hold on;
%     plot(t, movmean(conData{1}{1}{1},6), 'LineWidth', 2); hold on;
%     plot(t,  conv(conData{1}{1}{1},gaussianKernel,'same'), 'LineWidth', 2); 
%    
% end
%  legend('hbo','AAvsmooth','filt','hb','AAvsmoothhb','filthb');