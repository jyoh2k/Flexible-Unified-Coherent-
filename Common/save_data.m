  function save_data( sim, stim_sig, FileName)  

%  Usage      :  save_data( sim, stim_sig, FileName)
%  Function   : save signals into file
%     1. to analyze dynamic range for fixed point design
%     2. to compare hardware RTL to fixed point code
%  Author     : Rha, Hae Young.
%  Contact    : miroandi@kaist.ac.kr   
%  Known bugs :

    global SW_PATH
    FileName = [SW_PATH 'Results/TestVector/' FileName];
    dlmwrite([FileName, '.txt'], (real(stim_sig(1,:)))' , '-append', 'precision', '%.0f'); 
  end
