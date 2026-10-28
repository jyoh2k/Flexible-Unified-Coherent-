%% Square root raised cosine filter to combat with intersymbol interference.

function [response] = SRRC(os_factor,roll_off, resp_sample, resp_type)
%  Usage      : [response] = SRRC(os_factor,roll_off, resp_sample)
%               [response] = SRRC(os_factor,roll_off, resp_sample, 'time')
%               [response] = SRRC(os_factor,roll_off, resp_sample, 'freq')
%  Function   :
%     1. 'time' (default) : time response (filter taps), unit energy.
%     2. 'freq'           : zero-phase frequency response H(k), FFT bin order
%                           (DC first, k = 0..N-1, f = k/N*os_factor [1/T]).
%                           N is even (time tap count, rounded up to even).
%                           Normalized so that sum(abs(H).^2) = N (unit energy).
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com
%  Known bugs :

if nargin < 4 || isempty(resp_type)
    resp_type = 'time';
end

a=roll_off;

switch lower(resp_type)
    case 'time'
    case 'freq'
        N = length(-resp_sample/2:1/os_factor:resp_sample/2);
        N = N + mod(N,2);                       % even length for FFT
        k = [0:N/2-1, -N/2:-1];                 % FFT bin order
        f = abs(k/N*os_factor);                 % |f| normalized to symbol rate (T=1)
        f1 = (1-a)/2;
        f2 = (1+a)/2;
        H = zeros(1,N);
        H(f <= f1) = 1;
        idx = (f > f1) & (f <= f2);
        if a > 0
            H(idx) = sqrt(0.5*(1+cos(pi/a*(f(idx)-f1))));
        end
        response = H*sqrt(N/sum(H.^2));         % Normalization to unit energy (Parseval)
%         response = fftshift( response );
        return;
    otherwise
        error('SRRC: resp_type must be ''time'' or ''freq''.');
end

t=-resp_sample/2:1/os_factor:resp_sample/2; %Limiting the response to -4T to 4T
%This can be increased or decreased according to the requirement
 
p=zeros(1,length(t));
    for i=1:1:length(t)
        if t(i)==0
            p(i)= (1-a)+4*a/pi;
        else if t(i)==1/(4*a) || t(i)==-1/(4*a)
               p(i)=a/sqrt(2)*((1+2/pi)*sin(pi/(4*a))+(1-2/pi)*cos(pi/(4*a)));
              else
                p(i) = (sin(pi*t(i)*(1-a))+4*a*t(i).*cos(pi*t(i)*(1+a)))./(pi*t(i).*(1-(4*a*t(i)).^2));
             end
        end
    end
    response=p./sqrt(sum(p.^2)); %Normalization to unit energy

% sim.srrc_coef = rcosdesign(roll_off, resp_sample, os_factor);
end
