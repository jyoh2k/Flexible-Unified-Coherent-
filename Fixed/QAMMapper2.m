function [mapper] = QAMMapper2 ( mapperin,  params )

    %  Usage      : mapper = QAMMapper2 ( mapperin,  params );
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

    d2 = size ( mapperin, 2 );
    num_bps = params.Nbitspersymbol ;
    if ( mod( d2, num_bps  ) ~= 0 )
        error(' The number of bit stream should be the integer multiples of params.Nbitspersymbol ');
    end

    if( params.big_end_map == 0)
          mapper_mux = [1:num_bps/params.QAM_factor]-1;
    else
         mapper_mux = [num_bps/params.QAM_factor :-1:1]-1;
    end
    mapper_mux = 2 .^ mapper_mux;


    if ( num_bps == 1 * params.QAM_factor ) 
        mapperI = mapperin  * 2 -1; 
        gray_mapper = mapperI;
        non_gray_mapper = mapperI;
    end

    if ( num_bps == 2 * params.QAM_factor ) % 16 QAM, 4PAM
        mapperI = mapperin( :, 2:2:end) * mapper_mux(2) + mapperin( :, 1:2:end) *mapper_mux(1); 
        gray_mapper =(mapperI == 0)* -3 + (mapperI == 1)* -1 ...
                            + (mapperI == 2) * 3 + (mapperI == 3)* 1 ;   
        non_gray_mapper =(mapperI == 0)* -1 + (mapperI == 1)* -3 ...
                                      + (mapperI == 2) * 1 + (mapperI == 3)* 3;
    end

    if ( num_bps == 2.5 * params.QAM_factor )  % 32 QAM, PAM-6

        mapper1 = mapperin(1:5:end)    + mapperin(2:5:end) *2 + ...
                  mapperin(3:5:end)* 4 + mapperin(4:5:end) *8 + ...
                  mapperin(5:5:end)* 16;
        mapper1 = mapper1 +1;
        demapper_list = [ ...
              0 0 0 0 0; 0 0 0 0 1; 1 0 0 0 1; 1 0 0 0 0; ...
              0 0 1 0 0; 0 1 1 0 0; 0 1 0 0 0; 1 1 0 0 0; 1 1 1 0 0; 1 0 1 0 0; ...
              0 0 1 0 1; 0 1 1 0 1; 0 1 0 0 1; 1 1 0 0 1; 1 1 1 0 1; 1 0 1 0 1; ...
              0 0 1 1 1; 0 1 1 1 1; 0 1 0 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 0 1 1 1; ...
              0 0 1 1 0; 0 1 1 1 0; 0 1 0 1 0; 1 1 0 1 0; 1 1 1 1 0; 1 0 1 1 0; ...
              0 0 0 1 0; 0 0 0 1 1; 1 0 0 1 1; 1 0 0 1 0; ...
        ];
        mapper_list = [ ...
            (-3+1j*5) (-1+1j*5) (1+1j*5) (3+1j*5) ...
            (-5+1j*3) (-3+1j*3) (-1+1j*3) (1+1j*3) (3+1j*3) (5+1j*3)...
            (-5+1j*1) (-3+1j*1) (-1+1j*1) (1+1j*1) (3+1j*1) (5+1j*1)...
            (-5+1j*-1) (-3+1j*-1) (-1+1j*-1) (1+1j*-1) (3+1j*-1) (5+1j*-1)...
            (-5+1j*-3) (-3+1j*-3) (-1+1j*-3) (1+1j*-3) (3+1j*-3) (5+1j*-3)...
            (-3+1j*-5) (-1+1j*-5) (1+1j*-5) (3+1j*-5) ...
           ];

        demapper_list = [ 1 + demapper_list(:,1) + demapper_list(:,2) *2  + demapper_list(:,3) * 4 + demapper_list(:,4) *8 + demapper_list(:,5) *16 ];
        [out,idx1] = sort( demapper_list) ;
        mapper2     = mapper_list(idx1(mapper1));
        Normf = mean(abs(mapper_list) .^2) ;
        if ( params.QAM_factor ==  2 )
            mapper2     = 1/sqrt(Normf)* mapper2;
        else 
            mapper1 = zeros(size(mapper2,1), size(mapper2,2)*2);
            mapper1(1:2:end) = real(mapper2);
            mapper1(2:2:end) = imag(mapper2);
            mapper2 = mapper1;
        end  
        gray_mapper = mapper2;
        non_gray_mapper = mapper2;
    end 

    if ( num_bps == 3 * params.QAM_factor )  % 64 QAM, PAM-8
        mapperI = mapperin( :, 3:3:end) * mapper_mux(3) + mapperin( :, 2:3:end) * mapper_mux(2) + ...
                         mapperin( :, 1:3:end) * mapper_mux(1);  
        gray_mapper = (mapperI == 0)* -7 + (mapperI == 1)* -5 ...
                             + (mapperI == 3)* -3 + (mapperI == 2)* -1 ...
                             + (mapperI == 6)*  1 + (mapperI == 7)*  3 ...
                             + (mapperI == 5)*  5 + (mapperI == 4)*  7; 

        non_gray_mapper = (mapperI == 0)* -1 + (mapperI == 1)* -3 ...
                             + (mapperI == 2)* -5 + (mapperI == 3)* -7 ...
                             + (mapperI == 4)*  1 + (mapperI == 5)*  3 ...
                             + (mapperI == 6)*  5 + (mapperI == 7)*  7; 
    end

    if ( num_bps == 4 * params.QAM_factor ) 
        mapper1 =  mapperin( :, 4:4:end) * mapper_mux(4) + mapperin( :, 3:4:end) * mapper_mux(3) + ...
                          mapperin( :, 2:4:end) * mapper_mux(2) + mapperin( :, 1:4:end) * mapper_mux(1);  
        gray_mapper  = (mapper1  ==  0)* -15 + (mapper1  ==  1)* -13 ...
                     + (mapper1  ==  3)* -11 + (mapper1  ==  2)*  -9 ...
                     + (mapper1  ==  6)* -7  + (mapper1  ==  7)*  -5 ...
                     + (mapper1  ==  5)* -3  + (mapper1  ==  4)*  -1 ...
                     + (mapper1  == 12)*  1  + (mapper1  == 13)*   3 ...
                     + (mapper1  == 15)*  5  + (mapper1  == 14)*   7 ...
                     + (mapper1  == 10)*  9  + (mapper1  == 11)*  11 ...
                     + (mapper1  ==  9)*  13 + (mapper1  ==  8)*  15;
        non_gray_mapper  = (mapper1  ==  7)* -15 + (mapper1  ==  6)* -13 ...
                     + (mapper1  ==  5)* -11 + (mapper1  ==  4)*  -9 ...
                     + (mapper1  ==  3)* -7  + (mapper1  ==  2)*  -5 ...
                     + (mapper1  ==  1)* -3  + (mapper1  ==  0)*  -1 ...
                     + (mapper1  ==  8)*  1  + (mapper1  ==  9)*   3 ...
                     + (mapper1  == 10)*  5  + (mapper1  == 11)*   7 ...
                     + (mapper1  == 12)*  9  + (mapper1  == 13)*  11 ...
                     + (mapper1  == 14)*  13 + (mapper1  == 15)*  15;

    end
    %%
    if ( params.GrayMap == 1)
        mapper2 = gray_mapper;
    else
        % For probability shaping
        mapper2 =  non_gray_mapper;
    end

    mapper = zeros( size(mapperin,1)/params.QAM_factor, params.QAM_factor*size(mapperin,2)/num_bps);
    if ( params.QAM_factor == 2)
        %  Normalization factor 
        if ( num_bps == 2) 
            mapper2  = 1/sqrt(2) * mapper2 ;
        end
        if ( num_bps == 4) 
            mapper2  = 1/sqrt(10) * mapper2  ; 
        end
        if ( num_bps == 6) 
            mapper2  = 1/sqrt(42) * mapper2 ;  
        end

        for istream=1:size(mapperin,1)/2
            mapper(istream,:) = complex( mapper2((istream-1)*2+1,:), mapper2((istream-1)*2+2,:));
        end
    else
        mapper = mapper2;
    end

    mapper = fie_c( mapper,  params.T.mapper);

    if ( params.fixed_bit == 2 ) 
    end 
end 
