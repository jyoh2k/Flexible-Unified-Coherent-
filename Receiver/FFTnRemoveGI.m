function [ out ]=  FFTnRemoveGI( in, params )

%  Usage      :  [ out ]=  FFTnRemoveGI( in, params )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    NSample = params.NSymbol * params.NSamplepersymbol;

    Nout =   params.NSymbol  * params.NFFT;
    out = zeros(size(in,1), Nout); 
    
    for ich=1:size(in,1)
       in1 = reshape( in(ich, 1:NSample),  params.NSamplepersymbol, params.NSymbol );  
       fftin  = in1(params.index, :);
       fftout = fft(fftin, [],1); 
       out(ich, :)  = reshape(fftout, 1, Nout);
    end 

end 
