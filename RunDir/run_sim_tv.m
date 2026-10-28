
sims.mode      = mode;
sims.X_coor    = X_coor;
[sims, params]=  ReInit ( sims, params  );   
%%
simout.out = zeros(1,2);
ROP=zeros(1,2);
for testvector=testvector_list
    for simseq=1:length(sims.X_coor)
        sims.testvector = testvector;
        [sims, params]     = SweepSim(  sims, params, simseq);
        [txsignal, params] = SelPtnFile ( sims.testvector , sims, params );
        
%   params.h_init_en =2;
%   params.stbc.h =frameout.stbcout.h(:,:,489);
        for idx=1:sims.max_num_sim
            [channelout]       = SelTestVector( sims.testvector , idx, sims, params ) ;
            if ( sims.channel_learning == 1 )
                params.stbc.h_init_en = 1 ;
                [~,frameout1, ~] =  RxTop( channelout, txsignal, sims, params) ;
                params.stbc.h_init_en = 2 ;
                params.stbc.h_init =  frameout1.stbcout.h(:,:,end);
            end
            [~,frameout, sims] =  RxTop( channelout, txsignal, sims, params) ;
            simout             = SimAnalysis( sims, simout, frameout, idx );
            simout.out(simseq, 1) = mean(simout.BER);
            simout.out(simseq, 2) = mean(simout.EVM);
            sims.en_disp_result = 2;
            disp_result(simout, frameout, sims, params);
        end
        sims.en_disp_result = 1;
        disp_result(simout, frameout, sims, params);
    end
end 
%%
draw_new_plot = 0 ;
sims1.plot_mode = 1 ;
sims1.X_coor = sims.X_coor;
sims1.Xlabel = sims.Xlabel;
sims1.Ylabel = sims.Ylabel;
if ( mode == 35 )
    sims1.X_coor = [-30:1:-15];
    sims1.Xlabel = 'ROP(dBm)';
end
simout.legend = legend_str; 
% coloridx =8;
simout.color = 'ms-';
simout.title = [ 'BER   '  ];
simout.color = get_color(coloridx); 
sims1 = DrawSimout( simout, sims1, params, draw_new_plot);  

sims1.plot_mode = 2 ;
simout.title = [ 'EVM   '  ];
sims1.Ylabel = 'EVM';
sims1 = DrawSimout( simout, sims1, params, draw_new_plot);  
