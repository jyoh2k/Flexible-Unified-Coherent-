function [AOUT, cfrout] = RxMultiCFR( AIN, params, T )  


    [cfo_recovered, cfrout1]      = RxCFR( AIN, params, T );
    cfrout = cfrout1 ;
    cfrout.cfo_est_step = [cfrout1.cfo_est];
    if ( params.CFEtype == 5)
        max_try = 10;
    else
        max_try = 0;
    end
    try_cnt = 1;
    while ( try_cnt < max_try & abs(cfrout1.cfo_est) > 7e-6 )
        [cfo_recovered, cfrout1]      = RxCFR( cfo_recovered, params, T );
        cfrout.cfe = cfrout.cfe + cfrout1.cfe;
        cfrout.cfo_est = cfrout.cfo_est + cfrout1.cfo_est ;
        cfrout.cfo_est_step = [cfrout.cfo_est_step cfrout1.cfo_est];
        try_cnt = try_cnt + 1;
    end
    AOUT = cfo_recovered;
    
%     [cfo_recovered, cfrout3]      = RxCFR( cfo_recovered, params, T );
%     [cfo_recovered, cfrout3]      = RxCFR( cfo_recovered, params, T );
%     [cfo_recovered, cfrout3]      = RxCFR( cfo_recovered, params, T );
%     [AOUT,          cfrout4]      = RxCFR( cfo_recovered, params, T );
% 
%     cfrout.cfe = cfrout1.cfe + cfrout2.cfe + cfrout3.cfe + cfrout4.cfe ;
%     cfrout.cfo_est = cfrout1.cfo_est + cfrout2.cfo_est + cfrout3.cfo_est + cfrout4.cfo_est ;
end
