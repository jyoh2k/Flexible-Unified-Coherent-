function [demapper_out, I] = RxDemapper ( demapper_in, params)

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
       [demapper_out, I]  = QAMDemapper2( demapper_in,  params);
   else
       [demapper_out, I]  = QAMDemapper( demapper_in,  params);
   end 

end 
