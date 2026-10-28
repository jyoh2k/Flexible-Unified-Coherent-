function out = RmTrainingSymbol ( in,  params, T )

%  Usage      : out = RmTrainingSymbol ( in,  params, T );
%
%  Function   :
%        
%  Port
%     1.  in : data to be mapped 
%     2   params   : parameters 
%     3   T        : Reserved for fixed sim.
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    
    if ( params.CFEtype  == 2 )
        dataidx =  length(params.sync_pattern ) * params.OV * 2  +1;
        out                 = in(dataidx:end);
    else 
        out = in;
    end
  
end
