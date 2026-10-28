function demapper_out = Demapper2 ( demapper_in,  params, T)

    if ( params.QAM_factor ==  1)
        [hard_dec,I, I2] = HardDecision( demapper_in, params); 
        [demapper_out]  = PAMDemapper( I2, [], params );
    else
        [demapper_out] = QAMDemapper2 ( demapper_in,  params, T);
    end
end 