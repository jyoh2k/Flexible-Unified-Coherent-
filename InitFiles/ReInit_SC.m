function [sims, params]=  ReInit ( sims, params  )

global SW_PATH
run( [ 'Units.m']);

%% simulation 
sims.Ylabel = sims.plot_str{sims.plot_mode};


%% pattern
file_length  = length(importdata( sims.dataf.data_file ));
ptn_length   = lcm( file_length, params.Nbitspersymbol)/ params.Nbitspersymbol;
params.ptn_rep_length    = ptn_length;
        
params.filter_name = [SW_PATH 'InitFiles/' num2str(sims.channel.fiber_length/km) 'km_' num2str(params.BaudFreq/GHz) '_coef.mat'];

params = FixedBit(params);

%%  DSP
params.TXoversample      = params.TXSampleFreq /  params.BaudFreq;
params.RXoversample      = params.RXSampleFreq /  params.BaudFreq;
params.ADCSampleFreq     = params.RXSampleFreq; 
if ( params.ps.en == 1 )
params.GrayMap = 0;
end

if ( params.testmode == 1)
params.NSymbol           = params.NTrainingSymbol;
end 
params = get_format_map(params);
%params.blkterm = reinit_blkterm( params.blkterm, params );
params.mapper    = reinit_mapper( params.mapper,  params );
params.tmapper   = reinit_tmapper( params.tmapper,  params );
params.smapper   = reinit_smapper( params.smapper,  params );
params.pilot   = reinit_pilot(params.pilot, params);
%params.precoding = reinit_precoding( params.precoding, params );
params.lutpredistortion = reinit_lutpredistortion( params.lutpredistortion, params );
params.fec = reinit_fec( params.fec, params );
params.ps = reinit_ps( params.ps, params );
params.demap             = reinit_demapper( params.demap,  params );
params.TXoversample      = params.TXSampleFreq /  params.BaudFreq;
params.RXoversample      = params.RXSampleFreq /  params.BaudFreq;
params.sync_pattern = get_sync_pattern(  params, sims);
%params.txnlapdp  = reinit_dfe(params.txnlapdp, params);
params.txnlapdp  = reinit_dfe(params.txnlapdp, params);
params.txnlapdp  = reinit_nlapdp(params.txnlapdp, params);
params.stbcdivdec= reinit_stbcdivdec(params.stbcdivdec, params);

params                   = get_frame_length(params);
params                   = get_awg_pad(params);



params.TXMatchedfilter.time_resp = SRRC( max(2, params.TXoversample),...
                                   params.TXMatchedfilter.alpha, ...
                                   params.TXMatchedfilter.resp_sample);
params.RXMatchedfilter.time_resp = SRRC( params.RXoversample,...
                                   params.RXMatchedfilter.alpha, ...
                                   params.RXMatchedfilter.resp_sample);
params.RXMatchedfilter.freq_resp = SRRC( params.RXoversample,...
                                   params.RXMatchedfilter.alpha, ...
                                   (length(params.OFDE.freq_resp)-1)/2, 'freq');
params.TXMatchedfilter = reinit_txmatched_filter(params.TXMatchedfilter, params);
params.RXMatchedfilter = reinit_rxmatched_filter(params.RXMatchedfilter, params);
params.demap             = reinit_demapper( params.demap,  params );
params.skew              = reinit_skew(params.skew, params );
params.txskew            = reinit_txskew(params.txskew, params );
params.searchframe = reinit_searchframe( params.searchframe, params );
params.searchfineframe = reinit_searchfineframe( params.searchfineframe, params );

params.rxpostemp =   reinit_preemp( params.rxpostemp, params);
params.txpreemp  =   reinit_preemp( params.txpreemp , params);
params.tpr = reinit_tpr( params.tpr, params);
params.cpr = reinit_cpr( params.cpr, params);
params.cpr1= reinit_cpr( params.cpr1, params);
params.cfr = reinit_cfr( params.cfr, params);
params.dfe = reinit_dfe( params.dfe, params);
params.dfe1 = reinit_dfe( params.dfe1, params );
params.stbc = reinit_stbc( params.stbc, params );
params.dfe1.filtertap_update_size = params.training_seq_size /2 * 0  ;

params.OFDE.SampleFreq = params.RXSampleFreq ;
params.OFDE =  get_OFDE ( sims.channel, params.OFDE  ); 
params.derot.NTrainingSymbol    = params.NTrainingSymbol ;
[filter_length]=  get_FilterLength( sims, params );
[h]=  get_CD_filter ( sims, params, filter_length  );
% params.rxpostemp.b =h;
% params.rxpostemp.en =1;
params = FixedBit(params);
%%  Channel
params.TX_IFSampleFreq   = params.AWGSampleFreq;
params.RX_IFSampleFreq   = params.OSCFreq;
sims.channel.TXSampleFreq =  params.AWGSampleFreq;
sims.channel.RXSampleFreq =  params.OSCFreq;

% if ( params.NTXStream == 1 )
%      sims.channel.Npol = 1 ;
% end

sims.channel = get_channel_parameter( sims.channel );
sims.channel.CarrierFreqOff_norm  = sims.channel.CarrierFreqOff / sims.channel.SampleFreq;
sims.channel.SNRdB_bw          = snr_bw(sims.channel.SNRdB,...
                                        params.BaudFreq,...
                                        sims.channel.RXSampleFreq);


