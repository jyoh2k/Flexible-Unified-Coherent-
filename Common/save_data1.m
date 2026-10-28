  function save_data1( sim, stim_sig, FileName, fixed_type)  

%  Usage      :  save_data( sim, stim_sig, FileName)
%  Function   : save signals into file
%     1. to analyze dynamic range for fixed point design
%     2. to compare hardware RTL to fixed point code
%  Author     : Rha, Hae Young.
%  Contact    : miroandi@kaist.ac.kr   
%  Known bugs :

    global SW_PATH
    FileName = [SW_PATH 'Results/TestVector/' FileName];
    if ( size(stim_sig,1)==1)
        if ( isreal(stim_sig) == 1 ) 
            dlmwrite([FileName, '.txt'], (real(stim_sig(1,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f');  
        else 
            dlmwrite([FileName, 'I.txt'], (real(stim_sig(1,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f'); 
            dlmwrite([FileName, 'Q.txt'], (imag(stim_sig(1,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f');  
        end
    else
        if ( isreal(stim_sig) == 1 ) 
            dlmwrite([FileName, '1.txt'], (real(stim_sig(1,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f'); 
            dlmwrite([FileName, '2.txt'], (real(stim_sig(2,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f'); 

        else 
            dlmwrite([FileName, '1I.txt'], (real(stim_sig(1,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f'); 
            dlmwrite([FileName, '1Q.txt'], (imag(stim_sig(1,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f'); 

            dlmwrite([FileName, '2I.txt'], (real(stim_sig(2,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f'); 
            dlmwrite([FileName, '2Q.txt'], (imag(stim_sig(2,:) * 2^fixed_type.fracl ) )' , '-append', 'precision', '%.0f'); 
     
        end
    end
  end
