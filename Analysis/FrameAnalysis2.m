function [frameout, simout]=  FrameAnalysis2( txsignal, frame, params, sims)

%  Usage      : [frameout]=  FrameAnalysis2( txsignal, frame, params, sims)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    frameout     = frame;

    if (  isempty(sims.const_axes{1})  || ~ ishandle(sims.const_axes{1}) )
        [sims.const_axes{1}, sims.const_slider(1), ...
         sims.const_axes{2}, sims.const_slider(2), ...
         sims.psd_axes,      sims.ber_axes,  sims.tau_axes, ...
         sims.cpr_axes,      sims.sync_axes, sims.sync_axes1, ...
         sims.figure_handle] = SingleCarrier();
         sims.psdhandle.figure1 = sims.figure_handle;
         sims.evm_text          = sims.figure_handle.text2;
         sims.cpr_text          = sims.figure_handle.text23;
         sims.const_text(1)     = sims.figure_handle.text17;
         sims.const_text(2)     = sims.figure_handle.text19;
         sims.consthandle(1).figure1= sims.figure_handle;
         sims.consthandle(2).figure1= sims.figure_handle;
         sims.consthandle(1).popupmenu1= sims.figure_handle.popupmenu1;
         sims.consthandle(2).popupmenu1= sims.figure_handle.popupmenu2;
         sims.psdhandle.popupmenu1= sims.figure_handle.popupmenu3;
    end 
    if (  ( isempty(sims.dfe_axes{1})  || ~ ishandle(sims.dfe_axes{1})) ...
            && (  sims.show_dfe  || sims.show_dfe1 ))
        [sims.dfe_axes{1},  sims.dfe_axes1(1), ...
         sims.dfe_axes{2},  sims.dfe_axes1(2), ...
         sims.dfe_axes{3},  sims.dfe_axes1(3), ...
         sims.dfe_axes{4},  sims.dfe_axes1(4), ...
         sims.dfe1_axes{1}, sims.dfe1_axes1(1), ...
         sims.dfe1_axes{2}, sims.dfe1_axes1(2), ...
         sims.dfe1_axes{3}, sims.dfe1_axes1(3), ...
         sims.dfe1_axes{4}, sims.dfe1_axes1(4), ...
         sims.figure_handle1] = SingleCarrier1();
    end 

         
    [sims, frameout] = TPRAnalysis( sims, params, frameout);
    [sims, frameout] = CPRAnalysis( sims, params, frameout);
    [sims, frameout] = DFEAnalysis( sims, params, frameout);
    [sims, frameout] = DFE1Analysis( sims, params, frameout);
    [sims, frameout] = SyncAnalysis( sims, params, frameout);    
    [sims, frameout] = BERAnalysis( sims, params, frameout, txsignal);
    [sims] = ShowConstellation( sims, params, frameout);
    [sims ] = ShowPSD( sims, params, frameout);
    frameout.Nbitspersymbol = params.Nbitspersymbol ;     GHz =1e9;
    frameout.receivedclk   =  params.RXSampleFreq/GHz;
    set( sims.figure_handle.figure1, 'UserData', frameout);         
    simout = sims;
end