%Bandwidth 
sims.channel.TXDAC             = reinit_DAC1(sims.channel.TXDAC, params);
sims.channel.RFDriver          = reinit_BW (sims.channel.RFDriver);
sims.channel.MZmod             = reinit_BW (sims.channel.MZmod);
sims.channel.PD                = reinit_PD( sims.channel.PD );
sims.channel.RXADC             = reinit_ADC1(sims.channel.RXADC, params);
sims.channel.RFAmp             = reinit_BW (sims.channel.RFAmp);
             
if ( params.modulation_format  == 2 )
       
end

if ( sims.run_mode ==  1 )
  run_mode_str = 'Sim';
else
  run_mode_str = 'Test';
end

sims.logfile =[SW_PATH '/Results/Log/', run_mode_str, '_', ...
               datestr(now,'ddmmm'), '.txt'];
end

%% ----------------------

function sync_pattern = get_sync_pattern(  params, sims)
    dataf     = DataGen( sims.dataf, params.ptn_rep_length *params.Nbitspersymbol*params.NTXStream, 0 );
    mapper                 = QAMMapper ( dataf,  params.mapper);
    sync_pattern    = MultiStreamOut ( mapper,  params);
    if ( params.cfr.CFEtype == 1 )
        sync_pattern=[];
    end 
    if ( params.cfr.CFEtype == 2 )
        cfo_sync16_ptn = rand(1, params.Nbitspersymbol * 16) > 0.5;
        sync_pattern =  QAMMapper ( cfo_sync16_ptn,  params);
    end

    if ( params.cfr.CFEtype == 5 )
        if ( params.Nbitspersymbol >4)
            params.Nbitspersymbol =4;
            params.mapper.Nbitspersymbol =4;
        end
        if ( params.Nbitspersymbol == 3)
            params.Nbitspersymbol =2;
            params.mapper.Nbitspersymbol =2;
        end
        sync_pattern1 = get_sync_pattern_crt(params, sims, 1);
        sync_pattern2 = get_sync_pattern_crt(params, sims,2 );
        sync_pattern = [sync_pattern1; sync_pattern2;]; 
        if ( params.PTBC == 0 &  params.NTXStream == 1 )
        	sync_pattern =sync_pattern1; 
        end
%         sync_pattern = [sync_pattern1; circshift(sync_pattern1, [37 0]);]; 
        %disp(['CRT pattern randomly generated(Pol).']);
    end
end

function sync_pattern = get_sync_pattern_crt( params, sims, chidx)

        cfo_sync16_ptn = rand(1, params.Nbitspersymbol * 16) > 0.5;
        cfo_sync9_ptn = rand(1, params.Nbitspersymbol * 9) > 0.5;
        sync16_pattern  =  QAMMapper ( cfo_sync16_ptn,  params.mapper);
        if (  params.Nbitspersymbol == 4) 
            sync16_pattern = ...
                [-0.9487 - 0.3162i  -0.9487 + 0.3162i   0.3162 - 0.9487i   0.9487 - 0.3162i  ...
                 -0.3162 + 0.3162i   0.9487 + 0.3162i  -0.3162 - 0.9487i  -0.9487 - 0.9487i  ...
                  0.3162 + 0.9487i  -0.9487 + 0.9487i  -0.3162 - 0.3162i  -0.3162 + 0.9487i ...
                  0.3162 + 0.3162i   0.9487 + 0.9487i   0.3162 - 0.3162i   0.9487 - 0.9487i];

            cfo_sync9_ptn = ...
                [ 0     0     0     1     0     1     1     1     1     1     0     0     0     1  ...
                  0     1     1     0     0     1     0     1     0     1     1     0     1     0  ...
                   1     0     1     1     1     0     0     1 ];
        end   
        if( chidx == 2 )
            sync16_pattern = circshift( sync16_pattern,2,2);  
            cfo_sync9_ptn = ...
            [  0     1     1     0     0     1     1     0     1     1     1     1     0     0  ...
               1     1     0     0     1     0     0     0     0     1     1     0     0     0 ...
               0     0     1     0     1     0     1     1];
        end
        
        sync9_pattern   =  QAMMapper ( cfo_sync9_ptn,params.mapper);  
        if (  params.Nbitspersymbol == 2) 
            if( chidx == 1 )
                cfo_sync16_ptn = [ ...
                   1     0     0     0     1     1     0     0     0     0     0     1     0     0     0  ...
                   0     1     0     0     1     1     0     0     1     1     1     0     1     0     1  ...
                   1     1 ];
               
               cfo_sync9_ptn = [ ... 
                   1     1     0     0     0     1     0     0     1     1     0     1     1     0     1  ...
                   1     0     1]; 
            end
            if( chidx == 2 )
                cfo_sync16_ptn = [ ...
                    0     0     1     0     1     1     1     1     0     0     0     0     0     0     0  ...
                    0     1     1     0     1     0     1     1     1     0     0     0     1     1     1  ...
                    0     0];
                cfo_sync9_ptn = [ ...
                   1     0     1     1     1     0     1     1     1     1     0     1     1     0     1  ...
                   1     0     0];
            end
            sync16_pattern  =  QAMMapper ( cfo_sync16_ptn,  params.mapper);
            sync9_pattern   =  QAMMapper ( cfo_sync9_ptn,  params.mapper);
        end
        sync16_pattern  = [sync16_pattern sync16_pattern sync16_pattern ];
        sync16_patterns = [sync16_pattern sync16_pattern sync16_pattern ];
        sync9_patterns  = [sync9_pattern sync9_pattern ...
                           sync9_pattern sync9_pattern ];
        sync9_patterns  = [sync9_patterns sync9_patterns ];
        sync_pattern    = [sync9_patterns sync16_patterns];
        sync_pattern    = sync_pattern(1:9*16);
