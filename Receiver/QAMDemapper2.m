function [demapper_out, I] = QAMDemapper2 ( demapper_in,  params)

%  Usage      : mapper = QAMDemapper2 ( mapperin,  params, T );
%
%  Function   :
%     1.   4QAM, 16QAM mapping (Gray coding)    
%     2.   mapperin : data to be mapped 
%     3.   params   : parameters 
%     4.   T        : Reserved for fixed sim.
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

d1 = size ( demapper_in, 1 );
d2 = size ( demapper_in, 2 );
num_bps = params.Nbitspersymbol ;
 
[mapper_list0, mapper_list] = QAMMapper2List (  params );
mapper_list = reshape( mapper_list, 1, length(mapper_list));

demapper_out= zeros(d1*params.QAM_factor, d2*num_bps/params.QAM_factor);
demapper_tmp= zeros(d1*params.QAM_factor, d2*num_bps/params.QAM_factor);


demapperm = demapper_in;
if ( params.QAM_factor ==2 )
    for istream=1:d1
        demapperm(istream*2 -  1, :) = real(demapper_in(istream,:));
        demapperm(istream*2  , :) = imag(demapper_in(istream,:));
    end
end
if ( num_bps == 2.5 ) %  PAM6
    demapper_in = demapper_in(:, 1:floor(d2/2)*2);
    demapperm = demapper_in(1:2:end) + 1j*demapper_in(2:2:end);  
end

