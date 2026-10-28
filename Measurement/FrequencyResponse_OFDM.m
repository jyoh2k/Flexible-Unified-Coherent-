function varargout = FrequencyResponse_OFDM(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FrequencyResponse_OFDM_OpeningFcn, ...
                   'gui_OutputFcn',  @FrequencyResponse_OFDM_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
 


function FrequencyResponse_OFDM_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject; 

[handles.sims, handles.params]=  Default_FFT();
global SW_PATH
handles.sims.freq_filename = [SW_PATH 'FreqResp.mat'];
set( handles.edit1_5, 'String', 'FreqResp.mat'); 

GHz=1e9;
set( handles.edit2_1, 'String', num2str( handles.params.AWGSampleFreq/GHz));
set( handles.edit2_2, 'String', num2str( handles.params.OSCFreq/GHz));
set( handles.edit2_3, 'String', num2str( handles.params.AWGSampleFreq/2/GHz));
handles.prev_AFRvec ='';
handles.AFRvec ='';
guidata(hObject, handles);


 
function varargout = FrequencyResponse_OFDM_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.amp_axes;
varargout{2} = handles;
 
 
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function Plot_Callback(hObject, eventdata, handles)
 


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
 

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
global SW_PATH
[FileName, PathName] = uiputfile([ SW_PATH './Results/Figures/*']);
if ( PathName ~= 0 )
%     saveas(hObject,  [PathName FileName '.fig' ], 'fig');
%     saveas(handles.figure1,  [PathName FileName '.fig' ], 'fig');
    img =getframe(gcf);
%      img =getframe(handles.amp_axes);
    imwrite(img.cdata, [PathName FileName '.png' ]);
end
 
 

 

% --------------------------------------------------------------------
function uitoggletool4_ClickedCallback(hObject, eventdata, handles) 
        hfig=gcbf;
        lmenu = findall(gcbf,'Tag','figMenuInsertLegend');
        ltogg = uigettool(hfig,'Annotation.InsertLegend');
        cax = get(hfig,'CurrentAxes');
        if ~isempty(cax) 
            children = graph2dhelper ('get_legendable_children', cax);
            if ~isempty(children)
                if (~isempty(lmenu) && isequal(lmenu,gcbo) && strcmpi(get(lmenu,'Checked'),'off')) ||...
                        (~isempty(ltogg) && isequal(ltogg,gcbo) && strcmpi(get(ltogg,'State'),'on'))
                    hleg =  legend(cax,'show'); 
                     set(hleg,'Color','k','TextColor','yellow');
                else
                    legend(cax,'off');
                end
            else
                if ~isempty(ltogg)
                    set(ltogg,'State','off');
                    hL = legend(cax);
                    if ~isempty(hL)
                        legend(cax,'off');
                    end
                end
            end
        else
            if ~isempty(ltogg)
                set(ltogg,'State','off');
            end
        end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)


function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)


function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu2_Callback(hObject, eventdata, handles)


function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu3_Callback(hObject, eventdata, handles)


function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton1_Callback(hObject, eventdata, handles)


function popupmenu4_Callback(hObject, eventdata, handles)


function popupmenu4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)


function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)


function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)


function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_1_Callback(hObject, eventdata, handles)


function edit1_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_2_Callback(hObject, eventdata, handles)


function edit1_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_3_Callback(hObject, eventdata, handles)


function edit1_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_4_Callback(hObject, eventdata, handles)

function edit1_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_5_Callback(hObject, eventdata, handles)
[FileName,PathName]  = uiputfile([ '*.*']);
if isequal(FileName,0) || isequal(PathName,0)
    disp2(handles.sims.logfile, 'User clicked Cancel.')
else
    disp2(handles.sims.logfile, ['Loading File ', FileName,' in Path', PathName]);
    handles.sims.freq_filename = [PathName,FileName];
    set( hObject, 'String', FileName); 
end
guidata(hObject, handles);


function edit2_6_Callback(hObject, eventdata, handles)


function edit2_5_Callback(hObject, eventdata, handles)


function edit2_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_4_Callback(hObject, eventdata, handles)


function edit2_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_3_Callback(hObject, eventdata, handles)


function edit2_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text2_2_Callback(hObject, eventdata, handles)


function edit2_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function runbutton_Callback(hObject, eventdata, handles)
handles = update_ParameterSet(hObject, eventdata, handles);
handles = measure_ofdm(hObject, eventdata, handles);
display_measure(hObject, eventdata, handles);
guidata(hObject, handles);




function savebutton_Callback(hObject, eventdata, handles)
Fvec = handles.Fvec;
PFRvec = handles.PFRvec;
AFRvec = handles.AFRvec;
save(handles.sims.freq_filename, 'Fvec', 'PFRvec', 'AFRvec');  
disp2(handles.sims.logfile, ['Saved matfile File ', handles.sims.freq_filename ]); 



function popupmenu11_Callback(hObject, eventdata, handles)


function edit2_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text2_6_Callback(hObject, eventdata, handles)


function handles = update_ParameterSet(hObject, eventdata, handles)
    GHz=1e9;MHz=1e6;
    handles.txsignal  = get_value (handles.edit1_1);
    handles.rxsignal  = get_value (handles.edit1_2);
    handles.params.NLTF  = get_string (handles.edit1_3);
     
    handles.filename  = get(handles.edit1_5, 'String');

    handles.params.AWGSampleFreq  = get_string (handles.edit2_1)*GHz;
    handles.params.OSCFreq  = get_string (handles.edit2_2)*GHz;
    handles.params.BaudFreq  = get_string (handles.edit2_3)*GHz;
    handles.params.TXSampleFreq      = handles.params.BaudFreq ;
    handles.params.RXSampleFreq      = handles.params.BaudFreq ;

    handles.params.NFFT  = 2^(get_value (handles.edit2_4) + 6); 
    handles.debug_mode  = get_value (handles.text2_6);  
    handles.params.dmt_mode    = get_value (handles.text2_7);  
    handles.params.AWG.ResampleMethod = 1; 
%     handles.params.power_sc = 1 * ones(handles.params.NTXStream, size(handles.params.SubcarrierIndex,2)) ;

    [handles.sims, handles.params]=  ReInit_OFDM ( handles.sims, handles.params  );

     
guidata(hObject, handles);
 

function val = get_value(handles1)
val = get(handles1, 'Value');

function val = get_string(handles1)
val = str2num(get(handles1, 'String'));


function handles = measure_ofdm(hObject, eventdata, handles)
 
    params = handles.params;   
    sims = handles.sims;   
    dataf     = DataGen( sims.dataf, params.totalbits, 0 );
    [txout, txsignal] = TxOFDM( dataf, sims, params) ;
    [txout]    = Resample( txout, params.TXSampleFreq, params.AWGSampleFreq);


    if ( handles.debug_mode == 1 )  
        channelin = [txout(end-101:end)  txout txout];
%         [channelout, sims] = Channel( sims, channelin, sims.channel);
%         channelout        = MZMmod   ( channelin,     sims.channel.MZmod ); 
        [channelout]    = Resample( channelin, sims.channel.TXSampleFreq, sims.channel.SampleFreq); 
        channelout = ChBandwidth( channelout,sims.channel.MZmod.FilterCoef, 1);
        [channelout]    = Resample( channelout, sims.channel.SampleFreq, sims.channel.RXSampleFreq); 
        if ( handles.params.dmt_mode == 1 )
            channelout = real(channelout);
        end 

    else      
        [channelout]   = SelTestVector( 0, 1, sims, params ) ;      
    end
  
    [frame] = RxOFDM( channelout, txsignal, sims, params);

    handles.Fvec = [-params.NFFT/2:params.NFFT/2-1] * params.BaudFreq/params.NFFT;
    ce =reshape( frame.ce.H_mean, 1, params.NFFT);
    handles.AFRvec = 1 ./ fftshift(abs(ce) );
    handles.PFRvec = fftshift(angle(ce));
    if ( handles.params.dmt_mode == 1 )
        handles.Fvec = [1:params.NFFT/2-2] * params.BaudFreq/params.NFFT; 
        ce = ce(2:params.NFFT/2-1 );
        handles.AFRvec = 1 ./ (abs(ce) );
        handles.PFRvec = (angle(ce));
    end 
guidata(hObject, handles);

function display_measure(hObject, eventdata, handles)
GHz=1e9;MHz=1e6;
Fvec = handles.Fvec;
PFRvec = (handles.PFRvec);

% convert the amplitude do dB
AFRvec = 20*log10(handles.AFRvec);
plot(handles.amp_axes, Fvec/GHz, AFRvec, 'y', 'LineWidth', 2); 

xlim(handles.amp_axes, [min(Fvec/GHz) max(Fvec/GHz)])
ylim(handles.amp_axes, [min(AFRvec)-10 max(AFRvec)+10])
if ( size(handles.prev_AFRvec,1) ~= 0) 
    prev_AFRvec = 20*log10(handles.prev_AFRvec);
    hold(handles.amp_axes, 'on'); 
    plot(handles.amp_axes, handles.prev_Fvec/GHz, prev_AFRvec, 'y', 'LineWidth', 1) 
end 
hold(handles.amp_axes, 'off');
grid(handles.amp_axes, 'on');
 
xlim(handles.amp_axes, [min(Fvec/GHz) max(Fvec/GHz)]);
ylim(handles.amp_axes, [min(AFRvec)-1 max(AFRvec(find(AFRvec ~= Inf)))+1]);;
xlabel(handles.amp_axes, 'Frequency, GHz')
ylabel(handles.amp_axes, 'Magnitude, dB')
title(handles.amp_axes, 'Frequency response (gain)');
default_color(handles.amp_axes);
  
if ( handles.params.dmt_mode == 0 )
    plot(handles.phase_axes, Fvec/GHz, PFRvec, 'y', 'LineWidth', 2); 
    grid(handles.phase_axes, 'on');
    xlim(handles.phase_axes, [min(Fvec/GHz) max(Fvec/GHz)])
    ylim(handles.phase_axes, [min(PFRvec)-1 max(PFRvec)+1]) 
    xlabel(handles.phase_axes, 'Frequency, GHz')
    ylabel(handles.phase_axes, 'Phase, \circ')
    title(handles.phase_axes,  'Frequency response (phase)');
    default_color(handles.phase_axes);
end 



function edit2_1_Callback(hObject, eventdata, handles)


