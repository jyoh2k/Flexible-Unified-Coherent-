function [dataf] =  DataGen( ptn, totalbits, offset )

%  Usage      : [dataf] =  DataGen( ptn , totalbits, offset )
%  Function   :
%     1. Data generator 
%     2. ptn        : Parameter for data pattern
%     3. totalbits  : Number of total bits of output 
%     4. offset     : offset on data pattern file to generate output data
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

filename = ptn.data_file ;

if ( ptn.useprbsdata == 1 )
    %% read pbrs
%     global SW_DEBUG_ONLY
%     if ( SW_DEBUG_ONLY == 1 )
%         filename='/home/miroandi/Service/2026/Tbps_26/TOI_26/2_Matlab/../../DSP_Platform/Ptn/prbs11.txt';
%     end 
    pbrs =importdata(filename);    
    pbrs = reshape(pbrs,1,length(pbrs));
    tmpdata = pbrs;
    for ii=1:(ceil(totalbits/length(tmpdata) )+offset/length(tmpdata))
        tmpdata = [tmpdata pbrs];
    end
    dataf = tmpdata(offset+1:offset+totalbits);
else
    rng(11, 'twister'); %  Mersenne Twister 
    dataf = double(rand(1,totalbits) > 0.5);
end

end