%         sync_pattern1   = [sync_pattern;sync_pattern;sync_pattern;];
%         sync_pattern    = reshape(sync_pattern1, 1, length(sync_pattern)*3);
end

function params = get_format_map(params)
    params.mapper_list       = QAMMapperList(params);
    [~,   mapper1_list]      = QAMMapper2List (  params) ;
    params.mapper1_list      = mapper1_list;
    mapper_list = 1/sqrt(2) * (ones(2,1) * [ -1 1  ]) ;
    mapper_list = mapper_list + 1j * mapper_list';
    params.smapper_list      = squeeze(mapper_list(:));
    params.tmapper_list      = squeeze(mapper_list(:));
end 

function params = get_frame_length(params)
    if ( params.fec.en == 1 )
        fec_frame_symbol     =  lcm(params.fec.n * params.QAM_factor, params.Nbitspersymbol);
        fec_frame_symbol     =  lcm(fec_frame_symbol, params.block_size/params.pilot.rate);
        fec_frame_symbol     = fec_frame_symbol/params.Nbitspersymbol;
        num_fec_frame        = ceil(params.NDataSymbol /params.pilot.rate/fec_frame_symbol);
        params.NDataSymbol   = num_fec_frame * fec_frame_symbol * params.pilot.rate ;
    end
    if ( params.fec.en == 0 )
        fec_frame_symbol     =  lcm( params.QAM_factor, params.Nbitspersymbol);
        fec_frame_symbol     =  lcm(fec_frame_symbol, params.block_size/params.pilot.rate);
        fec_frame_symbol     = fec_frame_symbol/params.Nbitspersymbol;
        num_fec_frame        = ceil(params.NDataSymbol /params.pilot.rate/fec_frame_symbol);
        params.NDataSymbol   = num_fec_frame * fec_frame_symbol * params.pilot.rate ;
        num_fec_frame        = ceil(params.NTrainingSymbol /params.pilot.rate/fec_frame_symbol);
        params.NTrainingSymbol   = num_fec_frame * fec_frame_symbol * params.pilot.rate ;
        params.fec.k= params.fec.n ;
    end
    params.NSymbol       = params.NDataSymbol  + params.NTrainingSymbol ;
    params.NSymbol       = params.NSymbol  + params.NSignalSymbol ;

    if ( params.ps.en == 1)
        rate = (params.ps.k * params.ps.num_dm_block_per_fec +params.ps.signbit )/params.fec.k ;
    else
        rate = 1;
    end
    params.databits        = params.NDataSymbol * params.Nbitspersymbol;
    params.databits        = params.databits * params.NTXStream;
    params.databits        = params.databits * rate *  ...
                             params.fec.k/params.fec.n /params.pilot.rate;
    params.trainingbits    = params.NTrainingSymbol* params.Nbitspersymbol_Tr;
    params.trainingbits    = params.trainingbits / params.pilot.rate;
    params.signalbits      = params.NSignalSymbol  * params.Nbitspersymbol_Sig; 
    params.signalbits      = params.signalbits   / params.pilot.rate;
    if ( params.signal.en == 1)
        params.signalbits      = ceil(params.signalbits / ( 2^params.signal.m - 1))* (2^params.signal.m - params.signal.m -1);
    end
    if ( params.signal.en == 2)
        params.signalbits      = ceil( params.signalbits /params.signal.n * params.signal.k);
    end

    params.totalbits       = params.databits + params.trainingbits ;
    params.totalbits       = params.totalbits + params.signalbits; 

    params.NFrameSymbol    = length(params.frame_header) + params.NSymbol;
    if (  params.cfr.CFEtype  == 1)
        params.Npreamble = 0;
    else
        params.Npreamble = size(params.sync_pattern,2);
    end
    params.NFrameSymbol    = params.Npreamble * 2 + params.NFrameSymbol;
    params.NFrameSymbol    = params.NFrameSymbol + 96;
    params.NFrameSample    = params.NFrameSymbol * params.RXoversample ;