function    [txout, txsignal] = TxOFDM( dataf, sims, params) 
        dataf   = [];
        mapper   = [];
        mapper3   = [];
        mapper2   = [];
        pilotout      = AddPilotSymbol( mapper3, params.pilot );
        ltfout        = AddLTF( pilotout, params.ltf );
        ifftout       = IFFTnAddGI(ltfout, params.ifft );
        txframe       = AddTrainingSymbol ( ifftout,  params, []);
        txout         = txframe;
        txout_awg = txout;

    %%
    txsignal.dataf = dataf;
    txsignal.fecout = dataf;
    txsignal.mapper2 = mapper2;
    txsignal.mapper3 = mapper3;
    txsignal.mapper  = mapper ;
    txsignal.txframe  = txframe ;
    txsignal.txout        = txout ;
    txsignal.sync_pattern =  params.sync_pattern;



function [frame] =  RxOFDM( in, txsignal, sims, params);
    [in_rx]     = RateConversion( in, params.OSCFreq, params.RXSampleFreq );
    [in_agc, agcgain]             = AGC( in_rx, params.AGC);

    [in_sync, frame.fscs ]        = SearchFrameStart_OFDM( in_agc, params.searchframe,'');

    [cfo_recovered, frame.cfrout] = RxCFR( in_sync, params.cfr, '');
    params.searchfineframe.sync_pattern = txsignal.txframe(1,144+(1:300));
    [cfo_sync, frame.fsfs ]       = SearchFineFrameStart_Tr( cfo_recovered, ...
                                               params.searchfineframe, '' );

   [fcfo_sync, frame.fcfrout] = RxCFR( cfo_sync, params.fcfr, '');
    [fft_out    ]                 = FFTnRemoveGI( fcfo_sync, params.fft);

    params.ce.SubcarrierIndex = [1:params.NFFT];
    [data_out, H, frame.ce]       = ChannelEst ( fft_out,  params.ce);

function [ out, fscs ] = SearchFrameStart_OFDM( in, params, sims )

% if ( params.cfr.CFEtype  == 1 )
%     out = in ;
%     fscs.start_of_frame = 1;
%     return;
% end;
    fscs.start_of_frame = params.start_of_frame;
    fscs.MaxPos         = params.MaxPos;
    fscs.metric         = zeros(1, 1000);
    fscs.phaseoffset    = 0 ;
    out = in (:, 1+size(fscs.start_of_frame,2):end);

    if ( params.en  == 0 )
        return;
    end


if ( size(params.frame_header,1) ~= 0  )
    cor_pattern         = ones(size(in,1),1)*params.frame_header  ;
    search_range        = floor(params.frame_length * 1.3);
    k2                  = 1: size(cor_pattern,2);
    in1                 = in(:, 1:params.RXoversample:end);

    [P2, R2, Msym]      = CrossCorr( in1(:,1:search_range), cor_pattern, 1, k2  );
    Msym =  (abs( P2 ) .^2) ;
    [MaxVal, MaxPos]    = max(Msym);
    start_of_frame      = (MaxPos - 1+ length(cor_pattern)) * params.RXoversample  + 1 - 5 ; % Margin
    out                 = in(:, start_of_frame:end);

    fscs.start_of_frame = start_of_frame;
    fscs.MaxPos         = MaxPos ;
    fscs.metric         = Msym;
    return;
end 
if ( params.CFEtype  == 1 )
        cor_pattern =  reshape([(params.sync_pattern(1:100));  zeros(1,100 );], 1, []);
        cor_pattern  = TxUpsample( params.sync_pattern(:, 1:70), params.RXoversample, 0 );
        search_range = floor(params.ptn_rep_length * params.RXoversample   )  +15;   
        endidx = min(size(in,2),search_range);
        search_range1 = params.search_offset;
        fscs.phaseoffset =0 ;
%         search_range1 = 400;     
        search_idx = 1;
        k2 = 1: length(cor_pattern);
        [P2, R2, Msym] = CrossCorr2D( in(:,search_range1:1:endidx), cor_pattern, search_idx, k2  );         
        [MaxVal, MaxPos] = max(Msym);
        start_of_frame = ( MaxPos - 1 + params.offset ) * 1  + search_range1;
        out = in (:, start_of_frame:end);
        fscs.start_of_frame = start_of_frame+1;
        fscs.MaxPos = MaxPos  ;
        fscs.metric   = Msym;
    return;
end

if ( params.CFEtype  == 5 )
    CorLen     = size(params.sync_pattern,2)  ;
    Interval   = CorLen;
    search_idx = 1; search_end = min(round(params.frame_length*params.RXoversample)+100, size(in,2));
    [P1, R1, Msym, R2] = AutoCorr( in(:,1:params.RXoversample:search_end) ,search_idx, CorLen, Interval  );
    [MaxVal, MaxPos] = max(Msym);
    if (  params.th  > 0 )
        idx0 =find(Msym > params.th);
        search_end = idx0(1) + params.range  + 2*CorLen + Interval;
        [P1, R1, Msym1, R2] = AutoCorr( in(:,1:params.RXoversample:search_end) ,search_idx, CorLen, Interval  );
        [MaxVal, MaxPos] = max(Msym1);
    end 
    
    start_of_frame = ( MaxPos - 1 ) * params.RXoversample + 1;
    out = in ( :,start_of_frame:end);
    fscs.start_of_frame = MaxPos;
    fscs.MaxPos         = MaxPos ;
    fscs.metric = Msym;
    return;
end
    

function [sims, params]=  ReInit_OFDM ( sims, params  )
    
    global SW_PATH
    run( [ 'Units.m']);
    
    %% simulation 
    sims.Ylabel = sims.plot_str{sims.plot_mode};
    
    
    %% pattern
    file_length  = length(importdata( sims.dataf.data_file ));
    ptn_length   = lcm( file_length, params.Nbpsc)/ params.Nbpsc;
    params.ptn_rep_length    = ptn_length;
            
 
    
    %%  DSP
    
    params.mapper            = reinit_mapper( params.mapper,  params );
    params = get_STF( params );
    params = get_LTF( params );
    
    params.power_sc  =  ones(params.NTXStream, params.NFFT) ;
    params.TXoversample      = params.TXSampleFreq /  params.BaudFreq;
    params.RXoversample      = params.RXSampleFreq /  params.BaudFreq;
    params.ADCSampleFreq     = params.RXSampleFreq; 
    if ( params.ps.en == 1 )
        params.GrayMap = 0;
    end
    
    params                   = get_frame_length(params);
    params.mapper_list         = QAMMapper2List (  params.mapper) ;
    params.pilot   = reinit_pilot(params.pilot, params);
    params.ltf     = reinit_ltf  (params);
    params.ifft    = reinit_ifft  (params);
    params.spmpre  = reinit_spmpre( params.spmpre,  params, sims );
    params.fec = reinit_fec( params.fec, params );
    params.ps = reinit_ps( params.ps, params );
    
    params.fft    = reinit_fft  (params);
    params.ce     = reinit_ce  (params.ce, params);
    params.tpr    = reinit_tpr  (params.tpr, params);
    params.cpr    = reinit_cpr  (params.cpr, params);
    params.rxskew            = reinit_rxskew( params.rxskew,  params );
    params.demap             = reinit_demapper( params.demap,  params );
     
    params.awglpf.AWGSampleFreq        = params.AWGSampleFreq; 
    params.searchframe = reinit_searchframe( params.searchframe, params );
    params.searchfineframe = reinit_searchfineframe( params.searchfineframe, params );
    params.cfr = reinit_cfr( params.cfr, params);
    params.fcfr = reinit_fcfr( params.fcfr, params);
    
    %%  Channel
    sims.channel.TXSampleFreq =  params.AWGSampleFreq;
    sims.channel.RXSampleFreq =  params.OSCFreq;
    
    if ( params.NTXStream == 1 )
        sims.channel.Npol = 1 ;
    end
    
    sims.channel = get_channel_parameter( sims.channel );
    sims.channel.CarrierFreqOff_norm  = sims.channel.CarrierFreqOff / sims.channel.SampleFreq;
    
    
    %Bandwidth 
    sims.channel.TXDAC             = reinit_DAC(sims.channel.TXDAC, params);
    sims.channel.RFDriver          = reinit_BW (sims.channel.RFDriver);
    sims.channel.MZmod             = reinit_BW (sims.channel.MZmod);
    sims.channel.PD                = reinit_PD( sims.channel.PD );
    sims.channel.RXADC             = reinit_BW (sims.channel.RXADC);
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


%% ------------------------------------------  
function channelout = get_channel_coef ( channelin, gains)


    filtertap       =  channelin.multifading.filtertap;
    filtertaph      = (filtertap-1)/2;
    delays          = channelin.multifading.delays * channelin.SampleFreq;

    sample_delay    = floor(delays + 0.5) ;
    timing_delay_frac        = delays - sample_delay;
    filtercoef      = zeros(length(delays),  filtertap);
    for idx=1:length(delays)
        filtercoef(idx, :) = gains(idx) * sinc(timing_delay_frac (idx) - (-filtertaph : 1: filtertaph));
    end
    channelout = channelin;
    channelout.multifading.filtercoef = filtercoef;
    channelout.multifading.sample_delay = sample_delay;
    channelout.multifading.gains = gains;



function params = get_frame_length(params)
    rate = 1;
    params.totalbits        = params.NTXStream * params.NDataSymbol * ...
                              params.Nsd * params.Nbpsc;
    params.databits  = params.totalbits;
    params.NSamplepersymbol= params.NFFT*(1+params.CP_ratio);
    params.NLTFSymbol      = params.NTXStream * params.NLTF ;
    params.NLTFSample      = params.NLTFSymbol * params.NSamplepersymbol ;
    params.NFrameSample    = params.NSTFSample + params.NLTFSample + ...
                             params.NDataSymbol * params.NSamplepersymbol ;
    params.NDataSample     = params.NDataSymbol * params.NSamplepersymbol ;
    params.NSymbol         = params.NDataSymbol + params.NLTFSymbol ;


function [Matchedfilter]= reinit_txmatched_filter(Matchedfilter, params)
    Matchedfilter.p           = Matchedfilter.sps /params.TXoversample;
    Matchedfilter.q           = Matchedfilter.p ;
    os_factor = 2;
    Matchedfilter.time_resp =  SRRC( os_factor,Matchedfilter.alpha, Matchedfilter.resp_sample);


