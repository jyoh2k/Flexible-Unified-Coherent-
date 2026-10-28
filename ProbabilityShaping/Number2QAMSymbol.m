% Not gray code, but is it required? I am not sure.
function out = Number2QAMSymbol(in, params)
   num_bps = params.Nbitspersymbol ;
    if ( num_bps == 2 )  
       mapper2 = in * 2 - (1) ;
       Normalization_factor = 1/sqrt(2);
    end
    
    if ( num_bps == 4 ) % 16 QAM  
        % Gray Mapping 
        mapper2 = (in == 0)* -3 + (in == 1)* -1 + (in == 3)* 1 + (in == 2)* 3;
        Normalization_factor = 1/sqrt(10);         
    end

    
         
     %% 64 QAM
    if ( num_bps == 6 ) 
        mapper2 = (in == 0)* -7 + (in == 4)* -5 ...
                       + (in == 6)* -3 + (in == 2)* -1 ...
                       + (in == 3)*  1 + (in == 7)*  3 ...
                       + (in == 5)*  5 + (in == 1)*  7;
        Normalization_factor = 1/sqrt(42);   
    end
     
    NStream=size(in,1)/2;
    out = zeros( NStream, size(in,2));
    for istream = 1:NStream
        out(istream,:) = complex( mapper2((istream-1)*2+1,:),mapper2((istream-1)*2+2,:));
    end
    
    out = Normalization_factor * out;
end