end

 
function params = get_awg_pad(params)
    if ( isa(params.AWGSampleFreq, 'integer') == 0 || isa(params.AWGSampleFreq, 'integer') == 0)
        params.awg_pad = 0;
        return;
    end 
    gcd1 = gcd(params.AWGSampleFreq, params.TXSampleFreq);
    txunit = params.TXSampleFreq/gcd1;
    awgunit=params.AWGSampleFreq/gcd1 * 128;
    pad1 = ceil(params.NFrameSample/txunit) * txunit - params.NFrameSample;
    NFrameSample_TX = params.NFrameSample + (params.Npreamble +96)  * 2 + pad1;
    NFrameSample_AWG = NFrameSample_TX * params.AWGSampleFreq/params.TXSampleFreq;
    NFrameSample_AWG = ceil(NFrameSample_AWG/awgunit) * awgunit ;
    pad2 = NFrameSample_AWG *params.TXSampleFreq/params.AWGSampleFreq -NFrameSample_TX ;
    params.awg_pad = pad1 + pad2;
end


function emphasis = reinit_preemp( emphasis, params) 
    if ( emphasis.en == 0 )
        return;
    end    
    if ( strcmp(emphasis.filename, '') )
        emphasis.b  = [ 1 0.1];
        emphasis.a        = 1;   
    else
        load (emphasis.filename);
        emphasis.b  = PostEmphasis(end:-1:1); 
        emphasis.a        = 1;   
    end 
end 

function cpr = reinit_cpr( cpr, params)
    cpr.OV             = params.RXoversample;
    cpr.mapper_list    = squeeze(params.mapper_list) ;
    cpr.smapper_list   = squeeze(params.smapper_list) ;
    cpr.tmapper_list   = squeeze(params.tmapper_list) ;
    cpr.Nbitspersymbol = params.Nbitspersymbol;
    cpr.OV             = params.RXoversample;
    cpr.PTBC           = params.RXDSP_PTBC;
    if ( params.pilot.en ~= 0 )
       if ( cpr.CPEtype == 5 ) % Pilot based 
           %cpr.STEP             = params.block_size;
           %cpr.fSTEP            = params.block_size; 
       end  
       if ( cpr.CPEtype == 6 ) % Pilot based Autocorrelation
           %cpr.STEP             = params.block_size * params.pilot.period;
           %cpr.BLK              = cpr.STEP * cpr.OV;
       end  
    end
    cpr.period           = params.pilot.period;
    cpr.NTrainingSymbol  = params.NTrainingSymbol;
    cpr.NSignalSymbol    = params.NSignalSymbol;
    cpr.training_seq_size    = params.NTrainingSymbol;
    cpr.signal_seq_size      = params.NTrainingSymbol + params.NSignalSymbol;
    if ( params.RXDSP_PTBC == 1 && cpr.CPEtype == 5)
    	cpr.NTrainingSymbol  = 0;
    end
    if ( params.RXDSP_PTBC == 1 && cpr.CPEtype == 6)
    	cpr.NTrainingSymbol  = 0;
    end
    if ( params.RXDSP_PTBC == 1 && cpr.CPEtype == 7)
    	cpr.NTrainingSymbol  = 0;
    end
    if (   cpr.CPEtype == 8)
    	cpr.NTrainingSymbol  = 0;
    end

end

function tpr = reinit_tpr( tpr, params)
    tpr.OV            = params.RXoversample;
    %if ( params.RXMatchedfilter.en == 1 )
    % tpr.time_resp     = params.RXMatchedfilter.time_resp;
    %else
      tpr.time_resp     = 1;
    %end
    tpr.FilterLength = tpr.L + (length(tpr.time_resp)-1)/2;


end

function cfr = reinit_cfr( cfr, params);
    cfr.OV            = params.RXoversample;
    cfr.sync_pattern  = params.sync_pattern;
    cfr.exp_phasediff = params.cfr.CarrierFreqOff  / ( params.RXSampleFreq ) * 2 * pi;
    cfr.mapper_list    = squeeze(params.mapper_list) ;
    cfr.frame_length   = params.NSymbol;
end



function nlapdp  = reinit_nlapdp(nlapdp, params)
    %nlapdp.betab= 0;
    nlapdp.Npbe = 0;
    nlapdp.Np3be = 0;
    nlapdp.OV    = 1;
    nlapdp.training_seq_size = params.NSymbol * params.RXoversample;

    nlapdp = reinit_coef(nlapdp);

end

function stbcdivdec= reinit_stbcdivdec(stbcdivdec, params) 
    stbcdivdec.head = params.NTrainingSymbol -256;
    stbcdivdec.tail = params.NTrainingSymbol ;
end 

function params  = reinit_coef( params)
    coef = params.filtertap;
    ck    = complex( coef(:,1:params.Nffe));
    dk    = complex( coef(:,params.Nffe+(1:params.Nfbe)));
%     ek2   = ( coef(:,params.Nffe+params.Nfbe+(1:params.Ndpfe)));
%     ek    = complex(zeros(params.Npfe, params.W));
%     ek    = complex( reshape(ek2, size(coef,1),params.Npfe, params.W));
%     fk    = complex( coef(:,params.Nffe+params.Nfbe+params.Ndpfe+(1:params.Npbe)));
%     dc    = complex(zeros(1,1));

%     offidx = params.Nffe+params.Nfbe+params.Ndpfe+params.Npbe;
%     e3k2        = ( coef(:,offidx +(1:params.Ndp3fe)));
%     e3k        = complex(zeros(params.Np3fe, 0.5 * params.W3 * (params.W3+1)));
%     e3k         = complex( reshape(e3k2, size(coef,1),params.Np3fe, 0.5 *  params.W3 * (params.W3+1)));
%     offidx = params.Nffe+params.Nfbe+params.Ndpfe+params.Npbe + params.Ndp3fe;
%     f3k         = complex( coef(:,offidx +(1:params.Np3be)));
    params.ck    = ck;
    params.dk    = dk;
