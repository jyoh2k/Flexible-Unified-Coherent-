function esignal_bw =  OpticalReceiver( osignal,  params)

%  Usage      : esignal =  OpticalReceiver( osignal,  params)
%  Function   :
%     1. PD (Direct detection)
%     2. Coherent PD      
%     3. Stokes vector receiver
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

   if ( strcmp( params.type, 'Direct') )
        esignal_bw = PD(osignal, params);
        params.dccancel.en = params.en_DCCancel;
        [esignal_bw, dc_val] = DCBlock( params.dccancel, esignal_bw);
   end

   if ( strcmp( params.type, 'Coherent') )
        esignal_bw = CoherentPD(osignal, params);
   end

   if ( strcmp( params.type, 'SVR') )
        esignal_bw = SVR(osignal, params);
   end

end
