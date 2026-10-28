%% Raised cosine filter to combat with intersymbol interference.

function [response] = RC(os_factor,roll_off, resp_sample, FWHM)
%  Usage      : [response] = RC(os_factor,roll_off, resp_sample)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
  
    a=roll_off;
    t=-resp_sample/2:1/os_factor:resp_sample/2;  
    t = [0:1/os_factor: resp_sample/2];
    t = [- t(end:-1:2) t];
    %This can be increased or decreased according to the requirement
    t  = t *  FWHM;
    p=zeros(1,length(t));
    for i=1:1:length(t)
        if t(i)==1/(4*a) || t(i)==-1/(4*a)
            p(i)= pi /4 * sinc (1/(2*a));
        else
            p(i)=  1 * sinc (t(i)) * cos  ( pi * a * t(i)) /( 1 - (2*a*t(i))^2);
        end
    end
    response=p./sqrt(sum(p.^2)); %Normalization to unit energy

% sim.srrc_coef = rcosdesign(roll_off, resp_sample, os_factor);
end

%function [out]=  sinc ( x  )
%
% out =  sin(pi*x)./(x*pi); 
% out(find(x == 0 )) =1;
%end
