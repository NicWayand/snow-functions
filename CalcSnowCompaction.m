function [mLayerDepth mLayerVolFracIceNew  mLayerVolFracLiqNew CR_grainGrowth_all CR_ovrvdnPress_all] = CalcSnowCompaction_TEST(mLayerDepth,mLayerTemp,mLayerVolFracIceNew,mLayerVolFracLiqNew,...
    densScalGrowth,tempScalGrowth,grainGrowthRate,densScalOvrbdn,tempScalOvrbdn,base_visc,dt,nSnow,mLayerMeltFreeze,...
    scalarSnowSublimation)

% Coded from SUMMA fortran into Matlab for testing reasonable ranges of
% parameter values for experiment

 % Constants
iden_ice = 917;
iden_water = 1000;
Tfreeze = 273.16;

% Parameters
snwden_min=100;
snwDensityMax=550;
wetSnowThresh=0.01;
% dt_toler=0.1; % not used in SUMMA or here

 
 % initialize the weight of snow above each layer (kg m-2)
 weightSnow = 0;
 
 % loop through snow layers (top to bottom?)
 for iSnow= 1:nSnow
          % print starting density
          %write(*,'(a,1x,i4,1x,f9.3)') 'b4 compact: iSnow, density = ', iSnow, mLayerVolFracIceNew(iSnow)*iden_ice
          % save mass of liquid water and ice (mass does not change)
          massIceOld = iden_ice*mLayerVolFracIceNew(iSnow)*mLayerDepth(iSnow);   % (kg m-2)
          massLiqOld = iden_water*mLayerVolFracLiqNew(iSnow)*mLayerDepth(iSnow); % (kg m-2)
          % *** compute the compaction associated with grain growth (s-1)
          % compute the base rate of grain growth (-)
          if(mLayerVolFracIceNew(iSnow)*iden_ice <snwden_min);
              chi1=1;
          elseif(mLayerVolFracIceNew(iSnow)*iden_ice>=snwden_min) 
              chi1=exp(-densScalGrowth*(mLayerVolFracIceNew(iSnow)*iden_ice - snwden_min));
          end
          % compute the reduction of grain growth under colder snow temperatures (-)
          chi2 = exp(-tempScalGrowth*(Tfreeze - mLayerTemp(iSnow)));
          % compute the acceleration of grain growth in the presence of liquid water (-)
          if(mLayerVolFracLiqNew(iSnow) > wetSnowThresh)
              chi3=2;  % snow is "wet"
          else
              chi3=1;  % snow is "dry"
          end                                      
          % compute the compaction associated with grain growth (s-1)
          CR_grainGrowth = grainGrowthRate*chi1*chi2*chi3;
          % **** compute the compaction associated with over-burden pressure (s-1)
          % compute the weight imposed on the current layer (kg m-2)
          halfWeight = (massIceOld + massLiqOld)/2;  % there is some over-burden pressure from the layer itself
          weightSnow = weightSnow + halfWeight;         % add half of the weight from the current layer
          % compute the increase in compaction under colder snow temperatures (-)
          chi4 = exp(-tempScalOvrbdn*(Tfreeze - mLayerTemp(iSnow)));
          % compute the increase in compaction under low density snow (-)
          chi5 = exp(-densScalOvrbdn*mLayerVolFracIceNew(iSnow)*iden_ice);
          % compute the compaction associated with over-burden pressure (s-1)
          CR_ovrvdnPress = (weightSnow/base_visc)*chi4*chi5;
          % update the snow weight with the halfWeight not yet used
          weightSnow = weightSnow + halfWeight;          % add half of the weight from the current layer
          % *** compute the compaction rate associated with snow melt (s-1)
          % NOTE: loss of ice due to snowmelt is implicit, so can be updated directly
          if(iden_ice*mLayerVolFracIceNew(iSnow) < snwDensityMax) % only collapse layers if below a critical density
           % (compute volumetric losses of ice due to melt and sublimation)
           if(iSnow==1)  % if top snow layer include sublimation and melt
            volFracIceLoss = max(0,mLayerMeltFreeze(iSnow)/iden_ice - dt*(scalarSnowSublimation/mLayerDepth(iSnow))/iden_ice );
           else
            volFracIceLoss = max(0,mLayerMeltFreeze(iSnow)/iden_ice);  % volumetric fraction of ice lost due to melt (-)
           end
           % (adjust snow depth to account for cavitation)
           scalarDepthNew = mLayerDepth(iSnow) * mLayerVolFracIceNew(iSnow)/(mLayerVolFracIceNew(iSnow) + volFracIceLoss);
           %print*, 'volFracIceLoss = ', volFracIceLoss
          else
           scalarDepthNew = mLayerDepth(iSnow);
          end
          % compute the total compaction rate associated with metamorphism
          CR_metamorph = CR_grainGrowth + CR_ovrvdnPress;
          % update depth due to metamorphism (implicit solution)
          mLayerDepth(iSnow) = scalarDepthNew/(1 + CR_metamorph*dt);
          % check that depth is reasonable
          if(mLayerDepth(iSnow) < 0)
              disp('depth less than zero, print out things')
              return
        %    sprintf('(a,1x,i4,1x,10(f12.5,1x))') 'iSnow, dt, density, massIceOld, massLiqOld = ', iSnow, dt, mLayerVolFracIceNew(iSnow)*iden_ice, massIceOld, massLiqOld
        %    sprintf('(a,1x,i4,1x,10(f12.5,1x))') 'iSnow, mLayerDepth(iSnow), scalarDepthNew, mLayerVolFracIceNew(iSnow), mLayerMeltFreeze(iSnow), CR_grainGrowth*dt, CR_ovrvdnPress*dt = ',...
        %                                          iSnow, mLayerDepth(iSnow), scalarDepthNew, mLayerVolFracIceNew(iSnow), mLayerMeltFreeze(iSnow), CR_grainGrowth*dt, CR_ovrvdnPress*dt
          end
          % update volumetric ice and liquid water content
          mLayerVolFracIceNew(iSnow) = massIceOld/(mLayerDepth(iSnow)*iden_ice);
          mLayerVolFracLiqNew(iSnow) = massLiqOld/(mLayerDepth(iSnow)*iden_water);
          %write(*,'(a,1x,i4,1x,f9.3)') 'after compact: iSnow, density = ', iSnow, mLayerVolFracIceNew(iSnow)*iden_ice
          %if(mLayerMeltFreeze(iSnow) > 20) pause 'meaningful melt'
          
          % Save metamorph sources
          CR_grainGrowth_all(iSnow) = CR_grainGrowth;
          CR_ovrvdnPress_all(iSnow) = CR_ovrvdnPress;
          
 end  % looping through snow layers (iSnow)
 
 

 % check depth
 if(any(mLayerDepth(1:nSnow) < 0))
  for iSnow=1:nSnow
   sprintf('(a,1x,i4,1x,4(f12.5,1x))) iSnow, mLayerDepth(iSnow)', iSnow, mLayerDepth(iSnow));
  end
 end

 % check for low/high snow density
 if(any(mLayerVolFracIceNew(1:nSnow)*iden_ice < 50) | ...
    any(mLayerVolFracIceNew(1:nSnow)*iden_ice > 900))
        disp('Density out of bounds')
        mLayerVolFracIceNew(1:nSnow)*iden_ice
%   for iSnow=1,nSnow
%    write(*,'(a,1x,i4,1x,f9.3)') 'iSnow, density = ', iSnow, mLayerVolFracIceNew(iSnow)*iden_ice
%   end do

 end