%     params.ek    = ek;
%     params.e3k   = e3k;
%     params.dc    = dc;

end


function dfe = reinit_dfe( dfe, params )
    dfe.mapper_list  = params.mapper_list;
    dfe.smapper_list = params.smapper_list;
    dfe.tmapper_list = params.tmapper_list;
    dfe.term_symbol = params.term_symbol ;
    dfe.PTBC             = params.RXDSP_PTBC;
    dfe.NStream     = params.NRXStream;
    if ( dfe.PTBC == 1 )
        dfe.NStream     = 2;
    end
    dfe.OV          = params.RXoversample;
    dfe.Nbitspersymbol = params.Nbitspersymbol;
    dfe.training_seq_size    = params.NTrainingSymbol;
    dfe.signal_seq_size      = params.NTrainingSymbol + params.NSignalSymbol;
    %dfe.training_seq_size    = dfe.training_seq_size  * dfe.OV;
    %dfe.signal_seq_size      = dfe.signal_seq_size    * dfe.OV;
    dfe.en_block_termination = params.en_block_termination;
    dfe.Nfilter              = 0;
    dfe.Nffe_update_coef = dfe.Nffe;
    if ( dfe.Nfbe == 0 )
        dfe.Nfbe = 1;
        dfe.betab =0;
    end
    dfe.Ndpfe = dfe.Npfe * dfe.W ;
    dfe.Ndp3fe = dfe.Np3fe * dfe.W3 * (dfe.W3+1) /2 ;
    dfe.Ndfe  = dfe.Nffe+dfe.Nfbe+dfe.Ndpfe + dfe.Npbe+dfe.Ndp3fe + dfe.Np3be;
    dfe.Npostcursor =  round( (dfe.Nffe- 1)/2) ;

    dfe.cost_function = 1;
    if (dfe.type  == 4 || dfe.type  == 6  || dfe.type  ==  7)  
       dfe.cost_function = 4; 
    end  
    dfe = reinit_dfe_filtertap( dfe, params );
    dfe = reinit_RLS( dfe, params );
    if (params.en_block_termination  ~= 0 )
        dfe.block_size  = params.block_size ;
        dfe.en_block_termination = 1;
    end
    if (params.pilot.en   ~= 0 )
        dfe.en_block_termination = 2;
        dfe.block_size  = params.block_size ;
    end
    if (params.pilot.en   == 4 )
        dfe.en_block_termination = 4;
        if (  dfe.PTBC == 1)
            dfe.block_size  = params.block_size;
        else
            dfe.block_size  = params.block_size * 2;
        end        
    end
    dfe = reinit_dfeskew( dfe, params );
end


function dfe = reinit_dfeskew( dfe, params )
    if ( dfe.skewcomp_en == 1) %4x4 Real MIMO
        [~, dfe.mapper_list]      = QAMMapper2List (  params) ;
        NStream = params.NStream  * params.NRXStream * 4;
        filtertap_init = zeros(NStream, size(dfe.filtertap,2));
        filtertap_init(1:(params.NRXStream )* 2 +1:end , dfe.Npostcursor+1)=1;
        filtertap_init(:, end) = 1;
        dfe.filtertap = filtertap_init;
        dfe.NStream = dfe.NStream  * 2;
    end
    if ( dfe.skewcomp_en == 2) % widely linear MIMO
        NStream = dfe.NStream  * params.NRXStream * 2;
        filtertap_init = zeros(NStream, size(dfe.filtertap,2));
        filtertap_init([1:(dfe.NStream +1):dfe.NStream^2], dfe.Npostcursor+1)=1;
        filtertap_init(:, end) = 0;  
        dfe.filtertap = filtertap_init; 
    end
end

function dfe = reinit_RLS( dfe, params )
    if ( dfe.Nfbe ~= 0 && dfe.betab ~=0 )
       RLStap = dfe.Nffe + dfe.Nfbe;
    else
       RLStap = dfe.Nffe;
    end
    P_mat= ones(size(dfe.filtertap,1),1)*reshape(complex(eye(RLStap)), 1,RLStap^2);
    Rinv  =  reshape(P_mat, size(dfe.filtertap,1),RLStap,RLStap);
    Rinv  =  dfe.delta * complex(Rinv);
    dfe.P_mat = Rinv;
end

function dfe = reinit_dfe_filtertap( dfe, params )
    if ( dfe.init_filter_rand == 1)
        filtertap_init = ones(params.NRXStream * dfe.NStream, dfe.Ndfe) ;
        filtertap_init = rand(size(filtertap_init)) / ...
                         sqrt(sum(sum(filtertap_init)));
    else
        if ( dfe.PTBC == 1)
            filtertap_init = zeros(4, dfe.Ndfe);
            filtertap_init( 1,  dfe.Npostcursor+1) = 1;
            filtertap_init( 4,  dfe.Npostcursor+1) = -1;
        else
            filtertap_init = zeros(params.NRXStream * dfe.NStream, dfe.Ndfe);
            filtertap_init( [0:params.NRXStream-1] * ...
                            ( params.NRXStream +1)+1, dfe.Npostcursor+1) = 1;
        end
    end
    dfe.filtertap   = filtertap_init  ;
    if ( dfe.load_filtercoef )
        load(dfe.filter_name) ;
        dfe.filtertap = filtercoef;
    end
