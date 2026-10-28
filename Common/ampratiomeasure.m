% +------------------------------------------------------+
% |             Amplitude Ratio Measurement              |
% |              with MATLAB Implementation              | 
% |                                                      |
% | Author: M.Sc. Eng. Hristo Zhivomirov        11/15/14 | 
% +------------------------------------------------------+
% 
% function: AmpRat = ampratiomeasure(x, y)
%
% Input:
% x - first signal in the time domain
% y - second signal in the time domain
% 
% Output:
% Amp - amplitude ratio of the two signals Y/X
%
% Note: Be aware! This funtion gives exact results only when 
% the two signals of consideration have one and the same shape 
% (e.g., both are sine-waves)!

function AmpRat = ampratiomeasure(x, y)

% represent the signals as column-vectors
x = x(:);
y = y(:);

% remove the DC component of the signals
x = x - mean(x);
y = y - mean(y);

% signals length calculation
xlen = length(x);
ylen = length(y);

% windows generation
xwin = flattopwin(xlen, 'periodic');
ywin = flattopwin(ylen, 'periodic');

% calculation of the coherent amplification of the windows
Cx = sum(xwin)/xlen;
Cy = sum(ywin)/ylen;

% perform fft on the signals
px = nextpow2(10*xlen);
py = nextpow2(10*ylen);
nfftx = 2^px;
nffty = 2^py;
X = fft(x.*xwin, nfftx);
Y = fft(y.*ywin, nffty);

% fundamental frequency detection
[~, indx] = max(abs(X));
[~, indy] = max(abs(Y));

% amplitude ratio estimation
Xamp = abs(X(indx))/xlen/Cx;
Yamp = abs(Y(indy))/ylen/Cy;
AmpRat = Yamp/Xamp;

end