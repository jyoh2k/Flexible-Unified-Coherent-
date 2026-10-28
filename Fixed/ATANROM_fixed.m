
function [phase_1] = ATANROM_fixed( INr, INi, ATANINbit, ATANbit) %#codegen
    ATANINbit1= ATANINbit.fracl;
    tablex=0:2^(ATANINbit1)-1;
    tabley=0:2^(ATANINbit1)-1;
    ROM = tablex' * ones(1, length(tabley) )   + 1j* ones( length(tablex), 1) * tabley ;
    phase_ROM = angle( ROM ) ;
    phase_ROM =  fie_phase(phase_ROM, ATANbit)  ;
    phase_1 = phase_ROM(INr+1, INi+1);
end 
