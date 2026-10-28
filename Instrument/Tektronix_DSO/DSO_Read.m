 function [channelout, params] = DSO_Read( sims, params )  
%  Usage      :  [scope_out] = DSO_Read( sims, params )  
 
    %% Setup DSO
    instrreset; 
 
    %% 
    SR = 100;  
    SC = params.OSCScale;  

    %% 
    wfileind= 1; 
    
    %% Receive Rx signal 
    
    [mode1_X,mode1_Y] = CgetWaveform_DPO72004(wfileind,SR,SC); 
    pause(1);
     
    if ( params.NRXStream == 2)
        channelout = [  mode1_X';  mode1_Y';];
    else
        channelout = [  mode1_X' ;  mode1_Y'; ];
    end
    
    [channelout] =  rxmapping ( channelout,params.RXmapping);

    SaveOsc(channelout, sims, params); 

end 
