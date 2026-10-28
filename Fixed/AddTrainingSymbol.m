function out = AddTrainingSymbol ( in,  params, T )

%  Usage      : out = AddTrainingSymbol ( in,  params, T );
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

    out = in;
    if ( params.cfr.CFEtype  == 2 || params.cfr.CFEtype  == 5 )
         sync_ptn    = params.sync_pattern;  
         out = [sync_ptn sync_ptn in];
    end
    out = fie_c( out,  params.mapper.T.mapper); 
end
