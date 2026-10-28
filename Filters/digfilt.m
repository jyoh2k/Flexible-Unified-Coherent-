function [out] = digfilt( en, in, ovsample, coef )

%  Usage      : [out] = digfilt( en, in, ovsample, coef )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


if ( en  == 0 )
    out = in ;
    return;
else
%     ovsample = 8 ;
    for ii=1:size(in,1)
        if ( ovsample == 1 )
            firout = conv(in(ii, :),   coef) ;
        else
            firout = downsample(conv(upsample(in(ii, :),ovsample),   coef),ovsample,1);
        end
        out(ii,:) = firout((size( coef, 2)-1)/2/ovsample+(1:size(in,2)));
    end 
    out =mean( mean(abs(in)))/mean(mean(abs(out))) * out;
end
        
