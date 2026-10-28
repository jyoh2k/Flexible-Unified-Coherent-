  function save_datap( sim, stim_sig, FileName, fixed_type)  

%  Usage      :  save_data( sim, stim_sig, FileName)
%  Function   : save signals into file
%     1. to analyze dynamic range for fixed point design
%     2. to compare hardware RTL to fixed point code
%  Author     : Rha, Hae Young.
%  Contact    : miroandi@kaist.ac.kr   
%  Known bugs :

    global SW_PATH
    FileName = [SW_PATH 'Results/TestVector/' FileName];
    stim_sigp = stim_sig/2/pi ;
    if ( size(stim_sigp,1)==1) 
            dlmwrite([FileName, '.txt'], (real(stim_sigp(1,:) * 2^(fixed_type.wordl) ) )' , '-append', 'precision', '%.0f');         
    else
            dlmwrite([FileName, '1.txt'], (real(stim_sigp(1,:) * 2^(fixed_type.wordl) ) )' , '-append', 'precision', '%.0f'); 
            dlmwrite([FileName, '2.txt'], (real(stim_sigp(2,:) * 2^(fixed_type.wordl) ) )' , '-append', 'precision', '%.0f'); 
    end
  end
