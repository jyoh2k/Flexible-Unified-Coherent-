function   [equalized, decided, ffeout, ffeout1 ] = feedback_filter...
                             ( ffesum, DIN1, prev_decided, dk, fk, f3k, is_training_seq, params) 
    PRL         = params.PRL;
    OV          = params.OV;  
    block_size  = params.block_size;    
    NStream     = params.NStream;
    training_seq         = [prev_decided(:,end) DIN1 ];

    ak =complex( [prev_decided(:, end:-1:end-size(dk,2)+1) ]);
    ffeout      = complex( zeros(params.NStream, PRL * OV) );
    ffeout = ffesum;
    ffeout1= ffesum;
    fbe  = complex(zeros(params.NStream, PRL));
    vfbe = complex(zeros(params.NStream, PRL));
    v3fbe = complex(zeros(params.NStream, PRL));
    is_block_start =  zeros(1, PRL);
    if ( params.en_block_termination == 1 )      
        is_block_start = double( mod([1:PRL], block_size) == 1);
    end
    if ( params.en_block_termination == 2 )
        is_block_start = double( mod([1:PRL], block_size) == 0);
    end
    equalized = complex(zeros(params.NStream, PRL));
    decided = complex(zeros(params.NStream, PRL));
    for idx=1:PRL 
        for os=1:params.NStream 
            if ( is_block_start(idx) == 1 )
                ak(:,1) = training_seq(os,idx);
            end
            ak2=ak;
            if (params.skewcomp_en == 2 )
               ak2 = [ak; conj(ak)];
            end
            fbe(os, idx)   = sum(sum(ak2 .* dk(os:NStream:end,:)));
            fbe(os, idx)   =  fie_c ( fbe(os, idx), params.T.FBE); 
            
%             vfbe(os, idx)  = sum(sum(ak2(:, 1:params.Npbe) .^ 2 .* fk(os:NStream:end,:))); % Volterra 2nd order
%             vfbe(os, idx) = fie_c ( vfbe(os, idx), params.T.VFBE);
%             v3fbe(os, idx) = sum(sum(ak2(:, 1:params.Np3be) .^3 .* f3k(os:NStream:end,:))); % Volterra  3rd order
%             v3fbe(os, idx) = fie_c ( v3fbe(os, idx), params.T.V3FBE);

            equalized(os,idx) =  ffesum(os, (idx-1)*OV+1) +  ...
                                fbe(os,idx)+ vfbe(os,idx)+ v3fbe(os,idx);

            equalized = fie_c(equalized, params.T.EQOut);
            fbe_mlse = sum(sum(ak2(:,1:params.Nfilter) .* dk(os:NStream:end,1:params.Nfilter)));
            fbe_mlse = fie_c(fbe_mlse, params.T.FBE);
            ffeout(os, (idx-1)*OV+1) = equalized(os,idx) - fbe_mlse; %sum(sum(ak2(:,1:params.Nfilter) .* dk(os:NStream:end,1:params.Nfilter))); 
            ffeout = fie_c(ffeout, params.T.FFE);
            decided(os,idx) = slicer( equalized(os,idx), training_seq(os,idx+1),is_training_seq,idx,params);
        end
        
        
        ak(:,1:params.Nfbe) =[ decided(:,idx) ak(:,1: params.Nfbe -1)];
    end
    
    
    if ( params.fixed_bit == 2 )
    end

end