function [Matchedfilter]= reinit_rxmatched_filter(Matchedfilter, params)
    Matchedfilter.p           = Matchedfilter.sps /params.RXoversample;
    Matchedfilter.q           = Matchedfilter.p ;
    os_factor = 2;
    Matchedfilter.time_resp =  SRRC( os_factor,Matchedfilter.alpha, Matchedfilter.resp_sample);


function cfr = reinit_cfr( cfr, params);
    cfr.OV            = params.RXoversample;
    cfr.sync_pattern  = params.STF;
    cfr.exp_phasediff = params.cfr.CarrierFreqOff  / ( params.RXSampleFreq ) * 2 * pi;

function fcfr = reinit_fcfr( fcfr, params);
    fcfr.OV           = params.RXoversample;
    fcfr.CFEtype      = 2;
    fcfr.sync_pattern = zeros(1, params.NTXStream * params.NSamplepersymbol);
    if ( params.NLTF == 1 )
        fcfr.en       = 0;
    end

 
function pilot  = reinit_pilot( pilot, params )
    pilot.pilot_index = params.PilotIndex;
    pilot.pilot_symbol = params.PilotSym;
    pilot.block_size_in   = params.Nsd ;
    pilot.block_size_out  = params.Nsd + length(pilot.pilot_index);
    pilot.block_size_in   = params.NFFT;
    pilot.block_size_out  = params.NFFT;
    pilot.rate         =  pilot.block_size_out/(pilot.block_size_in);

function ltf  = reinit_ltf(  params )
    LTF = params.LTF ;
    %LTF = sqrt(1/sum(params.LTF .* params.LTF)) * params.LTF;
    if ( params.NTXStream == 2 )
        if (  params.LTF_type == 1 ) 
             LTF = [LTF LTF;  ...
                        LTF  -LTF;];
        end 
    end
    if ( params.NTXStream == 1 )
         LTF = LTF; 
    end
    ltf.SubcarrierIndex1 = params.SubcarrierIndex1;
    ltf.SubcarrierIndex2 = params.SubcarrierIndex2;
    ltf.LTF = repmat(LTF, 1, params.NLTF);

function ifft    = reinit_ifft  (params)
    NCP = params.NFFT * params.CP_ratio;
    ifft.NSamplepersymbol = params.NSamplepersymbol;
    ifft.NFFT    = params.NFFT;
    ifft.CPindex = [(params.NFFT -NCP+1):params.NFFT 1:params.NFFT];
    ifft.power_sc = params.power_sc;
    ifft.SubcarrierIndex = params.SubcarrierIndex;


function fft    = reinit_fft  (params)
    NCP = params.NFFT * params.CP_ratio;
    fft.NSamplepersymbol = params.NSamplepersymbol; 
    fft.NSymbol  = params.NSymbol; 
    fft.NFFT    = params.NFFT;
    syncpoint = floor(params.NFFT * params.CP_ratio /2);
    syncpoint = 0;
    fft.index = [(params.NFFT*params.CP_ratio -syncpoint)+(1:params.NFFT)];
    fft.syncpoint = syncpoint;

function ce     = reinit_ce  (ce, params)
    ce.SubcarrierIndex = params.SubcarrierIndex ;
    ce.SubcarrierIndex1 = params.SubcarrierIndex1;
    ce.SubcarrierIndex2 = params.SubcarrierIndex2;
    ce.NFFT  = params.NFFT ;
    ce.LTF   = params.LTF ;
    ce.syncpoint   = params.fft.syncpoint ;
    ce.NTXStream   = params.NTXStream ;
    ce.NLTF        = params.NLTF ;
    ce.NLTFSample   = params.NTXStream * params.NFFT;
    ce.NTXStream    = params.NTXStream ;
    ce.PRL       = params.NFFT;

function tpr    = reinit_tpr (tpr, params)
   tpr.PRL = params.NFFT;
   tpr.NFFT = params.NFFT;

function cpr    = reinit_cpr (cpr, params)
   cpr.PRL = params.NFFT;
   cpr.BLK = params.NFFT;

function sync = reinit_searchframe( sync, params )
    sync.sync_pattern   = params.STF;
    sync.offset         = 7;
    sync.NFrameSymbol   = params.NFrameSample * params.RXoversample;
    sync.CFEtype        = params.cfr.CFEtype;
    sync.ptn_rep_length = params.ptn_rep_length;
    sync.RXoversample   = params.RXoversample;
 %  sync.frame_header   = params.STF;
    sync.frame_length   = params.NFrameSample;

function finesync = reinit_searchfineframe( finesync, params )
    finesync.sync_pattern   = params.STF;
    finesync.NFrameSymbol   = params.NDataSample + params.NLTFSample;
    finesync.offset         =  0;
    finesync.offset         =  finesync.offset  + size(params.sync_pattern,2);
    finesync.CFEtype        = params.cfr.CFEtype;
    finesync.ptn_rep_length = params.ptn_rep_length;
    finesync.RXoversample   = params.RXoversample;


function ps = reinit_ps( ps, params )
    pas_bit    = params.Nbpsc /params.QAM_factor - 1;
    ps.QAM_factor            = params.QAM_factor ;
    
    level      = 2^(pas_bit );
    code_size  = params.fec.n/(pas_bit + 1)  ; %symbol
    num_dm_block_per_fec = 1;
    if ( params.QAM_factor == 2 )
        B_level = sqrt(length(params.mapper_list));
        mapper_list =real(params.mapper_list(1:B_level:end));
    else
        mapper_list =real(params.mapper_list(1:end));
    end
    ps.mapper_list = reshape( mapper_list, 1, length(mapper_list));
    ps.Nbpsc = params.Nbpsc;
    
    if ( ps.en == 0 )
        ps.k = params.fec.k ;
        ps.n = params.fec.k ;
        ps.signbit = 0 ;
        ps.entropy       = params.Nbpsc /params.QAM_factor;
        type_seq = ones(1, 2^(params.Nbpsc/params.QAM_factor));
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

function mapper = reinit_mapper( mapper, params  )
    mapper.Nbitspersymbol = params.Nbpsc;



function [skew]=  reinit_rxskew( skew, params  )
    if ( skew.en == 2 )
        ps  = 1e-12;
        skew_ps(1) = 0+1j*ps;
        skew.sft(1,1) = skew_ps(1)  *  params.RXSampleFreq;
    end


function demap = reinit_demapper( demap, params  )
    % demap.type : 1: Hard decision, 2: , 3: Bit-metric decoding 
    if ( params.QAM_factor == 2 )
        demap.B_level = sqrt(length(params.mapper_list));
        mapper_list = real(params.mapper_list(1:demap.B_level:end));
    else
        demap.B_level = (length(params.mapper_list));
        mapper_list = params.mapper_list;
    end
    demap.mapper_list = reshape( mapper_list, 1, length(mapper_list));
    demap.type_seq = params.ps.type_seq;
    demap.Nbitspersymbol = params.Nbpsc;
    demap.QAM_factor = params.QAM_factor;
    demap.GrayMap    = params.GrayMap;
    demap.big_end_map= params.big_end_map;

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
    %– RS(544, 514, 15) over GF(210) – 100GBASE-KP4
    %– RS(528, 514, 7) over GF(210) – 100GBASE-KR4
    if ( fec1.FEC_mode  == 4 ) % RS , KP4
        fec.N=544;
        fec.K=514;
        fec.M=10;
        S = fec.K - fec.S;
        fec.k=fec.M * (fec.K -S);
        fec.n=fec.M * (fec.N -S);
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

function DAC = reinit_DAC( DAC, params)
%   DAC.SampleFreq = params.TXSampleFreq;  
    DAC.FilterCoef = get_bandwidth_coef (1, DAC);

function dev = reinit_BW( dev)
    dev.FilterCoef = get_bandwidth_coef (1, dev);

function PD  = reinit_PD( PD )
    mV = 1e-3;
    PD.FilterTapNum =5 ;
    PD.max_output_power= 10^(PD.max_output_power_dBm/10)*mV ;
    PD.max_current     = sqrt(PD.max_output_power /PD.resistor); % RF power = R*I^2 ;
    PD.FilterCoef = get_bandwidth_coef (0, PD);

function FilterCoef = get_bandwidth_coef (baseband, params)
    FilterTapNum  =7;
    mul_factor = 1;
    if ( baseband == 1 )
        mul_factor = 2;
    end
    NBandwidth = params.bandwidth * mul_factor / params.SampleFreq ;
    FilterCoef      = ChBandwidthInit(NBandwidth,FilterTapNum, 1);



