 function [channelout] = DSO_Read( sims, params )  
%  Usage      :  [scope_out] = DSO_Read( sims, params )  
 

    SR =256;
    SC =25;
    wfileind =1;

   [mode1_X,mode1_Y] = CgetWaveform_UXR0404A(wfileind,SR,SC); 
   pause(0.5);
   
   % mode1_X = real(mode1_X)- mean(real(mode1_X)) +  1j * (imag(mode1_X) - mean(imag(mode1_X))) ;   
   mode1_X = real(mode1_X) / rms(real(mode1_X)) + 1j* (imag(mode1_X) / rms(imag(mode1_X))) ;

   % mode1_Y = real(mode1_Y)- mean(real(mode1_Y)) +  1j * (imag(mode1_Y) - mean(imag(mode1_Y)) ) ;
   mode1_Y = real(mode1_Y) / rms(real(mode1_Y)) + 1j* (imag(mode1_Y) / rms(imag(mode1_Y))) ;

   % mode1_X = conj(mode1_X);
   mode1_Y = conj(mode1_Y);

    if ( params.NRXStream == 2)
        channelout = [  mode1_X';  mode1_Y';];
    else
        channelout = [  mode1_X' ;  mode1_Y'; ];
    end
    
      % save('C:\Users\USER\Documents\Work\TOI\Experiment\20-Jun-2023\PTBC_AWG_16QAM_256GS_30GBaud_20km_0ps_-25dBm_err_20.mat','channelout');        

%     load('C:\Users\USER\Documents\Work\TOI\Experiment\20-Jun-2023\PTBC_AWG_16QAM_256GS_30GBaud_20km_0ps_-25dBm_err_1.mat');

    PAPR =SC*4/sqrt(mean(mean(abs(channelout) .^2 )))/1000;
    AVG  =sqrt(mean(mean(abs(channelout) .^2 )))*1000;
    disp2(sims.logfile, ['OSC PAPR ' num2str( PAPR) ' Avg ' num2str( AVG) ]);

%% import from files
% load('C:\Users\USER\Documents\Work\TOI\Experiment\16-Feb-2023\DP_AWG_32QAM_160GS_30GBaud_0km_0ps_-12dBm_1.mat');
% load('C:\Users\USER\Documents\Work\TOI\Experiment\17-Jul-2023\PTBC_AWG_16QAM_256GS_30GBaud_20km_0ps_-15dBm_1.mat');
% channelout = [mode1_X, mode1_Y]';
% channelout = conj(channelout) ;
%% 
    


    [channelout] =  rxmapping ( channelout,params.RXmapping);
    SaveOsc(channelout, sims, params); 
%     save('temp1.mat','channelout'); 

    figure(2);
    xxx = [(-1/2):1/(length(channelout(1,:))-1):1/2]*SR;
    plot(xxx,log10(fftshift(abs(fft((channelout(1,:)))))));
    grid on;
    pause(1);

end 
