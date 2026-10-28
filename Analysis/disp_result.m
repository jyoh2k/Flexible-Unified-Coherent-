function  disp_result( simout, frameout, sim, params )  
    if nargin < 4
        if nargin < 1
            disp([' || OSNR ||  BER  || EVM  ||']);
        else
            disp2(sim.logfile, [' || OSNR || BER  || EVM  ||']);
        end
        return; 
    end 
    
%     [pol_est,pol_est0] =  est_pol( simout, frameout, sim, params )  ;
        if ( sim.en_disp_result == 1 )
            str = '';
            str = [str  ' || ', num2str( sim.X_val ), '  ' ];
%             str = [str  ' || ', num2str(sim.channel.SNRdB(1)), ' ' ];
            str = [str  ' || ', num2str(mean(simout.BER(1:simout.Totframe))) ];
            str = [str  ' || ', num2str(mean(simout.EVM(1:simout.Totframe))) ];
            str = [str  ' || ', num2str(frameout.cfrout.cfo_est * params.RXSampleFreq /1e6, '%1.2E '), ' MHz' ];
            %str = [str  ' || ', num2str(mean(simout.MSFE(1:simout.Totframe))) ];
            %str = [str  ' || ', num2str(mean(simout.MSPE(1:simout.Totframe))) ];
%             str = [str  ' || ', num2str(frameout.BER) ];
%             str = [str  ' || ', num2str(frameout.EVM) ];
%             str = [str  ' || ', num2str(frameout.cfrout.cfo_est * params.RXSampleFreq /1e9  ) ];
%             str = [str  ' || ', num2str( mean(  simout.MSTE (1:simout.Totframe)))  ];
            str = [str  ' || ', num2str(simout.Totframe ), ' Fr.' ];
            disp2(sim.logfile, [ str,    '  || '])
    %           ' || ', num2str(simout.EVM_avg), ... 
    %             ' || ', num2str(simout.CS_MSRE), ...
    %             ' || ',num2str(simout.CS_max), ...
    %             ' || ', num2str(simout.FS_MSRE), ...
    %             ' || ',num2str(simout.FS_max), ...
    %             ' ||  ',num2str(sqrt(simout.MSEE)/ ( 2*pi/ params.RXSampleFreq)/1e6), ...  
    %             ' || ']);
        end
        
        if ( sim.en_disp_result == 2 )
            str = '';
            str = [str  ' || ', num2str( sim.X_val ), '  ' ];
            str = [str  ' || ', num2str(frameout.codedBER) ];
            str = [str  ' || ', num2str(frameout.BER) ];
            str = [str  ' || ', num2str(frameout.EVM) ];
            if ( params.ps.en == 1)
                str = [str  ' || ', num2str(frameout.NGMI) ];
            end
            str = [str  ' || ', num2str(frameout.cfrout.cfo_est * params.RXSampleFreq /1e6, '%1.2E '), ' MHz' ];
%             str = [str  ' || ', num2str(frameout.cfrout.rcfo_est * params.RXSampleFreq /1e6, '%1.2E '  ), ' MHz' ];
            str = [str  ' || ', num2str(frameout.pee , '%1.2E '  ), '  ' ];
            str = [str  ' || ', num2str( mean(  simout.MSTE (1:simout.Totframe)))  ];
%             str = [str  ' || ', num2str( floor(pol_est(1) * 180/pi)) , ' °  ' ]; 
            str = [str  ' || ', num2str(simout.Totframe ), ' Fr. ' ];
            disp2(sim.logfile, [ str,    '  || '])
        end
        if (  ~isempty(sim.evm_text) &&  ishandle(sim.evm_text) )
            mean_EVM = mean(simout.EVM(1:simout.Totframe));
            mean_EVM_Str = num2str(mean_EVM) ;
            set(sim.evm_text, 'String', [ mean_EVM_Str  ' dB'] );
            %Ntotal set(sim.figure_handle.text5, 'String', [ num2str(frameout.EVM) 'dB'] );
            %Nerror set(sim.figure_handle.text4, 'String', [ num2str(frameout.EVM) 'dB'] );
            set(sim.figure_handle.edit5_2, 'String', [ num2str(params.databits) ''] );
            set(sim.figure_handle.edit5_3, 'String', [ num2str(frameout.Nbiterr) ''] );
            mean_BER = num2str(mean(simout.BER(1:simout.Totframe)), '%1.1E ') ;
%             est_BER = num2str(estimate_EVM2BER( mean_EVM, params), '%1.1E ') ;
%             set(sim.figure_handle.edit5_4, 'String', [  mean_BER ', ' est_BER ] );
set(sim.figure_handle.edit5_4, 'String', [  mean_BER  ] );
            set(sim.figure_handle.text5_4, 'String', [ 'BER(Mea., Est.)' ] );
            set(sim.figure_handle.text5_5, 'String', [ num2str(frameout.sfo_ppm) ' ppm'] );
            set(sim.figure_handle.text5_6, 'String', [ num2str(frameout.cfrout.cfo_est*params.RXSampleFreq/1e6) ' MHz'] );
%             pol_est= angle(frameout.dfe1out.filtercoef( :, params.dfe1.Npostcursor+1));
%             pol_est =  est_pol( simout, frameout, sim, params )  ;
%             set(sim.figure_handle.text14, 'String', [ num2str( floor(pol_est(1) * 180/pi)) ' °'] );
%             set(sim.figure_handle.text14, 'String', [ num2str( frameout.fsfs.pol_est * 180/pi) 'degree'] );
%             set(sim.figure_handle.text5_7, 'String',  'Line rate' );
%             set(sim.figure_handle.edit5_7, 'String', [ num2str( params.BaudFreq * params.Nbitspersymbol * params.NTXStream /1e9) ' Gbps'] );
        end
end
 
 

function [pol_est,pol_est0]  =  est_pol( simout, frameout, sim, params ) 
    pol_est = 0;pol_est0=0;
    if ( params.NTXStream == 1 )
        return;
    end
    coef0 = (frameout.dfeout.filtercoef( :, params.dfe1.Npostcursor+1));
    pol0_1 = atan2(real(coef0(3)),real(coef0(1))) ;
    pol0_2 = atan2(-real(coef0(2)),real(coef0(4)));
    pol_est0 = mean([pol0_1 pol0_2]) ;
    pol_est1= angle(frameout.dfe1out.filtercoef( :, params.dfe1.Npostcursor+1)) ;  
    frameout.fsfs.pol_est;
    pol_est = - pol_est0 +   frameout.fsfs.pol_est;
    if ( pol_est > 1 )
    pol_est = pol_est - 2;
    end
    pol_est = pol_est * pi/2 ;
end