function params = get_LTF( params )
    if ( params.NFFT == 2048 )
        MaxIdx =   1023 ;
        SubcarrierIndex1 = [1:MaxIdx] ;             
            PilotIndex1 = [  128   256   448   640   768   960 ] ;   
            PilotSym = [ -1 -1 1 1 1 -1 1 1 -1 -1 -1 1 ];        
         
        
        LTF_2048 = [	 ...
              1,-1, 1,-1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1 ,...
            1,-1, 1, 1,-1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1, 1, 1, 1,-1,-1,-1,-1,-1,-1,-1, 1,-1 ,...
            1,-1,-1,-1, 1,-1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1,-1,-1,-1,-1, 1,-1,-1 ,...
            1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1,-1,-1, 1, 1 ,...
            -1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1,-1,-1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1,-1 ,...
            -1,-1, 1, 1, 1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1, 1,-1,-1, 1,-1,-1, 1,-1,-1, 1, 1,-1, 1, 1,-1 ,...
            -1,-1, 1, 1, 1, 1,-1, 1, 1, 1, 1, 1, 1, 1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1, 1, 1, 1, 1,-1,-1,-1,-1 ,...
            1,-1,-1, 1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1, 1,-1 ,...
            1, 1, 1, 1, 1,-1,-1,-1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1,-1, 1,-1,-1, 1,-1,-1, 1,-1,-1, 1,-1 ,...
            -1, 1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1, 1, 1,-1, 1,-1,-1,-1,-1,-1,-1, 1, 1,-1,-1,-1,-1, 1, 1 ,...
            -1,-1, 1, 1,-1, 1,-1,-1, 1,-1,-1, 1,-1, 1,-1,-1, 1,-1,-1,-1,-1, 1, 1, 1, 1, 1, 1, 1, 1,-1,-1,-1 ,...
            1,-1,-1,-1,-1, 1, 1, 1, 1, 1,-1,-1, 1, 1, 1, 1, 1,-1,-1, 1,-1, 1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1 ,...
            -1, 1, 1,-1,-1,-1,-1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1,-1,-1, 1,-1, 1, 1,-1, 1, 1,-1,-1, 1,-1,-1 ,...
            -1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1,-1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1, 1, 1,-1,-1,-1,-1,-1, 1,-1 ,...
            -1,-1,-1,-1,-1,-1, 1,-1,-1,-1, 1, 1, 1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1,-1,-1,-1,-1, 1,-1,-1,-1 ,...
            1,-1, 1, 1, 1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1, 1 ,...
            1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1,-1,-1, 1,-1, 1,-1,-1, 1, 1, 1,-1,-1,-1, 1,-1, 1, 1, 1 ,...
            -1, 1,-1, 1,-1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1,-1, 1 ,...
            -1, 1, 1, 1,-1, 1, 1, 1,-1,-1,-1,-1, 1, 1, 1,-1, 1,-1, 1,-1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1 ,...
            -1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1,-1,-1, 1, 1, 1,-1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1, 1, 1,-1, 1 ,...
            -1, 1, 1, 1, 1, 1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1, 1,-1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1 ,...
            -1,-1, 1,-1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1, 1, 1, 1, 1, 1, 1,-1,-1,-1, 1,-1, 1,-1,-1, 1,-1,-1, 1 ,...
            1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1,-1,-1, 1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1 ,...
            -1,-1,-1,-1,-1,-1, 1,-1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1, 1, 1, 1 ,...
            1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1 ,...
            -1, 1, 1, 1, 1,-1,-1,-1, 1, 1, 1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1,-1 ,...
            1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1,-1,-1 ,...
            -1, 1,-1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1,-1, 1, 1, 1, 1, 1,-1,-1,-1, 1 ,...
            -1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1,-1,-1, 1,-1,-1 ,...
            1,-1,-1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,-1,-1,-1,-1,-1, 1, 1,-1,-1, 1,-1,-1,-1, 1,-1, 1,-1, 1 ,...
            1,-1,-1,-1,-1,-1, 1, 1,-1, 1,-1,-1,-1, 1, 1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1,-1, 1, 1,-1, 1 ,...
            -1, 1,-1, 1, 1,-1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1, 1, 1,-1,-1,-1,-1, 1 ,...
            1, 1,-1, 1, 1,-1, 1, 1, 1,-1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1, 1, 1,-1 ,...
            -1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1, 1, 1,-1 ,...
            -1,-1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,-1, 1,-1, 1, 1, 1,-1,-1,-1, 1,-1, 1,-1,-1,-1,-1,-1,-1,-1, 1 ,...
            -1, 1, 1,-1, 1, 1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1 ,...
            1, 1,-1,-1, 1, 1,-1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1, 1, 1, 1,-1, 1, 1,-1, 1, 1, 1,-1,-1,-1 ,...
            1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1, 1, 1, 1,-1, 1,-1,-1,-1 ,...
            -1, 1,-1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1,-1,-1,-1, 1, 1,-1,-1,-1, 1 ,...
            1, 1,-1,-1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1,-1,-1,-1,-1,-1, 1,-1,-1,-1,-1 ,...
            -1,-1, 1,-1,-1, 1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1, 1, 1, 1,-1, 1, 1 ,...
            1,-1, 1,-1,-1, 1, 1,-1,-1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1, 1, 1, 1,-1,-1, 1, 1,-1, 1 ,...
            1, 1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1,-1, 1,-1,-1, 1,-1,-1,-1,-1, 1,-1,-1, 1,-1, 1, 1, 1,-1,-1, 1 ,...
            1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1 ,...
            -1, 1, 1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1, 1,-1, 1, 1 ,...
            1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1, 1,-1, 1, 1, 1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1,-1,-1,-1,-1, 1 ,...
            1, 1,-1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1 ,...
            -1,-1,-1,-1,-1,-1, 1,-1,-1,-1, 1,-1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1,-1 ,...
            1,-1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1, 1, 1, 1, 1,-1, 1, 1, 1,-1,-1,-1,-1,-1,-1,-1 ,...
            -1, 1, 1, 1,-1,-1,-1,-1,-1,-1, 1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1,-1, 1,-1,-1, 1,-1,-1,-1, 1, 1, 1 ,...
            1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1 ,...
            1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1,-1,-1, 1, 1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1 ,...
            1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1, 1, 1, 1 ,...
            -1, 1, 1,-1, 1,-1, 1, 1,-1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1,-1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1 ,...
            1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1,-1, 1,-1,-1,-1,-1 ,...
            -1, 1, 1,-1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1,-1, 1,-1 ,...
            1, 1,-1,-1,-1, 1, 1, 1,-1,-1,-1, 1, 1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1, 1,-1,-1,-1, 1,-1,-1,-1,-1 ,...
            1, 1, 1,-1, 1, 1, 1, 1,-1,-1,-1,-1, 1,-1,-1, 1,-1,-1,-1,-1,-1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1, 1 ,...
            1, 1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1,-1, 1 ,...
            -1,-1, 1, 1,-1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1,-1 ,...
            1, 1,-1,-1, 1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 1, 1, 1,-1, 1, 1,-1, 1, 1, 1, 1, 1, 1,-1,-1, 1,-1, 1 ,...
            -1, 1, 1, 1,-1, 1, 1,-1,-1,-1, 1, 1, 1,-1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1,-1, 1, 1, 1, 1,-1, 1, 1 ,...
            -1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1 ,...
            -1,-1, 1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1, 1 ...
     ];
    
        LTF  =  [ LTF_2048 ];
    end 
    if ( params.NFFT == 1024 )
        MaxIdx =  511 ;        
            SubcarrierIndex1 = [1:MaxIdx] ;
            PilotIndex1 = [  64   128   224   320   384 ];   
            PilotSym = [ -1  1 1 1 -1 -1 -1 1 1  -1 ];
       
        
        PilotIndex2 = sort(-PilotIndex1); 
        LTF_1024 = [	 ...
      1   -1   1   1   1   1  -1   1   1  -1   1  -1   1   1   1   1 ...
       1   1   1   1   1   1   1   1   1   1   1  -1   1   1   1  -1 ...
      -1  -1   1  -1  -1  -1  -1   1  -1   1   1  -1   1   1   1   1 ...
       1   1   1   1   1   1   1   1   1   1  -1   1  -1  -1  -1   1 ...
       1  -1  -1   1  -1  -1  -1   1   1   1  -1   1   1  -1   1  -1 ...
       1  -1  -1   1   1  -1   1  -1   1   1  -1   1  -1  -1   1   1 ...
       1  -1  -1   1  -1  -1  -1   1  -1   1   1  -1  -1  -1   1   1 ...
      -1  -1  -1  -1   1   1   1   1   1   1  -1  -1   1   1   1  -1 ...
      -1   1  -1   1  -1   1  -1  -1  -1  -1   1  -1   1  -1  -1   1 ...
       1   1   1  -1   1  -1  -1   1  -1  -1   1  -1  -1  -1   1  -1 ...
      -1   1  -1   1  -1  -1  -1  -1  -1   1   1  -1  -1   1  -1   1 ...
      -1  -1  -1  -1   1   1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ...
      -1   1  -1   1  -1  -1   1  -1   1  -1   1   1  -1   1  -1  -1 ...
      -1  -1  -1   1  -1  -1   1   1   1   1   1   1   1   1  -1  -1 ...
       1  -1   1   1  -1  -1  -1   1  -1  -1  -1   1  -1   1  -1  -1 ...
       1   1   1   1  -1   1  -1  -1  -1  -1  -1   1  -1   1   1  -1 ...
      -1  -1   1   1  -1   1   1  -1   1  -1   1   1   1   1   1   1 ...
       1  -1  -1   1  -1   1  -1  -1  -1   1   1  -1  -1   1   1  -1 ...
      -1   1   1  -1   1  -1   1   1   1  -1  -1   1   1  -1  -1   1 ...
       1   1  -1  -1   1   1   1   1   1   1   1  -1  -1   1  -1  -1 ...
       1  -1   1  -1   1  -1   1  -1  -1   1   1  -1  -1   1  -1   1 ...
       1   1   1   1   1   1   1   1  -1   1   1   1  -1   1   1   1 ...
       1  -1   1  -1  -1  -1  -1   1   1   1   1  -1   1  -1  -1   1 ...
      -1  -1   1   1  -1   1   1  -1  -1  -1   1  -1   1   1  -1   1 ...
       1   1   1  -1   1   1   1  -1   1   1  -1  -1  -1  -1  -1  -1 ...
      -1  -1  -1  -1  -1  -1  -1   1   1   1   1   1   1   1  -1   1 ...
       1  -1  -1   1  -1   1  -1  -1   1   1  -1  -1   1  -1  -1   1 ...
      -1  -1  -1  -1  -1   1  -1  -1  -1   1   1   1   1   1  -1   1 ...
       1   1  -1  -1  -1  -1  -1  -1  -1  -1   1  -1  -1   1  -1   1 ...
       1   1   1   1  -1   1  -1  -1   1  -1  -1   1   1   1  -1   1 ...
       1   1   1   1  -1   1  -1  -1   1  -1   1  -1  -1   1   1   1 ...
      -1   1   1   1  -1   1   1   1  -1   1  -1  -1   1   1   1  -1 ...
       1  -1   1  -1   1   1   1   1  -1  -1   1  -1   1  -1  -1  -1 ...
       1   1  -1  -1   1   1  -1   1  -1  -1  -1  -1  -1  -1   1  -1 ...
       1  -1   1  -1  -1   1   1  -1  -1  -1  -1   1  -1  -1   1  -1 ...
       1   1  -1   1  -1  -1   1   1   1  -1  -1  -1   1  -1  -1  -1 ...
       1  -1  -1  -1   1   1   1  -1   1  -1  -1  -1   1   1  -1   1 ...
      -1   1   1  -1   1  -1   1  -1  -1  -1  -1   1  -1   1   1  -1 ...
       1   1   1  -1  -1  -1  -1  -1   1   1  -1  -1   1   1   1   1 ...
      -1  -1   1   1   1   1   1  -1  -1   1   1  -1   1  -1  -1   1 ...
       1   1   1  -1  -1   1   1  -1  -1  -1  -1  -1  -1   1   1  -1 ...
       1   1   1   1   1  -1  -1   1  -1  -1   1  -1   1   1   1   1 ...
       1   1  -1  -1  -1  -1  -1  -1  -1   1   1   1   1   1   1  -1 ...
      -1  -1  -1   1   1   1  -1   1   1  -1   1   1   1   1   1   1 ...
       1  -1   1  -1  -1   1  -1   1  -1  -1   1   1   1   1   1  -1 ...
      -1  -1  -1   1  -1   1  -1  -1   1   1  -1  -1   1   1   1   1 ...
       1   1   1   1   1  -1   1  -1  -1  -1  -1  -1  -1   1   1   1 ...
       1  -1  -1   1  -1   1  -1  -1  -1  -1   1  -1   1  -1   1  -1 ...
       1  -1  -1   1  -1   1   1   1   1  -1  -1  -1  -1   1  -1  -1 ...
       1  -1   1  -1   1  -1  -1   1   1  -1   1  -1   1   1   1  -1 ...
       1  -1  -1   1  -1   1   1   1   1   1  -1   1  -1  -1   1   1 ...
      -1   1  -1  -1   1   1  -1   1  -1   1  -1  -1   1  -1   1  -1 ...
       1   1   1  -1  -1  -1  -1  -1   1   1  -1   1   1   1   1   1 ...
       1  -1   1  -1  -1   1   1  -1   1  -1  -1   1  -1  -1  -1   1 ...
       1  -1  -1  -1   1  -1  -1   1  -1  -1   1   1   1  -1   1   1 ...
       1   1   1   1   1   1  -1   1  -1  -1   1   1  -1  -1  -1   1 ...
      -1  -1  -1  -1   1  -1   1   1   1  -1   1   1   1  -1   1   1 ...
      -1   1  -1   1   1  -1   1  -1  -1   1   1   1   1  -1  -1  -1 ...
       1  -1  -1  -1   1  -1   1  -1   1  -1   1   1   1  -1  -1   1 ...
      -1  -1  -1  -1   1  -1   1   1  -1   1  -1   1  -1  -1   1  -1 ...
      -1   1  -1   1  -1  -1  -1   1  -1   1  -1  -1  -1  -1   1  -1 ...
       1  -1   1   1  -1  -1   1   1   1   1   1   1  -1  -1   1  -1 ...
       1   1  -1   1  -1  -1  -1  -1  -1  -1   1   1  -1  -1  -1   1 ...
      -1  -1  -1   1  -1  -1   1   1   1   1   1   1  -1   1  1 -1  ...
     ];
    
        LTF  =  [  LTF_1024];
    end 
    if ( params.NFFT == 512 )
        MaxIdx =  255;     
        SubcarrierIndex1 = [1:MaxIdx] ;
        PilotIndex1 = [  32   64  112   160   192    ];   
        PilotSym = [ -1  1 1 1 -1 -1 -1 1 1  -1 ]; 
        
        PilotIndex2 = sort(-PilotIndex1); 
        LTF_512 = [	 ...
              1  -1  1 -1  1 -1 -1 -1  1 -1 -1  1  1 -1  1 -1 ...
             -1  1 -1  1  1  1  1  1  1  1  1 -1 -1  1  1  1 ...
             -1  1  1  1  1 -1  1 -1 -1 -1 -1  1  1 -1 -1 -1 ...
              1 -1 -1  1 -1 -1  1 -1  1 -1 -1 -1  1  1  1  1 ...
              1 -1 -1  1  1 -1 -1  1 -1  1 -1 -1  1  1  1  1 ...
             -1  1 -1  1  1  1 -1  1  1  1 -1 -1 -1 -1 -1 -1 ...
              1  1  1  1  1  1 -1 -1  1 -1  1  1 -1 -1  1 -1 ...
             -1  1  1 -1 -1 -1 -1 -1  1  1  1 -1  1 -1 -1  1 ...
             -1  1 -1  1 -1  1  1 -1 -1 -1  1  1  1  1  1  1 ...
              1  1  1  1  1 -1  1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
              1 -1 -1  1 -1  1  1  1 -1 -1 -1  1 -1 -1  1 -1 ...
              1  1 -1 -1  1 -1 -1  1  1  1  1 -1 -1 -1 -1 -1 ...
             -1  1 -1 -1 -1  1  1  1  1  1 -1  1  1  1  1  1 ...
              1  1  1  1  1  1 -1  1  1 -1  1 -1  1 -1  1 -1 ...
              1  1 -1 -1  1  1  1 -1  1  1 -1  1 -1 -1  1  1 ...
             -1 -1 -1  1 -1 -1  1 -1  1  1 -1  -1  1  -1  1  1 ...
              -1  -1  -1 1  1 1 -1 -1 -1 -1 -1 -1  1  1  1  1 ...
              1 -1  1  1 -1 -1  1  1  1 -1  1 -1  1 -1 -1 -1 ...
             -1 -1  1 -1 -1 -1 -1  1  1  1  1  1 -1 -1  1 -1 ...
              1 -1 -1 -1 -1  1  1 -1 -1  1 -1 -1 -1 -1 -1  1 ...
              1 -1 -1 -1  1 -1 -1  1 -1  1  1 -1  1  1 -1 -1 ...
             -1 -1  1 -1 -1  1  1  1 -1 -1  1 -1 -1  1 -1 -1 ...
             -1  1 -1  1  1 -1  1  1 -1  1 -1  1  1  1 -1 -1 ...
             -1  1 -1  1  1 -1 -1  1 -1 -1  1  1 -1 -1  1  1 ...
             -1  1 -1  1  1  1  1  1  1  1 -1  1  1 -1 -1  1 ...
              1  1  1  1  1 -1  1  1 -1 -1 -1 -1  1  1 -1 -1 ...
              1 -1 -1  1  1 -1 -1  1  1  1 -1  1 -1 -1 -1 -1 ...
             -1 -1  1 -1 -1  1  1 -1 -1 -1  1  1  1  1  1  1 ...
             -1 -1 -1  1 -1  1 -1 -1  1  1 -1 -1 -1  1  1 -1 ...
              1 -1  1  1 -1 -1  1  1 -1 -1  1 -1 -1  1  1 -1 ...
             -1 -1 -1  1  1 -1 -1  1  1  1 -1 -1 -1 -1  1  1 ...
             -1  1 -1  1  1  1 -1  1  1  1 -1  1  1 -1  1 1 ...
     ];
    
    
        LTF  =  LTF_512;
    end 
    if (params.NFFT == 256 ) 
        MaxIdx = 127; 
        SubcarrierIndex1 = [ 1:MaxIdx];
        PilotIndex1 = [ 12 36 60 84 ];      
        PilotSym = [-1 1 -1 1 1 -1 -1 1];
        
          LTF_256 = [ ...
              1, -1,  1, -1, -1, -1,  1,  1, -1,  1, -1,  1, -1,  1,  1, -1, ...
              1, -1, -1, -1,  1,  1, -1, -1,  1, -1, -1,  1,  1, -1, -1,  1, ...
             -1, -1,  1,  1, -1,  1,  1, -1,  1,  1, -1, -1,  1,  1,  1, -1, ...
              1, -1, -1, -1,  1, -1,  1, -1,  1, -1, -1, -1,  1, -1,  1, -1, ...
             -1,  1, -1, -1, -1,  1, -1, -1,  1, -1,  1, -1,  1, -1,  1,  1, ...
              1,  1, -1, -1, -1, -1, -1,  1, -1,  1, -1, -1,  1,  1, -1,  1, ...
              1,  1,  1,  1,  1,  1, -1, -1,  1, -1, -1,  1, -1, -1,  1,  1, ...
             -1,  1, -1,  1, -1, -1, -1,  1,  1,  1, -1,  1,  1,  1, -1,  1,  ...
              1, -1, -1,  1, -1,  1, -1, -1,  1, -1, -1,  1, -1,  1,  1,  1,  ...
             -1,  1,  1,  1, -1,  1,  1,  1, -1, -1, -1, -1, -1,  1, -1, -1, ...
             -1,  1,  1, -1,  1, -1, -1, -1,  1,  1,  1, -1,  1,  1, -1, -1, ...
              1, -1,  1,  1,  1, -1, -1,  1, -1, -1,  1,  1, -1,  1, -1, -1, ...
             -1,  1,  1,  1, -1, -1,  1, -1, -1, -1,  1, -1, -1,  1,  1,  1, ...
              1,  1, -1, -1,  1, -1,  1, -1, -1,  1,  1,  1,  1, -1, -1,  1, ...
              1,  1, -1, -1, -1, -1, -1, -1,  1,  1,  1, -1, -1,  1,  1, -1, ...
             -1,  1, -1,  1, -1,  1, -1, -1,  1, -1,  1, -1, -1, -1,  1,  -1 ...
           ];
       
        LTF  =  LTF_256;
    end
    
    if ( params.NFFT == 128 )
        MaxIdx = 63;  
        SubcarrierIndex1 = [ 1:MaxIdx];
        PilotIndex1 = [ 8 24 40 ];          
        PilotSym = [-1 -1 1 1 1 -1 ];
        LTF_128 = [1, 1, -1, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	//1 @1
                    1, 1, 1, 1, 1,-1,-1,1, 1,-1, 1,-1, 1, 1, 1,1, ...
                    1, 1,-1,-1, 1, 1,-1,1,-1, 1,-1,-1,-1,-1,-1,1, ...
                    1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1, -1,1, ...	//-1 @59
                   -1, 1, -1, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	//-1 @-59
                    1, 1, 1, 1, 1,-1,-1,1, 1,-1, 1,-1, 1, 1, 1,1, ...
                    1, 1,-1,-1, 1, 1,-1,1,-1, 1,-1,-1,-1,-1,-1,1, ...
                    1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1, 1,-1 ];
    
        LTF  =  LTF_128;   
    end 
    
    if ( params.NFFT == 64 )
        MaxIdx =31;
        if ( MaxIdx > 24 ) 
            SubcarrierIndex1 = [1:MaxIdx] ;   
        else
            SubcarrierIndex1 = [1:MaxIdx] ;   
        end
        PilotIndex1 = [ 8 16 ];% 24];
        PilotSym = [ -1 -1 1 1 1 -1 ];
        PilotSym = [ -1   1 1   -1 ];
        LTF_64 = [	-1, -1, -1, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	 
                    1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1,-1,1, ...	 
                    1, -1, -1, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	 
                    1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1,-1, -1 ];
    
        LTF =  LTF_64 ;
    end 
    
    
    if ( params.NFFT == 32 )
        MaxIdx =15;
        if ( MaxIdx > 16 ) 
            SubcarrierIndex1 = [1:MaxIdx] ;   
            PilotIndex1 = [ 8 16 ]; 
            PilotSym = [ -1   1 1   -1 ];
        else
            SubcarrierIndex1 = [1:MaxIdx] ;   
            PilotIndex1 = [ 8 ]; 
            PilotSym = [ -1   1];
        end
        
        
        LTF_32 = [	1, -1, -1, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	 
                    1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1,-1,-1 ];
    
        % 16 repetition
        LTF =  LTF_32 ;
    end 
        
    SubcarrierIndex2 = [ sort(-SubcarrierIndex1)];
    params.LTF =  zeros(size(LTF));
    SubcarrierIndex =[SubcarrierIndex1+1 params.NFFT+SubcarrierIndex2+1];
    params.LTF([SubcarrierIndex])= LTF(SubcarrierIndex);
    if ( params.dmt_mode == 1 )
        params.LTF([params.NFFT+SubcarrierIndex2+1])= LTF(SubcarrierIndex1(end:-1:1)+1);
    end
    params.SubcarrierIndex1 = SubcarrierIndex1;
    params.SubcarrierIndex2 = SubcarrierIndex2;
    params.SubcarrierIndex1 = SubcarrierIndex1+1;
    params.SubcarrierIndex2 = params.NFFT+SubcarrierIndex2+1;
    params.SubcarrierIndex  = SubcarrierIndex ;
    params.PilotSym = PilotSym;
    if ( params.NTXStream == 2 )
        params.PilotSym = [PilotSym; -PilotSym;];
        %params.PilotSym = [PilotSym; PilotSym;];
    end
    params.PilotIndex = [PilotIndex1 -PilotIndex1 + params.NFFT] +1;
    params.DataSubcarrierIndex = setdiff(params.SubcarrierIndex,params.PilotIndex);
    params.Nsd = length(SubcarrierIndex1) + length(SubcarrierIndex2) - length(PilotIndex1)*2;    
    params.sync_pattern = params.sync_pattern * sqrt(length(SubcarrierIndex))/params.NFFT;


