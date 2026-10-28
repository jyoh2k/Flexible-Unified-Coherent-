
function  SaveOsc(channelout, sims, params, simnum)

%  Usage      : SaveOsc(mode1_X, sims,params,frameout )
%  Function   :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

     if ( sims.store_data == 0)
         return
     end
     
    if ( sims.store_data == 2 && sims.simnum > sims.max_num_sim )
         return
    end
     
    global SW_PATH  
    result_dir = [SW_PATH      'Results' filesep  date ];
    [s,messy] =mkdir([   result_dir ]);
    file_name1=[  result_dir filesep 'Tbps' date  '_PTBC_RXDP' num2str(sims.simnum) '_' num2str(params.BaudFreq/1e9 ), '.mat']; 
    disp(['Saved ' file_name1 ])

    
    save(file_name1,'channelout');
end
