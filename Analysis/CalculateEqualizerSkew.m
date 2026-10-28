
function CalculateEqualizerSkew( frameout, sims, params, mode )


    ps =1e-12;
    if ( mode < 4 )
        mode1 = mode;
        if  ( frameout.fsfs.pol_est == 1)
            if ( mode == 2)
                mode1 = 3;
            end
            if ( mode == 3)
                mode1 = 2;
            end
        end
        skew_est_ps1     = EqualizerSkewEstimator( frameout.dfeout, params, mode1 );
        if ( length(frameout.fsfs.MaxPos) ~= 1 )
            skew_y_sync  = (frameout.fsfs.MaxPos(2) -frameout.fsfs.MaxPos(1) ) /params.RXSampleFreq/ps;
            if ( frameout.fsfs.pol_est == 1)
                skew_est_ps(1) = skew_est_ps1(4);
                skew_est_ps(2) = -skew_est_ps1(2) ;
                skew_est_ps(3) = -skew_est_ps1(2) + skew_est_ps1(1) ;
                skew_y_sync = -skew_y_sync;
            else
                skew_est_ps  = skew_est_ps1;
            end
            skew_est_ps(2) = skew_est_ps(2)+skew_y_sync;
            skew_est_ps(3) = skew_est_ps(3)+skew_y_sync;
        end 
        skew_est_ps = round(skew_est_ps*10)/10;
        disp2(sims.logfile,[ 'Prop skew ' num2str(skew_est_ps(1)+imag(params.skew.skew_ps(1))) '  ' ...
             num2str(skew_est_ps(2)+real(params.skew.skew_ps(2))), ' '  ...
             num2str(skew_est_ps(3)+imag(params.skew.skew_ps(2)))]);
    end
    if ( mode == 5 )    
        if (  params.dfe1.en == 1)
            [skew_est_ps1]     = EqualizerSkewEstimator( frameout.dfe1out, params, 5 );
            Xskew_ps = skew_est_ps1(1);
            Yskew_ps = skew_est_ps1(4);
            disp2(sims.logfile,[ 'TX Mea X, Y ' num2str(Xskew_ps) ', ' num2str(Yskew_ps)]);
        end
    end
end