function params = get_STF( params )

    if ( params.cfr.CFEtype == 2 )
        cfo_sync16_ptn = [ ...
           1  0  0  0  1  1  0  1  1  0  1  1  1  0  1 ...
           0  0  1  1  1  1  0  0  0  0  0  1  1  0  0 ...
           1  1  1  1  1  0  1  1  1  1  1  0  0  0  0 ...
           1  1  0  1  0  0  0  1  0  1  1  1  0  1  0 ...
           0  0  1  0];
        sync_pattern =  QAMMapper ( cfo_sync16_ptn,  params, '' );
    end

    if ( params.cfr.CFEtype == 5 )
        sync_pattern1 = get_sync_pattern_crt(params, 1);
        sync_pattern2 = get_sync_pattern_crt(params, 2);
        if ( params.NTXStream == 1 )
            sync_pattern3= [sync_pattern1;]; 
        else
            sync_pattern3= [sync_pattern1; sync_pattern2;]; 
        end  
        sync_pattern = repmat(sync_pattern3, 1, params.cfr.CRTrep);
    end

    if ( params.dmt_mode == 1 )
        sync_pattern= real(sync_pattern);
    end
    params.STF = sync_pattern ;
    params.NSTFSample = size(sync_pattern,2) * 2;
    params.sync_pattern = sync_pattern;


