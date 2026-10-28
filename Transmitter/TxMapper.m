function [mapper] = TxMapper ( mapperin,  params)

%  Usage      : mapper = TxMapper ( mapperin,  params);
%
%  Function   :
%     1.   QAMMapper ( IQ merged mapping)
%     2.   QAMMapper2 (IQ seperate mapping)
%     3.   params   : parameters 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

   if ( params.iq_sep == 1 ) 
       mapper = QAMMapper2( mapperin,  params);
   else
       mapper = QAMMapper ( mapperin,  params);
   end 


end 