end

function stbc = reinit_stbc( stbc, params )
    stbc.en          =  params.RXDSP_PTBC;
    stbc.mapper_list =  params.mapper_list;
    stbc.smapper_list =  params.smapper_list;
    stbc.tmapper_list =  params.tmapper_list;

    stbc.Npostcursor =  round((stbc.Nffe-1)/2);
    stbc.NStream     = 2;
    stbc.OV          = params.RXoversample;
    stbc.en_block_termination = 0;
    if ( params.pilot.en ~= 0 )
        stbc.en_block_termination = 2; % Termination symbol :first symbol at a block
        stbc.block_size = params.block_size;
    end
    if ( params.pilot.en == 4 )
        stbc.en_block_termination = 4; % Termination symbol :first symbol at a block
        stbc.block_size = params.block_size;
    end
    stbc.training_seq_size    = params.NTrainingSymbol;
    stbc.signal_seq_size      = params.NTrainingSymbol + params.NSignalSymbol;
    stbc.pilot_en    =  params.pilot.en;
end

function [skew]=  reinit_txskew( skew, params  )
 ps =1e-12;
   skew.sft(1,1) = skew.skew_ps(1)  * ps *  params.AWGSampleFreq;
   skew.sft(2,1) = skew.skew_ps(2)  * ps *  params.AWGSampleFreq;
end

function [skew]=  reinit_skew( skew, params  ) 
 ps =1e-12;
   skew.sft(1,1) = skew.skew_ps(1)  * ps *  params.RXSampleFreq;
   skew.sft(2,1) = skew.skew_ps(2)  * ps *  params.RXSampleFreq;
end



function sync = reinit_searchframe( sync, params )
    if ( size(params.frame_header,2) ~= 0 )
        sync.sync_pattern   = params.frame_header;
    else
        sync.sync_pattern   = params.sync_pattern;
    end
    sync.offset         = 0;
    sync.NFrameSymbol   = params.NFrameSymbol * params.RXoversample;
    sync.CFEtype        = params.cfr.CFEtype;
    sync.ptn_rep_length = params.ptn_rep_length;
    sync.RXoversample   = params.RXoversample;
    sync.frame_header   = params.frame_header;
    sync.frame_length   = params.NFrameSymbol + params.awg_pad;
end

function finesync = reinit_searchfineframe( finesync, params )
    finesync.sync_pattern   = params.sync_pattern;
    finesync.NFrameSymbol   = params.NSymbol ;%* params.RXoversample;
    finesync.NFrameSample   = params.NSymbol * params.RXoversample;
    if ( params.modulation_format == 3 || params.modulation_format == 2 )
    %finesync.offset         = params.dfe.Npostcursor + params.tpr.L -1;
    finesync.offset         =  1;
    else
    %finesync.offset         = params.dfe.Npostcursor + params.tpr.L ;
    finesync.offset         =  0;
    end
    finesync.offset         =  finesync.offset  + size(params.sync_pattern,2);
    finesync.CFEtype        = params.cfr.CFEtype;
    finesync.ptn_rep_length = params.ptn_rep_length;
    finesync.RXoversample   = params.RXoversample;
end

function ps = reinit_ps( ps, params )
    pas_bit    = params.Nbitspersymbol /params.QAM_factor - 1;
    ps.QAM_factor            = params.QAM_factor ;
    
    level      = 2^(pas_bit );
    code_size  = params.fec.n/(pas_bit + 1)  ; %symbol
    num_dm_block_per_fec = 1;
    if ( params.QAM_factor == 2 && ...
            mod(params.Nbitspersymbol,params.QAM_factor) ==0 )
        B_level = sqrt(length(params.mapper_list));
        mapper_list =real(params.mapper_list(1:B_level:end));
    else
        mapper_list =real(params.mapper_list(1:end));
    end
    ps.mapper_list = reshape( mapper_list, 1, length(mapper_list));
    ps.Nbitspersymbol = params.Nbitspersymbol;
    
    if ( ps.en == 0 )
        ps.k = params.fec.k ;
        ps.n = params.fec.k ;
        ps.signbit = 0 ;
        ps.entropy       = params.Nbitspersymbol /params.QAM_factor;
        type_seq = ones(1, 2^floor(params.Nbitspersymbol/params.QAM_factor));
        ps.type_seq = type_seq + 1j * type_seq;
        ps.level   = level;
        ps.num_dm_block_per_fec=1;
        return;
    end 
    while ( code_size > 10000 )
        code_size = code_size / 2;
        num_dm_block_per_fec = num_dm_block_per_fec* 2;
    end
    rate       = ps.entropy - 1;
    ps.ccdm      = ccdm( level, code_size, rate, 30);
    ps.n            = ps.ccdm.n;
    ps.k            = ps.ccdm.k;
    ps.signbit = params.fec.k  - ps.n * num_dm_block_per_fec * pas_bit;  
    ps.level   = level;
    ps.num_dm_block_per_fec  = num_dm_block_per_fec ;
    type_seq = ps.ccdm.type_seq;
    type_seq = [type_seq(end:-1:1); type_seq;]'; 
    if ( params.QAM_factor == 1)
        ps.type_seq = type_seq;
    else
        ps.type_seq = type_seq + 1j * type_seq;   
    end