function sync_pattern = get_sync_pattern_crt( params, chidx)

        cfo_sync16_ptn = rand(1, params.Nbpsc * 16) > 0.5;
        cfo_sync9_ptn = rand(1, params.Nbpsc * 9) > 0.5;
        sync16_pattern = ...
            [-0.9487 - 0.3162i  -0.9487 + 0.3162i  ...
              0.3162 - 0.9487i   0.9487 - 0.3162i  ...
             -0.3162 + 0.3162i   0.9487 + 0.3162i ...
             -0.3162 - 0.9487i  -0.9487 - 0.9487i  ...
              0.3162 + 0.9487i  -0.9487 + 0.9487i  ...
             -0.3162 - 0.3162i  -0.3162 + 0.9487i ...
              0.3162 + 0.3162i   0.9487 + 0.9487i ...
              0.3162 - 0.3162i   0.9487 - 0.9487i];
        if( chidx == 2 )
        	sync16_pattern = circshift( sync16_pattern,2,2);
	end
        params.mapper.Nbitspersymbol = params.Nbpsc; 
        %sync16_pattern  =  QAMMapper ( cfo_sync16_ptn,  params, '' );
        sync9_pattern   =  QAMMapper ( cfo_sync9_ptn,  params.mapper, '');    
        if (  params.Nbpsc == 2) 
            if( chidx == 1 )
                cfo_sync16_ptn = [ ...
                   1  0  0 0 1 1 0 0 0 0 0 1 0 0 0  ...
                   0 1 0 0 1 1 0 0 1 1 1 0 1 0 1  ...
                   1 1 ];
               
               cfo_sync9_ptn = [ ... 
                   1 1 0 0 0 1 0 0 1 1 0 1 1 0 1  ...
                   1 0 1];
            end
            if( chidx == 2 )
                cfo_sync16_ptn = [ ...
                    0 0 1 0 1 1 1 1 0 0 0 0 0 0 0  ...
                    0 1 1 0 1 0 1 1 1 0 0 0 1 1 1  ...
                    0 0];
                cfo_sync9_ptn = [ ...
                   1 0 1 1 1 0 1 1 1 1 0 1 1 0 1  ...
                   1 0 0];
            end
            sync16_pattern  =  QAMMapper ( cfo_sync16_ptn,  params.mapper, '' );
            sync9_pattern   =  QAMMapper ( cfo_sync9_ptn,  params.mapper, '' );   
        end
        sync16_pattern  = [sync16_pattern sync16_pattern sync16_pattern ];
        sync16_patterns = [sync16_pattern sync16_pattern sync16_pattern ];
        sync9_patterns  = [sync9_pattern sync9_pattern ...
                           sync9_pattern sync9_pattern ];
        sync9_patterns  = [sync9_patterns sync9_patterns ];
        sync_pattern    = [sync9_patterns sync16_patterns];
        sync_pattern    = sync_pattern(1:9*16);
        sync_pattern = sync_pattern / sqrt(mean(abs(sync_pattern) .^2));
        %if ( params.cfr.CRT2  == 8 )
        %    sync_pattern    = [sync9_patterns(1:36) sync16_patterns];
        %    sync_pattern1   = sync_pattern(1:9*8);
        %else
        %    sync_pattern    = [sync9_patterns(1:72) sync16_patterns];
        %    sync_pattern1   = sync_pattern(1:9*16);
        %end

function spmpre  = reinit_spmpre  (spmpre, params, sims)
    [pwr_mul, LP_dB] = GetLaunchPwr( sims );
    span =1;
    Leff =   (1 - exp (- sims.channel.ssmf.Alpha*  sims.channel.edfa.length))/sims.channel.ssmf.Alpha;
    gain =   pwr_mul * sims.channel.ssmf.Gamma* Leff * span;
    spmpre.gain = gain;


function [pwr_mul, LP_dB] = GetLaunchPwr( sims)

%  Usage      : [pwr_mul, LP_dB] = GetLaunchPwr(laser, sims, MZmod, txedfa )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : miroandi@kaist.ac.kr   
%  Known bugs :

    mW = 1e-3;
    pwr_mul= sqrt(sims.channel.MZmod.launch_power)* sims.channel.TXDAC.gain ;
    pwr_mul = pwr_mul * 128; %sim.dacout ;
    pwr_mul = pwr_mul *  pi/ sims.channel.MZmod.Vpi_RF/sqrt(2)* db2mag(sims.channel.txedfa.gain_dB);
    pwr_mul = (pwr_mul )^2 ;
    LP_dB = 10*log10(pwr_mul) - 9.4857  ;

function   [sims, params]=  Default_FFT()
    
    global SW_PATH
    global  DSP_PATH 
    run( ['Units.m']);

if ( exist('sims') == 0) 
    [sims, params]=  Init_OFDM (    );        
    load ([SW_PATH 'RunDir/savedState.mat']);
else
    [sims, params]=  Init_OFDM ( sims, params  );
end

defaultStream = RandStream.getGlobalStream;
defaultStream.State = savedState;

params.BaudFreq = 30*GHz;
params.RX = 30*GHz;
params.Nbpsc = 2 ;
params.TXSampleFreq = params.BaudFreq;
params.RXSampleFreq = params.BaudFreq;
params.NTXStream = 1;
params.NRXStream = params.NTXStream;

params.Nbpsc = 2 ;
params.Nsd = 120;
params.NFFT = 128;

params.TXSampleFreq = params.BaudFreq;
params.RXSampleFreq = params.BaudFreq;
params.NTXStream = 1;
params.NRXStream = params.NTXStream;
params.NLTF=  100; % 2:Frame synchronization problem
params.NDataSymbol = 0; 
params.en_bit_alloc = 0;
params.en_power_loading =0;
params.AWGSampleFreq = 100*GHz;
params.OSCFreq  =120*GHz;
params.power_sc = 1 * ones(params.NTXStream, size(params.NFFT,2)) ;

[sims, params]=  ReInit_OFDM ( sims, params  );  

function [sims, params]=  Init_OFDM ( sims, params  )

global SW_PATH
run( ['Units.m']);

if nargin < 1
    BitPerSymbol = 4;
    sims.T = 0; 
    sims.const_axes={'' '' '' ''};
    sims.plot_axes={'' '' '' '' '' '' '' '' '' '' };
    sims.cpr_axes='';
    sims.cpr_axes1='';
    sims.ter_axes='';
    sims.plothandle='';
    sims.sync_axes ='';
    sims.psd_axes ='';
    sims.psdhandle='';
    sims.ber_axes ='';
    sims.evm_text ='';
    params.Nbpsc    = BitPerSymbol;    
end


sims.show_constellation = 0;
sims.show_cpr  = 0;
sims.show_tpr  = 0;
sims.show_sync = 0;
sims.show_psd  = 0;
sims.show_ber  = 0;
sims.show_ce   = 0;

 
sims.en_disp_result = 1;
sims.max_num_sim    = 1 ;
sims.logfile   = [SW_PATH '/Results/Log/OFDM', datestr(now,'ddmmm'), '.txt'];
sims.comment   = '';
sims.mode        = 0; % 0: No sweep
sims.X_val       = 0; % 
sims.store_data     = 0; 
sims.Xlabel      = 'SNR'; % 
sims.run_mode    = 1; % 1: Simulation, 0: Test mode 
sims.plot_mode   = 1; % 1: BER, 
sims.plot_str{1} = 'BER';
sims.plot_str{2} = 'EVM';
sims.plot_str{3} = 'MSEE(Phase)';
sims.print_tx_testvector = 0;
sims.print_rx_testvector = 0;
sims.one_panel           = 0;