for istream=1:d1*params.QAM_factor 
    demapper1 = demapperm(istream,:);

    if ( num_bps == 2.5 * params.QAM_factor ) 
       distance = ( ones(length(mapper_list),1) *  conj(demapper1) ...
                    - mapper_list' * ones(1, d2/2 )).^2;
       [C, I]= min(distance, [],1);
    else
       distance = ( ones(length(mapper_list),1) * real(demapper1) ...
                    - mapper_list' * ones(1, d2 )).^2;
       [C, I]= min(distance, [],1);

    end 

   if ( num_bps == 1 * params.QAM_factor ) 
        demapper_out(istream,:) = I == 2;
   end 
   if ( num_bps == 2 * params.QAM_factor ) 
       if (params.GrayMap == 1)
           % For Gray code
           demapper_tmp(istream, 2:2:end ) = I > 2;
           demapper_tmp(istream, 1:2:end ) = I == 2 | I == 3 ;
       else
           % For probability shaping
           demapper_tmp(istream, 2:2:end ) = I > 2;
           demapper_tmp(istream, 1:2:end ) = I == 1 | I == 4;
       end
       if ( params.big_end_map == 1)
           demapper_out(istream, 1:2:end ) = demapper_tmp(istream, 2:2:end ) ;
           demapper_out(istream, 2:2:end ) = demapper_tmp(istream, 1:2:end ) ;
       else 
           demapper_out(istream, :)= demapper_tmp(istream, :);
       end 
   end 

   if ( num_bps == 2.5 * params.QAM_factor ) 
       demapper_list = [ ...
          0 0 0 0 0; 0 0 0 0 1; 1 0 0 0 1; 1 0 0 0 0; ...
          0 0 1 0 0; 0 1 1 0 0; 0 1 0 0 0; 1 1 0 0 0; 1 1 1 0 0; 1 0 1 0 0; ...
          0 0 1 0 1; 0 1 1 0 1; 0 1 0 0 1; 1 1 0 0 1; 1 1 1 0 1; 1 0 1 0 1; ...
          0 0 1 1 1; 0 1 1 1 1; 0 1 0 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 0 1 1 1; ...
          0 0 1 1 0; 0 1 1 1 0; 0 1 0 1 0; 1 1 0 1 0; 1 1 1 1 0; 1 0 1 1 0; ...
          0 0 0 1 0; 0 0 0 1 1; 1 0 0 1 1; 1 0 0 1 0; ...
       ];
       demapper_out( 1:5:end ) = demapper_list(I, 1);
       demapper_out( 2:5:end ) = demapper_list(I, 2);
       demapper_out( 3:5:end ) = demapper_list(I, 3);
       demapper_out( 4:5:end ) = demapper_list(I, 4);
       demapper_out( 5:5:end ) = demapper_list(I, 5);
       
    mapper_list = [ ...
        (-3+1j*5) (-1+1j*5) (1+1j*5) (3+1j*5) ...
        (-5+1j*3) (-3+1j*3) (-1+1j*3) (1+1j*3) (3+1j*3) (5+1j*3)...
        (-5+1j*1) (-3+1j*1) (-1+1j*1) (1+1j*1) (3+1j*1) (5+1j*1)...
        (-5+1j*-1) (-3+1j*-1) (-1+1j*-1) (1+1j*-1) (3+1j*-1) (5+1j*-1)...
        (-5+1j*-3) (-3+1j*-3) (-1+1j*-3) (1+1j*-3) (3+1j*-3) (5+1j*-3)...
        (-3+1j*-5) (-1+1j*-5) (1+1j*-5) (3+1j*-5) ...
       ];
      I1 =   zeros(1, length(I)*2);
      I = mapper_list(I);
      I1(1:2:end) = real(I); 
      I1(2:2:end) = imag(I); 
      I = (I1 + 5) /2;
   end 

   if ( num_bps == 3 * params.QAM_factor ) 
       if (params.GrayMap == 1)
           % For Gray code
           demapper_tmp(istream, 1:3:end ) = I == 2 | I == 3 | I == 6 | I == 7;
           demapper_tmp(istream, 2:3:end ) = I == 3 | I == 4 | I == 5 | I == 6;
           demapper_tmp(istream, 3:3:end ) = I > 4;
       else
           % For probability shaping
           demapper_tmp(istream, 1:3:end ) = I == 1 | I == 3 | I == 6 | I == 8;
           demapper_tmp(istream, 2:3:end ) = I == 1 | I == 2 | I == 7 | I == 8;
           demapper_tmp(istream, 3:3:end ) = I > 4;
       end
       if ( params.big_end_map == 1)
           demapper_out(istream, 1:3:end ) = demapper_tmp(istream, 3:3:end ) ;
           demapper_out(istream, 2:3:end ) = demapper_tmp(istream, 2:3:end ) ;
           demapper_out(istream, 3:3:end ) = demapper_tmp(istream, 1:3:end ) ;
       else 
           demapper_out(istream, :)= demapper_tmp(istream, :);
       end 
   end 
 

   if ( num_bps == 4 * params.QAM_factor )
       if (params.GrayMap == 1)
           % For Gray code
           demapper_tmp(istream, 1:4:end ) = I == 2 | I == 3 | I == 6 | I == 7 | ...
                                             I ==10 | I ==11 | I ==14 | I ==15;
           demapper_tmp(istream, 2:4:end ) = I == 3 | I == 4 | I == 5 | I == 6 | ...
                                             I ==11 | I ==12 | I ==13 | I ==14;
           demapper_tmp(istream, 3:4:end ) = I == 5 | I == 6 | I == 7 | I == 8 | ...
                                             I == 9 | I == 10 | I ==11 | I == 12;
           demapper_tmp(istream, 4:4:end ) = I > 8;
       else
           % For probability shaping
           demapper_tmp(istream, 1:4:end ) = I == 1 | I == 3 | I == 5 | I == 7 | ...
                                             I ==10 | I ==12 | I ==14 | I ==16;
           demapper_tmp(istream, 2:4:end ) = I == 1 | I == 2 | I == 5 | I == 6 | ...
                                             I ==11 | I ==12 | I ==15 | I ==16;
           demapper_tmp(istream, 3:4:end ) = I == 1 | I == 2 | I == 3 | I == 4 | ...
                                             I ==13 | I ==14 | I ==15 | I == 16;
           demapper_tmp(istream, 4:4:end ) = I > 8;
       end
       if ( params.big_end_map == 1)
           demapper_out(istream, 1:4:end ) = demapper_tmp(istream, 4:4:end ) ;
           demapper_out(istream, 2:4:end ) = demapper_tmp(istream, 3:4:end ) ;
           demapper_out(istream, 3:4:end ) = demapper_tmp(istream, 2:4:end ) ;
           demapper_out(istream, 4:4:end ) = demapper_tmp(istream, 1:4:end ) ;
       else 
           demapper_out(istream, :)= demapper_tmp(istream, :);
       end 
   end

end