end 

function map = reinit_mapper( map, params  )
    if ( params.QAM_factor == 2 && ...
            mod(params.Nbitspersymbol,params.QAM_factor) ==0  )
       [mapper_list,mapper1_list]= QAMMapper2List (params);
    else
       [mapper_list,mapper1_list]= QAMMapperList (params);
    end
    map.B_level = sqrt(length(mapper_list));
    map.mapper_list = reshape( mapper_list, 1, length(mapper_list));
    map.Nbitspersymbol = params.Nbitspersymbol;
    map.QAM_factor = params.QAM_factor;
    map.GrayMap    = params.GrayMap;
    map.big_end_map= params.big_end_map;
end



function map = reinit_tmapper( map, params  )
    map.Nbitspersymbol = params.Nbitspersymbol_Tr;
    mapper_list       = QAMMapperList(map);
    [~,   mapper1_list]      = QAMMapper2List (  map) ;
    map.mapper1_list      = mapper1_list;
%     if ( params.QAM_factor == 2 )
%         demap.B_level = sqrt(length(params.mapper_list));
%         mapper_list = real(params.mapper_list(1:demap.B_level:end));
%     else
%         demap.B_level = (length(params.mapper_list));
%         mapper_list = params.mapper_list;
%     end
    map.mapper_list = reshape( mapper_list, 1, length(mapper_list));
    map.QAM_factor = params.QAM_factor;
    map.GrayMap    = params.GrayMap;
    map.big_end_map= params.big_end_map;
end

function map = reinit_smapper( map, params  )
    map.Nbitspersymbol = params.Nbitspersymbol_Sig;
    mapper_list       = QAMMapperList(map);
    [~,   mapper1_list]      = QAMMapper2List (  map) ;
    map.mapper1_list      = mapper1_list;
    map.mapper_list = reshape( mapper_list, 1, length(mapper_list));
    map.QAM_factor = params.QAM_factor;
    map.GrayMap    = params.GrayMap;
    map.big_end_map= params.big_end_map;
end

function [Matchedfilter]= reinit_txmatched_filter(Matchedfilter, params)
    if ( Matchedfilter.fixed_bit   == 1 && params.fixed_type == 1)
        Matchedfilter.sps  = 2;
    else
        Matchedfilter.sps  = 4;
    end
    Matchedfilter.p           = Matchedfilter.sps /params.TXoversample;
    Matchedfilter.q           = Matchedfilter.p ;
%     Matchedfilter.os_factor = 2;
    if ( Matchedfilter.en == 1)
        Matchedfilter.time_resp =  SRRC( Matchedfilter.os_factor,Matchedfilter.alpha, Matchedfilter.resp_sample);
    end
    if ( Matchedfilter.en == 2)
        Matchedfilter.time_resp =  RC( Matchedfilter.os_factor,Matchedfilter.alpha, Matchedfilter.resp_sample,Matchedfilter.FWHM);
    end

end

function [Matchedfilter]= reinit_rxmatched_filter(Matchedfilter, params)
    if ( Matchedfilter.fixed_bit   == 1 && params.fixed_type == 1)
        Matchedfilter.sps  = 2;
    else
        Matchedfilter.sps  = 4;
    end
    Matchedfilter.p           = Matchedfilter.sps /params.RXoversample;
    Matchedfilter.q           = Matchedfilter.p ;
    Matchedfilter.os_factor = 2;
    Matchedfilter.time_resp =  SRRC( Matchedfilter.os_factor,Matchedfilter.alpha, Matchedfilter.resp_sample);
end

function demap = reinit_demapper( demap, params  )
    % demap.type : 1: Hard decision, 2: , 3: Bit-metric decoding 
    if ( params.QAM_factor == 2  && ...
            mod(params.Nbitspersymbol,params.QAM_factor) ==0  )
        demap.B_level = sqrt(length(params.mapper_list));
        mapper_list = real(params.mapper_list(1:demap.B_level:end));
    else
        demap.B_level = (length(params.mapper_list));
        mapper_list = params.mapper_list;
    end
    demap.mapper_list = reshape( mapper_list, 1, length(mapper_list));
    demap.type_seq = params.ps.type_seq;
    demap.Nbitspersymbol = params.Nbitspersymbol;
    demap.QAM_factor = params.QAM_factor;
    demap.GrayMap    = params.GrayMap;
    demap.big_end_map= params.big_end_map;
end

function blkterm  = reinit_blkterm( blkterm, params )
    blkterm.en              = params.en_block_termination;
    blkterm.block_size_in   = params.block_size * params.Nbitspersymbol - length(params.term_bits);
    blkterm.block_size_out  = params.block_size * params.Nbitspersymbol;
    blkterm.bits            = params.term_bits ;
    blkterm.Nbit            = length(params.term_bits) ;
    blkterm.rate           = 1;
    if ( blkterm.en == 1 )
        %blkterm.rate            = blkterm.block_size_out/blkterm.block_size_in; 
        blkterm.rate            = params.block_size/(params.block_size -1); 
    end
