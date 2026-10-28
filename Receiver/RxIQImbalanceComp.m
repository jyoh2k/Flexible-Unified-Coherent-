function [out, gsop]     = RxIQImbalanceComp( in, params )

%  Usage      : out = RxIQImbalanceComp( in, params )
%  Function   : 
%  GSOP(Gram-Schmidt orthogonalization procedure)  
%    PI = E{rI * rI)
%    PQ = E{rQ * rQ)
%    I(t) = rI(t) /sqrt(PI)
%    Qt(t) = rQ(t) - rho *rI(t)/PI 
%    Q(t) = Qt(t) /sqrt(PQ)
%    rho = E{rI(t) * rQ(t) }
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

gsop =0;
if ( params.en == 0 )
    out = in;
    return;
end

if ( params.en == 1 )  %GSOP 
    
%     warning(message('GSOP can be applied to QPSK. '))
    in1 = in; 
    outreal = real(in);
    outimag = imag(in);
    out = in;

    PI  = mean(real(in(:,1:1:end)) .* real(in(:,1:1:end)), 2);
    PQ  = mean(imag(in(:,1:1:end)) .* imag(in(:,1:1:end)), 2);
    rho = mean(real(in(:,1:1:end)) .* imag(in(:,1:1:end)), 2);
    pwr = mean(in .* conj(in),2);
    for istream=1:size(in,1)
        outreal(istream,:) = real(in(istream,:)) ./sqrt(PI(istream));
        outimag(istream,:) = imag(in(istream,:)) - (rho(istream) * real(in(istream,:)) ./(PI(istream)));
        outimag(istream,:) = outimag(istream,:) /sqrt(PQ(istream));
        out(istream,:)  = complex(outreal(istream,:) , outimag(istream,:) );
%         out(istream,:)  = out(istream,:)  / sqrt(2);
    end 
end
 
end 
