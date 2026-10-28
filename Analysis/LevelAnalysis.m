
function lut = LevelAnalysis(params, frame, level ) 
    trainingseq = frame.txsignal.trainingseq(params.NTrainingSymbol+1:end);
    equalized = frame.recovered(params.NTrainingSymbol+1:end);  
    [lut, num_map] = GetLutr( params, trainingseq, level);
    [var_level, mean_level, dif_level] = SubLevelAnalysis(  0, 0,  real(trainingseq), real(equalized), level, lut, num_map);
    lut = [lut dif_level'];
end     
    
function [var_level, mean_level, dif_level] = SubLevelAnalysis( en_display, axes1, trainingseq, equalized, level, lut, num_map)

    constraint_memory = level -1;
     mapper_in = zeros(constraint_memory +1, size(trainingseq,2));
     idx = 1; 
     for ich=1:size(trainingseq,1)
         mapper_in(constraint_memory+1,:) = trainingseq(ich, :);
         for imem=constraint_memory:-1:1
             mapper_in(imem,:) =  [0 mapper_in(imem+1, 1:end-1)];
         end
         %% Main part : offset 
         max_nb0 = 0;
         base_val = 10;
         color_str = {'y' 'r' 'g' 'b'  'm' 'c' 'k' 'r' 'g' 'b' 'y' 'm' 'g' 'c'};

         for ilut=1:size(lut, 1)
             if ( mod(ilut,  num_map^(level-1)) == 1  ||  level == 1)
    %              figure;
                base_val = base_val + max_nb0 * 1.2;
             end
             symbol_idx =1:min(size(mapper_in,2),size(equalized,2));
             for imem=1:constraint_memory+1
                 symbol_idx = intersect( symbol_idx, find(mapper_in(imem,:) == lut( ilut, imem)));
             end
             mean_level(idx) = mean(equalized(symbol_idx) );
             var_level(idx) = var(equalized(symbol_idx) );
             dif_level(idx) =  lut( ilut, imem) -   mean_level(idx) ;
             idx = idx +1;
             [nb0, xb0] =hist( equalized(symbol_idx),32);   
             if ( en_display == 1 )
                 plot(  axes1, xb0, nb0+base_val,[ color_str{mod(idx,4)+1} '-'],'LineWidth', 2  );
                 hold (axes1, 'on');
             end
             max_nb0 = max(max_nb0, max(nb0)+100);

         end     
     end
    if ( en_display == 1 )
        default_color(axes1);
    end

    if ( en_display == 1 )
        % xlim(axes1,  [-5.5 5.5]);
        ylim(axes1,  [-10  max_nb0 + base_val ]);
        hold (axes1, 'off');
    end
end


function [lut, num_map] = GetLutr( params,trainingseq, level)
    [~, map_list]= QAMMapper2List(params);
    map_list=[];
    for map_val=-10:10
        if (  isempty(find(trainingseq == map_val)) == 0)
            map_list=[map_list; map_val;];
        end
    end

    lut = map_list;
    num_map = length(map_list);
    for ilevel =1:level-1
        lut2=[];
        for imap=1:size(map_list)
            lut3 = zeros(size(lut, 1), size(lut,2)+1);
            lut3(:, 1:end-1) = lut;
            lut3(:, end) = map_list(imap);
            lut2 = [lut2; lut3];
        end
        lut =lut2;
    end
end

function [lut] = GetLut1( params, level)
    [~, ~, ~, map_list]= QAMMapper2List(params);
    lut = map_list;
    for ilevel =1:level-1
        lut2=[];
        for imap=1:size(map_list)
            lut3 = zeros(size(lut, 1), size(lut,2)+1);
            lut3(:, 1:end-1) = lut;
            lut3(:, end) = map_list(imap);
            lut2 = [lut2; lut3];
        end
        lut =lut2;
    end
end