end

function pilot  = reinit_pilot( pilot, params )
         
    pilot.block_size_in   = (params.block_size - 1 );
    pilot.block_size_out  = params.block_size ;
%     pilot.Nbitspersymbol = params.Nbitspersymbol; % Do not change
    pilot.T = params.mapper.T;
    pilot.symbol          = QAMMapper(params.term_bits, pilot);
    pilot.rate           = 1;
    pilot.en  = 0;
    if ( params.en_block_termination ~= 0)
        pilot.en  = params.en_block_termination;
        pilot.rate            = params.block_size/(params.block_size -1);
    end
end


function predistortion = reinit_lutpredistortion (predistortion, params )
    [~,~,~,~,norm1]= QAMMapper2List(params);
    predistortion.norm=norm1;
    if ( predistortion.en == 1 )
        predistortion.lut =predistortion_lut();
        predistortion.lut2=predistortion2_lut();
    end
end

function fec = reinit_fec( fec1, params )
    fec1.NTXStream = params.NTXStream * params.QAM_factor; 
    fec1.NRXStream = params.NRXStream * params.QAM_factor; 
    if ( fec1.en  == 0 )
       fec = fec1;
       fec.code_rate = 1;
       fec.FEC_mode  = 1;
       return;
    end
    if ( fec1.FEC_mode  == 0 )
        maxNumLDPCIterations = fec1.max_iter;
        subsystemType = fec1.subsystemType;
        EsNodB        = 30; % Meaningless
        fec = getParamsDVBS2Demo(subsystemType, EsNodB, maxNumLDPCIterations);
        fec.code_rate = fec.LDPCCodewordLength / fec.BCHMessageLength;
        fec.k = fec.BCHMessageLength;
        fec.n = fec.LDPCCodewordLength;
        fec.subsystemType = fec1.subsystemType;
        fec.max_iter = fec1.max_iter;
    end
    if ( fec1.FEC_mode  == 1 ) % RS 
        fec.N=255;
        fec.K=237;
        fec.S=161;
        fec.M=8;
        S = fec.K - fec.S;
        fec.k=fec.M * (fec.K -S);
        fec.n=fec.M * (fec.N -S);
        fec.code_rate = fec.n/fec.k;
    end
    %– RS(528, 514, 7) over GF(210) – 100GBASE-KR4
    %– RS(544, 514, 15) over GF(210) – 100GBASE-KP4
    if ( fec1.FEC_mode  == 4 ) % RS , KP4
        fec.N=544;
        fec.K=514;
        fec.M=10;
%         S = fec.K - fec.S;
        fec.k=fec.M * (fec.K);
        fec.n=fec.M * (fec.N);
        fec.code_rate = fec.n/fec.k;
    end
    if ( fec1.FEC_mode  == 5 ) % RS , KR4
        fec.N=528;
        fec.K=514;
        fec.M=10;
        S = fec.K - fec.S;
        fec.k=fec.M * (fec.K -S);
        fec.n=fec.M * (fec.N -S);
        fec.code_rate = fec.n/fec.k;
    end

    fec.en = 1;
    fec.FEC_mode = fec1.FEC_mode;    
    fec.NTXStream = params.NTXStream * params.QAM_factor; 
    fec.NRXStream = params.NRXStream * params.QAM_factor; 
end

function DAC = reinit_DAC( DAC, params)
    DAC.SampleFreq = params.AWGSampleFreq;
    DAC.FilterCoef = get_bandwidth_coef (1, DAC);
end

function DAC = reinit_DAC1( DAC, params)
    DAC.SampleFreq = params.AWGSampleFreq;
    DAC.FilterCoef = get_bandwidth_coef (0, DAC);
end

function dev = reinit_BW( dev)
    dev.FilterCoef = get_bandwidth_coef (1, dev);
end

function PD  = reinit_PD( PD )
    mV = 1e-3;
    PD.FilterTapNum =5 ;
    PD.max_output_power= 10^(PD.max_output_power_dBm/10)*mV ;
    PD.max_current     = sqrt(PD.max_output_power /PD.resistor); % RF power = R*I^2 ;
    PD.FilterCoef = get_bandwidth_coef (1, PD);
end

function ADC = reinit_ADC( ADC, params)
    ADC.SampleFreq = params.OSCFreq;
    ADC.FilterCoef = get_bandwidth_coef (1, ADC);
end

function ADC = reinit_ADC1( ADC, params)
    ADC.SampleFreq = params.OSCFreq;
    ADC.FilterCoef = get_bandwidth_coef (0, ADC);
end


function FilterCoef = get_bandwidth_coef (baseband, params)
    FilterTapNum  =7;
    mul_factor = 1;
    if ( baseband == 1 )
        mul_factor = 2;
    end
    NBandwidth = params.bandwidth * mul_factor / params.SampleFreq ;
    if ( params.bandwidth_en  == 1 )
        FilterCoef      = ChBandwidthInit(NBandwidth,FilterTapNum, 0);
    else
        FilterCoef      = 1;
    end 
end
