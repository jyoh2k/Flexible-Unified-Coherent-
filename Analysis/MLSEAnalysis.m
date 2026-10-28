function  [sims, frame] = MLSEAnalysis( sims, params, frame)

%  Usage      : [sfo]= MLSEAnalysis( sims, params, tpr)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

     
    if ( ~ sims.show_mlse  || ~ params.MLSE.en )
      return
    end
            
    if (  isempty(sims.mlse_axes)  || ~ ishandle(sims.mlse_axes) )
       [sims.mlse_axes, sims.mlsehandle] = MLSEGUI();
    end
    mlsehandle =sims.mlsehandle;
    mlse_axes={mlsehandle.axes1,  mlsehandle.axes2, ...
              mlsehandle.axes3,  mlsehandle.axes4};
    text_handle={mlsehandle.text2,  mlsehandle.text3, ...
              mlsehandle.text4,  mlsehandle.text5};
%     mlse_axes={mlsehandle.axes1,  mlsehandle.axes2, ...
%               mlsehandle.axes3,  mlsehandle.axes4, ...
%               mlsehandle.axes5,  mlsehandle.axes6, ...
%               mlsehandle.axes7,  mlsehandle.axes8, ...
%               mlsehandle.axes9,  mlsehandle.axes10, ...
%               mlsehandle.axes11, mlsehandle.axes12, ...
%               mlsehandle.axes13, mlsehandle.axes14, ...
%               mlsehandle.axes15, mlsehandle.axes16};


 
    
    C = params.MLSE.constraint_length;
    V = length(params.mapper_list );
    num_states   = V^(C-1)   ;
    hist_states = frame.MLSEout.hist_states_tr;
    hist_num = frame.MLSEout.hist_num_tr;
    branch_metric =  frame.MLSEout.coef ;
    branch_coef1 =  frame.MLSEout.coef1 ;
    V = size(hist_states,1);
    SubMLSEAnalysis(text_handle, mlse_axes, C, V, num_states, hist_states,hist_num, branch_metric, branch_coef1);
    
%     for idx3=1:16 
%         hold(mlse_axes{idx3}, 'on');
%     end
    
%     hist_states = frame.MLSEout.hist_states;
%     hist_num = frame.MLSEout.hist_num;
%     MLSEAnalysis1('g',  mlse_axes, C, V, num_states, hist_states,hist_num, branch_metric, branch_coef1);
%     for idx3=1:16 
%         hold(mlse_axes{idx3}, 'off');
%     end
end

function  SubMLSEAnalysis(text_handle, mlse_axes, C, V, num_states, hist_states,hist_num, branch_metric, branch_coef1)
   show_hist = 1;
    idx3= 0;
    max_nb0 = 0;
    color_str = {'y' 'r' 'g' 'b' 'y' 'm' 'g' 'c' 'y' 'r' 'g' 'b' 'y' 'm' 'g' 'c'};
    
    idx0 =0;
    if ( size(hist_states,1) == 8 )
        idx0 = 2;
    end
    for idx=(1:4)      
        str='';
        for idx2=1:num_states %  * M
            idx3= idx3 + 1;
            if ( show_hist )
                if ( idx2 < V+1 && idx  < V+1 )  
                    data_states =  hist_states(idx0+idx,idx2, 1:hist_num(idx0+idx,idx2));
                    [nb0, xb0] =hist( data_states(:),32);
                    plot( mlse_axes{idx}, xb0, nb0,[[ color_str{idx2} '-']],'LineWidth', 2  );
                    xlim( mlse_axes{idx}, [-5.5 5.5]);
                    max_nb0 = max( max_nb0, max(nb0));                    
                    hold(mlse_axes{idx}, 'on');
                end
                data_idx = get_sym_seq ( idx, idx2, C, V );
%                 disp(['Prev -> Cur ' , num2str((data_idx(end:-1:1) - 1 )*2-3), ...
%                     ' Mean ', num2str(branch_metric(idx, idx2)), ...
%                     ' Variance ', num2str( 1 ./ branch_coef1(idx, idx2)), ...
%                     ]);  
                str=[str,  num2str((data_idx(end:-1:1) - 1 )*2-(V-1), '%d -> %d,'), sprintf('    \t'), ...
                               num2str(branch_metric(idx, idx2), '%1.2f, '), sprintf('   \t'),...
                               num2str( 1 ./ branch_coef1(idx, idx2), '%1.2E '),  sprintf('\n')];
            end           
        end
        set(text_handle{idx}, 'String', str);
        hold(mlse_axes{idx}, 'off');
    end

    for idx3=1:4%16 
        default_color(mlse_axes{idx3});                    
        ylim( mlse_axes{idx3}, [-10 max_nb0]);
    end
    
end 

function data_idx = get_sym_seq ( idx, idx2, C, V )
   % Reverse time index T , T-1, T-2, ... T-(C-1)
    data_idx = floor(mod ((idx2-1) ./( V .^ (C-2:-1:0) ), V )) + 1;
    data_idx = [idx data_idx] ; 
end 

