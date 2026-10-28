function [sims] = DrawMulti( simout, sims, params, sim_data, sim_set, sim_str)  

    [d1,d2] = size(sim_data);
    %sim_data2 = reshape (sim_data, d1, 
    %simout.out = 
    d2 = d2/length(sim_set);
   if ( length(sims.X_coor) ~= d1 )
       error('Data dimension does not match with the given X_coor');
   end
    color = ['y' 'g' 'm' 'c' 'r' 'b' 'k' 'b'  'r' 'g' 'm' ];  
    marker = ['o' 'o' 'o' 'o' 'o' 'o' '<' '<'  '<' '<' '<' ];  
     
     
    draw_new_plot = 1;
    for idx=1:length(sim_set )
        simout.legend =[ sim_str ' ', num2str(sim_set{idx}) ,' '];         
        simout.color = [ color(idx) marker(idx) '-'];
        sims.X_coor =  sim_data( :,(idx-1)*2+1 );
        simout.out = sim_data( :, (idx-1)*2+2 ); 
        sims = DrawSimout( simout, sims, params, draw_new_plot);  
        draw_new_plot = 0;
    end

end
