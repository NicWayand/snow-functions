clear all; close all; clc; 

% Calculate compaction of snow layers

%% Define parameters
%! ********************************************************************
%! snow compaction Default values
%! ********************************************************************
% densScalGrowth            |       0.0460 |       0.0230 |       0.0920
% tempScalGrowth            |       0.0400 |       0.0200 |       0.0600
% grainGrowthRate           |       2.7d-6 |       1.0d-6 |       5.0d-6
% densScalOvrbdn            |       0.0230 |       0.0115 |       0.0460 
% tempScalOvrbdn            |       0.0800 |       0.0600 |       0.10000 
% base_visc                 |       9.0d+5 |       5.0d+5 |       1.5d+6

% densScalGrowth  (BIG impact)  Lower values higher compaction rates
% tempScalGrowth  (small impact) Lower values higher compaction rates 
% grainGrowthRate  (med impact)  Higher values higher compaction rates 
% densScalOvrbdn  (BIGimpact) Lower values equal higher compaction rates 
% tempScalOvrbdn- (Little impact)        
% base_visc       (med impact) lower values equal higher compaction rates


densScalGrowth            =       0.0460; %|       0.0330 |       0.0920
tempScalGrowth            =       0.0400; %|       0.0200 |       0.0600
grainGrowthRate           =       2.7d-6; %|       1.0d-6 |       5.0d-6
densScalOvrbdn            =       0.0230; %|       0.0200 |       0.0460
tempScalOvrbdn            =       0.0800; %|       0.06000 |      0.1000
base_visc                 =       9.0d+5; %|       5.0d+5 |       1.5d+6

densScalGrowth_all = [0.0330 0.0460 0.0920];
tempScalGrowth_all = [0.0200 0.0400 0.0600];
grainGrowthRate_all = [1.0d-6 2.7d-6 5.0d-6];
densScalOvrbdn_all = [0.0200   0.0230     0.0460];
tempScalOvrbdn_all = [0.06000 0.0800    0.1000];
base_visc_all = [5.0d+5 9.0d+5 1.5d+6];

for cParam = 1:3
    
