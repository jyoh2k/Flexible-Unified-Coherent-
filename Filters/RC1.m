% raised cosine filter to combat with intersymbol interference.

function [time_response, freq_response] = RC(os_factor,roll_off, resp_sample)

%  Usage      : [time_response, freq_responseras] = RC(os_factor,roll_off, resp_sample)
%  Function   :
%     1.   os_factor : oversampling     
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


 %os_factor=oversampling factor
 
alpha=roll_off;
% t=-resp_sample:1/os_factor:resp_sample; %Limiting the response to -4T to 4T
%This can be increased or decreased according to the requirement
fs=1;% os_factor ; 
os_factor =  os_factor/fs;
sincNum = sin(pi*[-fs:1/os_factor:fs]); % numerator of the sinc function
sincDen = (pi*[-fs:1/os_factor:fs]); % denominator of the sinc function
sincDenZero = find(abs(sincDen) < 10^-10);
sincOp = sincNum./sincDen;
sincOp(sincDenZero) = 1; % sin(pix/(pix) =1 for x =0

cosNum = cos(alpha*pi*[-fs:1/os_factor:fs]);
cosDen = (1-(2*alpha*[-fs:1/os_factor:fs]).^2);
cosDenZero = find(abs(cosDen)<10^-10);
cosOp = cosNum./cosDen;
cosOp(cosDenZero) = pi/4;
freq_response = sincOp.*cosOp;
% figure; plot(freq_response);
freq_response = freq_response(1:end-1);
% time_response = fft(freq_response,resp_sample * fs); 
time_response = 0;
end