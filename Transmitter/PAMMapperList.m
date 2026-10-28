function [mapper_list, upper_right_data] = PAMMapperList (params, T) 

%  Usage      :  [mapper_list, upper_right_data] = PAMMapperList (params, T) 
%  Function   :
%     1.   PAM mapping 
%     2.   params   : parameters 
%     3.   T        : Reserved for fixed sim.
%     
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    num_bps = params.Nbitspersymbol ;
    
    if ( num_bps == 2 ) 
        mapper_list = [-3; -1; 1;  3;] ;
    end
    if ( num_bps == 2.5) 
        mapper_list = [1:6] *2 - 5  ;
        mapper_list = mapper_list'; 
    end
    if ( num_bps == 3 ) 
        mapper_list = [1:8] *2 - 9  ;
        mapper_list = mapper_list'; 
    end
    if ( num_bps == 4 ) 
        mapper_list = [1:16] *2 - 17  ;
        mapper_list = mapper_list'; 
    end

    upper_right_data = mapper_list(end);
end