%     densScalOvrbdn = densScalOvrbdn_all(cParam);
%     tempScalOvrbdn = tempScalOvrbdn_all(cParam);
%     densScalGrowth = densScalGrowth_all(cParam);
%     tempScalGrowth = tempScalGrowth_all(cParam); 
%     grainGrowthRate = grainGrowthRate_all(cParam);
    base_visc = base_visc_all(cParam);
    %% Constants

    iden_ice = 917;

    %% Define initial state variables

    % % From a crash compaction experiment where density reached > 917 kg m^3
    % layerType          = [ 1002 1002 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001];
    % mLayerDepth        = [    0.02203     0.02682     0.02000     0.04000     0.04000     0.03000     0.03000     0.03000     0.03000     0.03000     0.04000     0.03000     0.04000     0.03000     0.01500     0.01000     0.08500     0.25000     0.25000     0.50000     0.50000];
    % mLayerTemp         = [  272.00984   273.07233   272.98578   272.91114   272.85716   272.84157   272.84333   272.85592   272.87522   272.89761   272.92408   272.94810   272.97020   272.99081   273.00390   273.01118   273.03903   273.15188   273.15683   273.15724   273.15748];
    % mLayerVolFracIce   = [    0.62111     1.00038     0.25778     0.27302     0.28092     0.28329     0.28364     0.28281     0.28109     0.27875     0.27551     0.27208     0.26837     0.26427     0.26125     0.25940     0.25086     0.06169     0.00120     0.00009     0.00012];
    % mLayerVolFracLiq   = [    0.00017     0.04775     0.16223     0.15082     0.14520     0.14384     0.14399     0.14509     0.14691     0.14926     0.15242     0.15576     0.15934     0.16325     0.16610     0.16783     0.17574     0.34331     0.40038     0.40628     0.40987];

    % From a crash compaction experiment where density reached > 917 kg m^3
    layerType          = [ 1002 1002 1002 1002 1002 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001 1001];
    mLayerDepth        = [ 0.02203 0.02203 0.02203   0.02203     0.02682     0.02000     0.04000     0.04000     0.03000     0.03000     0.03000     0.03000     0.03000     0.04000     0.03000     0.04000     0.03000     0.01500     0.01000     0.08500     0.25000     0.25000     0.50000     0.50000];
    mLayerTemp         = [ 272.00984 272.00984 272.00984 272.00984   272.07233   272.98578   272.91114   272.85716   272.84157   272.84333   272.85592   272.87522   272.89761   272.92408   272.94810   272.97020   272.99081   273.00390   273.01118   273.03903   273.15188   273.15683   273.15724   273.15748];
    mLayerVolFracIce   = [  0.1 0.2 0.3  0.3         0.6     0.25778     0.27302     0.28092     0.28329     0.28364     0.28281     0.28109     0.27875     0.27551     0.27208     0.26837     0.26427     0.26125     0.25940     0.25086     0.06169     0.00120     0.00009     0.00012];
    mLayerVolFracLiq   = [  0.00017 0.00017 0.00017  0.00017     0.002     0.16223     0.15082     0.14520     0.14384     0.14399     0.14509     0.14691     0.14926     0.15242     0.15576     0.15934     0.16325     0.16610     0.16783     0.17574     0.34331     0.40038     0.40628     0.40987];


    % Estiated or taken from output
    mLayerMeltFreeze   = [zeros(1,length(mLayerDepth))]; % volumetric melt in each layer (kg m-3)
    scalarSnowSublimation = 1.05414172965051e-11; % sublimation from the snow surface (kg m-2 s-1)

    nSnow = sum(layerType==1002);

    %% Calculate Compaction
    nDt = 10000; %number of time steps
    dt = 3600*10; % s

    outofbounds = false;
    
    sprintf('Running %d Days\n',nDt*dt/(60*60*24))
    for cts = 2:1:nDt
        if ~outofbounds
            [mLayerDepth(cts,:) mLayerVolFracIce(cts,:)  mLayerVolFracLiq(cts,:)...
                CR_grainGrowth_all(cts,:) CR_ovrvdnPress_all(cts,:)]  = ...
                ...
                CalcSnowCompaction_TEST(mLayerDepth(cts-1,:),...
                mLayerTemp,...
                mLayerVolFracIce(cts-1,:),mLayerVolFracLiq(cts-1,:),...
                densScalGrowth,tempScalGrowth,grainGrowthRate,densScalOvrbdn,tempScalOvrbdn,base_visc,dt,nSnow,...
                mLayerMeltFreeze,scalarSnowSublimation);

            if(any(mLayerVolFracIce(cts,1:nSnow)*iden_ice < 50) | ...
                any(mLayerVolFracIce(cts,1:nSnow)*iden_ice > 900))
                   outofbounds = true;
            end
        end

    end
    %% Plot compaction rates
    % colormap1 = cbrewer('div', 'RdYlBu', 10, 'cubic');
    colormap1 = cbrewer('qual', 'Set1', 10, 'cubic');
    Nruns = size(mLayerDepth,1);


    % Depths
    figure(1); hold on
    
    subplot(1,2,1); hold on
    for cL = 1:nSnow
        pl(cL) = plot((1:Nruns)*dt./(60*60),mLayerDepth(:,cL).*1000,'-k','color',colormap1(cL,:));
    end
    xlabel('time (hrs)')
    ylabel('depth (mm)')
    legend(pl(:),num2str((1:nSnow)'))


    % Density of layers
    subplot(1,2,2); hold on
    for cL = 1:nSnow
        pl(cL) = plot((1:Nruns)*dt./(60*60),mLayerVolFracIce(:,cL)*iden_ice,'-k','color',colormap1(cL,:));
    end
    xlabel('time (hrs)')
    ylabel('density (kg m^-^3)')
    legend(pl(:),num2str((1:nSnow)'))
    
    % Contributions to compaction
    figure(2); hold on
%     subplot(1,2,1); hold on
    for cL = 1:nSnow
        pl(cL) = plot((1:Nruns)*dt./(60*60),CR_grainGrowth_all(:,cL),'-k'); %,'color',colormap1(cL,:));
    end
    xlabel('time (hrs)')
    ylabel('Rate ')
    
%     subplot(1,2,2); hold on
    for cL = 1:nSnow
        p2(cL) = plot((1:Nruns)*dt./(60*60),CR_ovrvdnPress_all(:,cL),'-r'); %,'color',colormap1(cL,:));
    end
    xlabel('time (hrs)')
    ylabel('Rate ')
    

    
%     legend([pl(1) p2(1)],{'GrainGrowth' 'Overburden'})

end