%%  Generator
sims.dataf_filename             = [ 'prbs15.txt'];
sims.dataf.data_file            = [SW_PATH 'Ptn/' sims.dataf_filename];
sims.dataf.useprbsdata          = 1; % random data  
sims.txdata_file                = [SW_PATH 'Ptn/TxPtn.mat'];
sims.txdata_filename            = ['TxPtn.mat'];

%%  DSP parameters

params.NDataSymbol              = 1000 ; % Number of symbols

params.FEC_mode                  = 0; % 0: disable FEC, 1: RS, 2: LDPC(ETRI)

params.BaudFreq                  = (30 *GHz);
params.ssb                       = 0; 
params.modulation_format         = 1; 
params.modulation_format_str1{1} = 'OFDM';
params.modulation_format_str1{2} = 'DMT';
params.QAM_factor                = 2; 
params.GrayMap                   = 1; 
params.big_end_map               = 0; 
params.fixed_type                = 'emul';
params.fixed_sim                 = 0;
params.blind_mode                = 0;
params.dmt_mode                 = 0;


%%  Transmitter
params.TXSampleFreq      = params.BaudFreq;
params.AWGSampleFreq     = (120*GHz);
params.AWG.ResampleMethod = 0;
params.AWGcorrection     = 1;
params.NTXStream         = 1;      % Number of transmitted stream 
params                   = init_ofdm(params);
params.rs                = init_rs();
params.interleaver       = init_interleaver();
params.pilot             = init_pilot( );
params.tpr               = init_tpr( );
params.cpr               = init_cpr( );
params.ovsample_method   = 1; %  1: repetition, 0: zeropadding
params.ps                = init_ps();
params.mapper            = init_mapper();
params.TXMatchedfilter   = init_matched_filter();
params.spmpre            = init_spmpre();
params.TXAGC.avg_out     = 0.125;
params.TXAGC.en          = 1;
params.awglpf.en         = 0;
params.awglpf.cutoff     = 60*GHz;

%%  Receiver ;
params.RXoversample      = 1; % Not valid anymore.
params.RXSampleFreq      = params.BaudFreq * params.RXoversample  ;
params.OSCFreq           = (100 *GHz);
params.NRXStream         = 1;

% Matched filter
params.RXMatchedfilter   = init_matched_filter();
params.demap             = init_demapper();
params.AGC.avg_out       = 0.5;
params.AGC.avg_out       = 4.5;
params.AGC.en            = 1;
params.DCCancel.en       = 0;
params.OFDE              = init_OFDE() ;
params.rxskew            = init_skew() ;
params.cfr               = init_cfr( );
params.fcfr              = init_cfr( );
params.fec               = init_fec( );
params.ce                = init_ce( );
params.searchframe       = init_searchframe() ;
params.searchfineframe   = init_searchfineframe();
params.fixed_sim         = 0;


%% channel
channel.eb2b             = 0;
channel.Oversample       = 1;
channel.SampleFreq       = (200*GHz); 
channel.PhaseOffset      = 0 * pi/2;
channel.CarrierFreqOff   = 0*GHz ; %  0.5 % 
channel.CarrierFreqDrift = 0 ; 
channel.Jitter           = 0 *  0.5 * ps;
channel.TimeFreqOff      = 0 * 1 * ppm;
channel.TimePhaseOff     = 0 * 0.5;
channel.TXLineWidth      = 0 * 200 * kHz;
channel.RXLineWidth      = 0 * 200 * kHz;
channel.enAWGN           = 0;
channel.enASENoise       = 0;
channel.SNRdB            = 24;
channel.OSNRdB           = 40;
channel.multifading.filtertap     = 31;
channel.multifading.delays = [ 0  110*ps]; 
channel.carrier_frequency  = 275*GHz;
channel.AGC.avg_out        = 0.6;
channel.AGC.en             = 1;
channel.Npol               = 2;
channel.fiber_length       = 0*km;

%% System components
TXDAC   = init_DAC( channel.SampleFreq );
RFDriver= init_RFAmp (channel.SampleFreq );
MZmod   = init_MZmod( channel.SampleFreq );
fiber   = init_ssmf( channel.SampleFreq );
dcf     = init_dcf ( channel.SampleFreq );
edfa    = init_edfa( channel.SampleFreq );
txedfa  = init_edfa( channel.SampleFreq );
PD      = init_PD  ( channel.SampleFreq );
TIA     = init_TIA ( channel.SampleFreq );
RFAmp   = init_RFAmp (channel.SampleFreq );
RXADC   = init_ADC ( channel.SampleFreq );

channel.TXSampleFreq =  params.TXSampleFreq;
channel.RXSampleFreq =  params.RXSampleFreq;
channel.PMDtype =  2;
channel.PMD =  0;

%%

sims.channel  = channel;
sims.channel.TXDAC     = TXDAC; 
sims.channel.RFDriver  = RFDriver;
sims.channel.MZmod     = MZmod;
sims.channel.ssmf      = fiber;
sims.channel.dcf       = dcf;
sims.channel.edfa      = edfa;
sims.channel.txedfa    = txedfa;
sims.channel.PD        = PD;
sims.channel.TIA       = TIA;
sims.channel.RFAmp     = RFAmp;
sims.channel.RXADC     = RXADC;

%% ------------------------------------------  

function params=  init_ofdm(params) 
    params.NFFT = 128;
    params.CP_ratio = 1;
    params.LTF_type = 1; % [ A, -A; A, A] type
    params.NLTF = 1; 

function fec=  init_rs() 
    fec.en            = 0;
    fec.N=1023;          % Codeword length
    fec.K=979;           % Message length
    fec.S=fec.K - 465;   % Shortened message length
    fec.M=10;            % Modulation order
  

function interleaver=  init_interleaver() 
    interleaver.en      = 0;
    global SW_PATH
    interleaver.fecperm = dlmread([SW_PATH 'InitFiles/RandPerm14688_reg_12x1224.txt' ]); 

function txpreemp=  init_preemp() 
    txpreemp.en       = 0;
    txpreemp.a        = 1;  
    txpreemp.b        = [ 1 -0.1];
    txpreemp.mod      = 1;  % 1 : Modulo  disable , others: Modulo (-mod, mod]

function pilot = init_pilot ()
    pilot.data_file            = [];
    pilot.useprbsdata          = [];
    pilot.en        = 3;
    pilot.Nbitspersymbol = 2;
    pilot.GrayMap  = 1;
    pilot.rate         = 32/31;% params.block_size/(params.block_size -1);



function [Matchedfilter]=  init_matched_filter() 

    alpha = 0.4;  
    resp_sample = 8;
    os_factor = 2 ;
    %Matchedfilter.freq_resp = ones( 1, 512);
    Matchedfilter.freq_resp = fftshift(RRC_f( os_factor, alpha, resp_sample)) ;
    Matchedfilter.time_resp =  SRRC( os_factor,alpha, resp_sample);
    Matchedfilter.en        = 0;
    Matchedfilter.alpha = alpha;
    Matchedfilter.resp_sample = resp_sample ;
    Matchedfilter.span        = resp_sample ;
    Matchedfilter.sps         = 4 ;
    Matchedfilter.FWHM        = 1 ;

function spmpre =  init_spmpre() 
    spmpre.en = 0;
    spmpre.gain = 1;

function [OFDE]=  init_OFDE() 
    OFDE.freq_resp = ones( 1, 512);
    OFDE.en        = 1;

function [skew]=  init_skew(  )
    skew.en = 0 ;
    skew.en_est = 0 ;
    skew.sft = complex(0);
    skew.sft(2,1) = complex(0);
    skew.gainim(2,1) = (0);
    skew.phaseim(2,1) = (0);


