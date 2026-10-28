function [skew]     = EqualizerSkewEstimator( dfeout, params, mode )


%  Usage      :  [params]     = EqualizerSkewEstimator( dfeout, params )
%
%  Function   :
%     Calculate skews using equalization filter coefficients
% 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
%
% Reference paper :
%     Rios-Müller, Rafael, Jeremie Renaudier, and Gabriel Charlet.  "Blind receiver skew 
%     compensation and estimation for long-haul non-dispersion managed systems 
%     using adaptive equalizer." Journal of Lightwave Technology 33.7 (2015): 1315-1318. 

% h_XI_X : XI (RX) , X(TX)
  h_XI_X  = dfeout.filtercoef(1,1:end-1) +  dfeout.filtercoef(5,1:end-1) ;
  h_XQ_X  = dfeout.filtercoef(1,1:end-1) -  dfeout.filtercoef(5,1:end-1) ;
  h_XI_Y  = dfeout.filtercoef(2,1:end-1) +  dfeout.filtercoef(6,1:end-1) ;
  h_XQ_Y  = dfeout.filtercoef(2,1:end-1) -  dfeout.filtercoef(6,1:end-1) ;


  h_YI_X  = dfeout.filtercoef(3,1:end-1) +  dfeout.filtercoef(7,1:end-1) ;
  h_YQ_X  = dfeout.filtercoef(3,1:end-1) -  dfeout.filtercoef(7,1:end-1) ;
  h_YI_Y  = dfeout.filtercoef(4,1:end-1) +  dfeout.filtercoef(8,1:end-1) ;
  h_YQ_Y  = dfeout.filtercoef(4,1:end-1) -  dfeout.filtercoef(8,1:end-1) ;
  
  if ( mode == 1 )
      phase_X = fftshift(angle( fft(h_XI_X) ./ fft(h_XQ_X) + fft(h_XI_Y) ./ fft(h_XQ_Y)  ));
      phase_Y = fftshift(angle( fft(h_YI_X) ./ fft(h_YQ_X) + fft(h_YI_Y) ./ fft(h_YQ_Y)  ));  
      phase_XY_I = fftshift(angle( fft(h_XI_X) ./ fft(h_YI_X) + fft(h_XI_Y) ./ fft(h_YI_Y)  ));
      phase_XY_Q = fftshift(angle( fft(h_XQ_X) ./ fft(h_YQ_X) + fft(h_XQ_Y) ./ fft(h_YQ_Y)  ));
      phase_XI_YQ = fftshift(angle( fft(h_XI_X) ./ fft(h_YQ_X) + fft(h_XI_Y) ./ fft(h_YQ_Y)  ));
      
  end
  
  
  if ( mode == 2 ) 
      phase_X = fftshift(angle( fft(h_XI_X) ./ fft(h_XQ_X)   ));
      phase_Y = fftshift(angle( fft(h_YI_Y) ./ fft(h_YQ_Y)  ));     
      phase_XY_I = fftshift(angle( fft(h_XI_X) ./ fft(h_YI_Y) ));
      phase_XY_Q = fftshift(angle( fft(h_XQ_X) ./ fft(h_YQ_Y)  ));
      phase_XI_YQ = fftshift(angle( fft(h_XI_X) ./ fft(h_YQ_Y)  ));
  end
  
  
  if ( mode == 3 ) 
      phase_X = fftshift(angle( fft(h_XI_Y) ./ fft(h_XQ_Y)   ));
      phase_Y = fftshift(angle( fft(h_YI_X) ./ fft(h_YQ_X)  ));     
      phase_XY_I = fftshift(angle( fft(h_XI_Y) ./ fft(h_YI_X) ));
      phase_XY_Q = fftshift(angle( fft(h_XQ_Y) ./ fft(h_YQ_X)  ));
      phase_XI_YQ = fftshift(angle( fft(h_XI_Y) ./ fft(h_YQ_X)  ));
  end
  
  if ( mode == 5 )
      phase_X = fftshift(angle( fft(h_XI_X) ./ fft(h_XQ_X)   ));
      phase_Y = fftshift(angle( fft(h_YI_Y) ./ fft(h_YQ_Y)  ));
  end 
  
  half_range = floor(round((length(phase_X)-1)/2)/2) ;
  dc_idx = round((length(phase_X)-1)/2) +1;
  phase_idx = dc_idx + [-half_range:half_range];
  freq = params.RXSampleFreq / length(phase_X);
  freq_range = freq * [-half_range:half_range];
  freq_range1 = freq * [-dc_idx+1:(-dc_idx+length(phase_X))];
     
  figure; 
  s(1)=subplot(2,2,1);
  s(2)=subplot(2,2,2);
  s(3)=subplot(2,2,3);
  s(4)=subplot(2,2,4);
  Xskew_ps = plot_skew( s(1), freq_range, freq_range1,  phase_idx, phase_X,  'X I-Q skew'); 
  Yskew_ps = plot_skew(s(2),  freq_range, freq_range1,  phase_idx, phase_Y,  'Y I-Q skew'); 
  if ( mode == 5 )   
      XY_I_skew_ps = 0;
      XY_Q_skew_ps = 0;   
      XI_YQ_skew_ps = 0;    
  else     
      XY_I_skew_ps = plot_skew( s(3), freq_range, freq_range1,  phase_idx, phase_XY_I,  'X-I Y-I skew');
      XI_YQ_skew_ps = plot_skew( s(4), freq_range, freq_range1,  phase_idx, phase_XI_YQ,  'X-I Y-Q skew');
      XY_Q_skew_ps = plot_skew( 0 , freq_range, freq_range1,  phase_idx, phase_XY_Q,  'X-Q Y-Q skew');
  end
  
  skew = [Xskew_ps, XY_I_skew_ps, XI_YQ_skew_ps, Yskew_ps,  XY_Q_skew_ps];
end

function skew_ps  = plot_skew( s, freq_range,freq_range1, phase_idx, phase_X,  legend_str)
 
  PX = polyfit(freq_range, phase_X(phase_idx),1) ;
  
  ps = 1e-12;
  skew_ps = PX(1)/2/pi/ps;
  
    %   figure;  
    if ( s ~= 0 )
        plot(s, freq_range1, phase_X,'bs-' , 'Display' , legend_str); 
        hold (s, 'on'); 
        plot( s, freq_range, freq_range *PX(1) + PX(2),'rs--', 'Linewidth', 2 , 'Display' , ['fit ' num2str(skew_ps), ' ps']);

        legend (s,'show');
        grid (s,'on');
        plot(s, freq_range, phase_X(phase_idx),'bs-' , 'Linewidth', 2); 
    end 
end 
 