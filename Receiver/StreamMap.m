function [ out , fsfs] =StreamMap( in, fsfs,  params, T )
%  Usage      :   [ out,  phase_est ] = PhaseInit( in, params, T )
%
%  Function   :

 
%     Cor =  fsfs.metric1( :, fsfs.MaxPos);
    Cor =  fsfs.metric_max; 
    out = in;
    rot = 0;
    if ( size(in,1) < 2 )
        return;
    end 
    if ( (Cor(1)+Cor(4) < Cor(2) + Cor(3)))
        out(1,:) = in(2,:);
        out(2,:) = -in(1,:);
        rot = 1;
        
    end 
    
     fsfs.pol_est = rot ; 

end