function [cfr]=  init_cfr( )
    cfr.PRL         = 512*10;
    cfr.OV          = 2;
    cfr.BLK         = 64 ;% phase estimation block size ( # of samples  )
    cfr.STEP        = 64; % phase estimation block window slide
    cfr.en          = 1;
    cfr.CPEtype     = 1;     
    cfr.CPEtype_str1{1} = '4-th power V-V';
    cfr.CPEtype_str1{2} = '8-th power V-V (16QAM)';
    cfr.CPEtype_str1{3} = '8-th power V-V (16QAM) medium filter';
    cfr.CFEtype     = 5;        
    cfr.CFEtype_str1{1} = 'Phase difference';
    cfr.CFEtype_str1{2} = 'Training symbol -16 repetition';
    cfr.CFEtype_str1{5} = 'CRT ';
    cfr.PCtype     = 3;
    cfr.exp_phasediff = 0;
    cfr.CarrierFreqOff = 0 ;
    cfr.CRTrep = 1;
    cfr.CRT2   = 16;

function [ce]=  init_ce( )
    ce.en          = 1;
    ce.en_ISFA     = 1;
    ce.ISFASize     = 2;

function mapper = init_mapper(  )
    mapper.GrayMap        = 1;
    mapper.big_end_map    = 0;
    mapper.Nbitspersymbol    = 4;
    mapper.QAM_factor    = 2;

function demapper = init_demapper(  )
    demapper.type          = 1; % 1: Hard decision, 2: , 3: Bit-metric decoding 
    demapper.type_str1{1} = 'Hard';
    demapper.type_str1{2} = 'BIMD';
    demapper.type_str1{3} = 'BMD';
    demapper.GrayMap      = 1;
    demap.big_end_map    = 0;


function [tpr]=  init_tpr(  )
%  Timing phase recovery
   tpr.en            = 1; % Feedback
   tpr.L             = 5; 
   tpr.OV            = 1; 
   tpr.PRL           = 512 ;   
   tpr.tau_init      = 0;     
   tpr.K1            = -2e-2 * 1; 
   tpr.K2            = -1e-4 * 1 ;
   tpr.TPEtype       = 5;
   tpr.T             = 0;

function [cpr]=  init_cpr( )
    cpr.en          = 1;
    cpr.PRL         = 128 ;
    cpr.K1          = 1 ;
    cpr.K2          = 0 ;



function ps  = init_ps(  )
    ps.en            = 0;
    ps.n             = 1;
    ps.entropy       = 2.5;
    ps.k             = 1;
    ps.num_dm_block_per_fec = 1;
    ps.signbit       = 0;

function fec = init_fec(  )
    fec.subsystemType = 'QPSK 5/6';
    fec.en            = 0;
    fec.max_iter      = 50;
    fec.FEC_mode      = 0; % DVB-S2
    fec.n             = 1;
    fec.k             = 1;


function searchframe   = init_searchframe() 
    searchframe.en    = 1;
    searchframe.search_offset    = 1500; % For stable search
    searchframe.start_of_frame   = 1; 
    searchframe.frame_header     = []; 
    searchframe.MaxPos           = 1; 
    searchframe.th               = 0; 

function searchfineframe = init_searchfineframe() 
    searchfineframe.en= 1;
    searchfineframe.search_range1= 1;
    searchfineframe.search_range= 200;
    searchfineframe.start_of_frame   = 1; 
    searchfineframe.MaxPos           = 1; 
    searchfineframe.type             = 1; 

function DAC = init_DAC( SampleFreq )
    GHz = 1e9;
    DAC.SampleFreq      = SampleFreq;  
    DAC.en               = 1;  
    DAC.ENob             = 6;
    DAC.nonoise          = 0; 
    DAC.gain             = 1;
    DAC.T.signed         = 1;
    DAC.T.wordl          = 6;
    DAC.T.fracl          = 2;
    DAC.T.round          = 1;
    DAC.T.sat            = 1;
    DAC.bandwidth        = 1 * 20   * GHz; % Baseband bandwidth 
    DAC.bandwidth        = 1 * 27/2 * GHz; % Baseband bandwidth 
    DAC.bandwidth_en     = 1;

function MZmod = init_MZmod( SampleFreq ) 
    GHz = 1e9;
    mW = 1e-3;
    MZmod.type         = 'IMMZM';
    MZmod.Vpi_DC       = 4 ;
    MZmod.Vpi_RF       = 4 ;
    MZmod.Vbias1       =  1 ; % 1: Intensity modulation 
    MZmod.Vbias2       = -1 ; % -1: Intensity modulation 
    MZmod.launch_power = 0.1 *mW;
    MZmod.bandwidth    = 1 * 20 * GHz; % Baseband bandwidth 
    MZmod.bandwidth_en = 1;
    MZmod.SampleFreq        = SampleFreq;

function fiber = init_ssmf_Cband( SampleFreq )
    nm = 1e-9;
    km = 1e3;
    um = 1e-6;
    ps = 1e-12;
    W  = 1;
    c  = 2.99e8;
    Z0 = 377;
 
    fiber.lambda0      = 1550*nm; %m
    AlphadB            = 1*0.2 /km;        
    fiber.CD           = 17   ;                                        % ps/nm/km
    fiber.DeltaH       = 1*km  ;                              % m 
    fiber.fiber_length = 10 *km ;                      % Fiber length 
    fiber.Overlap      = 2 ;
    fiber.FFTSize      = 0;
    fiber.Beta2        = (1)*fiber.lambda0^2/(2*pi*c)*fiber.CD*1e-6 ;  % 2nd order dispersion
    fiber.Beta         = 0 ;                                 % 1st order dispersion
    fiber.Alpha        = 1*AlphadB/(log10(exp(1))*10) ;        % Loss(dB/m)/10/Log10(e)
    fiber.Gamma        = 1*-1*1.2/W/km ;                      % Nonlinear effect,  /W/m 0.6~2.4   
    fiber.Aeff         =  80*um^2;                            % Effective area.
    fiber.n2           = 26e-21 ;                               % n2.
    fiber.n            = 1.5 ;                                   % Not used.
    fiber.centered     = 1;                               % Carrier frequency is center of bandwidth 
                                                   % PMD related parameters
    fiber.Dp           = 1 *2* 1*ps/sqrt(km);                   % First order PMD coefficient Dp  
    fiber.power_split1 = 1;                            % Power splitting ratio of polarization (Transmit side)
    fiber.power_split2 = 0.7;                          % Power splitting ratio of polarization (Receiver)
    fiber.DGD          = 1*0.1*ps/km;                          % average DGD value /km, 0.1 ps/km
 
    fiber.Npol         = 2 ;                                  % Polarization diversity
    fiber.tolerance    = 1e-5; 
    fiber.maxiter      = 1;
 
    fiber.SampleTime   = 1/SampleFreq;
    %fiber.SampleTime   = 1/channel.SampleFreq ;
    fiber.DeltaT       = fiber.SampleTime ;   
    fiber.PMD = fiber.Dp * sqrt( fiber.fiber_length ) ;    

function fiber = init_ssmf( SampleFreq )
    nm = 1e-9;
    km = 1e3;
    um = 1e-6;
    ps = 1e12;
    W  = 1;
    c  = 2.99e8;
    Z0 = 377;
 
    fiber.lambda0      = 1310*nm; %m
    AlphadB            = 1*0.34 /km;        
    fiber.CD           = 2   ;                                        % ps/nm/km
    fiber.DeltaH       = 1*km  ;                              % m 
    fiber.fiber_length = 10 *km ;                      % Fiber length 
    fiber.Overlap      = 2 ;
    fiber.FFTSize      = 1024*8;
    fiber.Beta2        = (1)*fiber.lambda0^2/(2*pi*c)*fiber.CD*1e-6 ;  % 2nd order dispersion
    fiber.Beta         = 0 ;                                 % 1st order dispersion
    fiber.Alpha        = 1*AlphadB/(log10(exp(1))*10) ;        % Loss(dB/m)/10/Log10(e)
    fiber.Gamma        = 1*-1*1.2/W/km ;                      % Nonlinear effect,  /W/m 0.6~2.4   
    fiber.Aeff         =  80*um^2;                            % Effective area.
    fiber.n2           = 26e-21 ;                               % n2.
    fiber.n            = 1.5 ;                                   % Not used.
    fiber.centered     = 1;                               % Carrier frequency is center of bandwidth 
                                                   % PMD related parameters
    fiber.Dp           = 1 *2* 1*ps/sqrt(km);                   % First order PMD coefficient Dp  
    fiber.power_split1 = 1;                            % Power splitting ratio of polarization (Transmit side)
    fiber.power_split2 = 0.7;                          % Power splitting ratio of polarization (Receiver)
    fiber.DGD          = 1*0.1*ps/km;                          % average DGD value /km, 0.1 ps/km
 
    fiber.Npol         = 2 ;                                  % Polarization diversity
    fiber.tolerance    = 1e-5; 
    fiber.maxiter      = 1;
 
    fiber.SampleTime   = 1/SampleFreq;
    %fiber.SampleTime   = 1/channel.SampleFreq ;
    fiber.DeltaT       = fiber.SampleTime ;   
    fiber.PMD = fiber.Dp * sqrt( fiber.fiber_length ) ;    

function dcf = init_dcf( SampleFreq )
    c  = 2.99e8;
    km = 1e3;
    dcf = init_ssmf( SampleFreq );
    dcf.CD= -39  ;                                   % ps/nm/km
    dcf.Beta2 = (1)*dcf.lambda0^2/(2*pi*c)*dcf.CD*1e-6 ;  % 2nd order dispersion
    dcf.Beta  = 0 ;                                 % 1st order dispersion
    dcf.Alpha = (0.25 /km)/(log10(exp(1))*10) ;        % Loss(dB/m)/10/Log10(e)
    dcf.DeltaH = 1*km ;
    %dcf.Leff   = (1 - exp (- dcf.Alpha * dcf.fiber_length ))/dcf.Alpha;
    dcf.fiber_length = 0;

function edfa  = init_edfa( SampleFreq )
    km = 1e3;
    nm = 1e-9;
    fiber.lambda0      = 1550*nm; %m
    c = 2.99e8;  % Speed of light 
    h =6.6e-34;  % Plank constant, J.s
    edfa.SampleFreq  = SampleFreq; 
    edfa.length      = 20* km ; %400* km
    edfa.hv          = h*c/fiber.lambda0;
    edfa.gain_dB     = 20 ;
    edfa.NF_dB       = 5.5 ; 
    edfa.nonoise     = 0;

function PD  = init_PD( SampleFreq )
    GHz = 1e9;
    PD.type              = 'Direct';
    PD.SampleFreq        = SampleFreq;
    PD.max_output_power_dBm  = 7; % dBm 
    PD.responsivity      = 0.02; % 0.02 A/W 
    PD.resistor          = 100 ; % Ohm
    PD.noise_power_dBm   = -70;  % Opt 2 electric part noise including electri amplifier
    PD.nonoise           = 0; 
    PD.gain_dB           = 0;  
    
    PD.passband          = 1;
    PD.bandwidth         = 1 * 22 * GHz; % Baseband bandwidth 
    PD.bandwidth_en      = 1;
    PD.en_DCCancel       = 1;

function TIA  = init_TIA( SampleFreq )
    GHz = 1e9;
    TIA.SampleFreq      = SampleFreq;
    TIA.gain_dB         = 15 ;
    TIA.NF_dB           = 10 ;   
    TIA.nonoise         = 0;
    TIA.bandwidth       = 1 * 22 * GHz; % Baseband bandwidth 
    TIA.bandwidth_en    = 1;


function RFAmp   = init_RFAmp ( SampleFreq )
    GHz = 1e9;
    RFAmp.SampleFreq      = SampleFreq;
    RFAmp.gain_dB         = 37 ;
    RFAmp.NF_dB           = 10 ;   
    RFAmp.nonoise         = 0;
    RFAmp.bandwidth       = 1 * 40 * GHz; % Baseband bandwidth 
    RFAmp.bandwidth_en    = 1;
    RFAmp.V_sat           = 0;


function ADC = init_ADC ( SampleFreq ) 

    GHz = 1e9;
    ADC.SampleFreq       = SampleFreq;
    ADC.en               = 1+1j;  
    ADC.BIT              = 8; 
    ADC.ENob             = 7.3;
    ADC.gain             = 1;
    ADC.nonoise          = 1;  
    ADC.T.signed         = 1;
    ADC.T.wordl          = 8;
    ADC.T.fracl          = 5;
    ADC.T.round          = 1;
    ADC.T.sat            = 1;
    ADC.bandwidth        = 1 * 33/2 * GHz; % Baseband bandwidth 
    ADC.bandwidth_en     = 1;


% --- Executes on button press in text2_7.
function text2_7_Callback(hObject, eventdata, handles)
% hObject    handle to text2_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text2_7
