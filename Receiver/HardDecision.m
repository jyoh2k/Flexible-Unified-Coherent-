function [dec, I, I2]  =  HardDecision( in, params) 

%  Usage      :  [dec, I, I2]  =  HardDecision( in, params) 
%  Function   :
%     1.  Hard deicsion        
%         
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    %[mapper_list0, mapper_list] = QAMMapper2List (  params );
%     [~, ~, ~,mapper_list, ~] = QAMMapper2List (  params.demap );
%     mapper_list =[-31:2:31] ; % THP, TCM
    mapper_list = params.hd_mapper_list ;
    mapper_list =reshape(mapper_list, length(mapper_list),1); 
    
    distance = abs((ones(length(mapper_list),1) * in - ...
                        mapper_list * ones(1, length(in)))).^2;
    [C, I] = min( distance  );
    dec =  mapper_list(I);
    if ( params.Nbitspersymbol == 2.5)
        I = I + (min(mapper_list)-1)/2 - 1    + (3 + 1);
        I2= max(min(5, I), 1);
    else
        I = I  + (min(mapper_list)-1)/2 - 1 + (2^(params.Nbitspersymbol-1) + 1);
        I2= max(min(2^(params.Nbitspersymbol), I), 1);
    end 

end
