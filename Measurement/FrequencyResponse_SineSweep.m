function varargout = FrequencyResponse_SineSweep(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FrequencyResponse_SineSweep_OpeningFcn, ...
                   'gui_OutputFcn',  @FrequencyResponse_SineSweep_OutputFcn, ...
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
 


function FrequencyResponse_SineSweep_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject; 
handles.sims =  varargin{3};
handles.params =  varargin{4};
global SW_PATH
handles.sims.freq_filename = [SW_PATH 'FreqResp.mat'];
set( handles.edit1_5, 'String', 'FreqResp.mat'); 

GHz=1e9;
set( handles.edit2_1, 'String', num2str( handles.params.AWGSampleFreq/GHz));
set( handles.edit2_2, 'String', num2str( handles.params.OSCFreq/GHz));
set( handles.edit2_3, 'String', num2str( handles.params.OSCFreq/2/GHz));
handles.prev_AFRvec ='';
handles.AFRvec ='';
guidata(hObject, handles);


 
function varargout = FrequencyResponse_SineSweep_OutputFcn(hObject, eventdata, handles) 
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
handles.prev_AFRvec ='';
handles.AFRvec ='';
guidata(hObject, handles);


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
handles = sweep_sine(hObject, eventdata, handles);
display_measure(hObject, eventdata, handles);




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
    handles.signal  = get_value (handles.edit1_1);
    handles.reference  = get_value (handles.edit1_2);
    handles.retry_thres  = get_string (handles.edit1_3);
    handles.retry_cnt  = get_string (handles.edit1_4);
    handles.filename  = get(handles.edit1_5, 'String');

    handles.max_tone  = get_string (handles.edit2_3)*GHz;
    handles.num_tone  = get_string (handles.edit2_4);
    handles.norm_amp  = get_string (handles.edit2_5);
    handles.debug_mode  = get_value (handles.text2_6);
    handles.log_scale  = get_value (handles.edit2_6);
    handles.params.TXSampleFreq = handles.params.AWGSampleFreq;
    handles.params.AWG.ResampleMethod = 1;
    % Tone wave should has multiples of 128 symbol.
    handles.max_tone = floor(handles.max_tone/handles.num_tone/(handles.params.AWGSampleFreq/128/256));
    handles.max_tone = handles.max_tone * handles.params.AWGSampleFreq/128/256 * handles.num_tone ;
    if ( handles.log_scale == 1 )
        Fvec = decade(5, 12, 0.1);
    else
        Fvec = handles.max_tone/handles.num_tone *(1:handles.num_tone);
    end
    Fvec(Fvec<20*MHz | Fvec>handles.max_tone) = [];
    % Freq should be integer times of AWGFreq/128
    handles.Fvec =Fvec;
    handles.Flen = length(Fvec);
    guidata(hObject, handles);
 

function val = get_value(handles1)
val = get(handles1, 'Value');

function val = get_string(handles1)
val = str2num(get(handles1, 'String'));


function handles = sweep_sine(hObject, eventdata, handles)
Flen = handles.Flen;
Fvec = handles.Fvec;
handles.prev_AFRvec  = handles.AFRvec;
handles.prev_Fvec  = handles.Fvec;
hWtbr = waitbar(0, 'Please wait...');
AFRvec = zeros(1, Flen);
PFRvec = zeros(1, Flen);
sims = handles.sims;
params = handles.params;
Umout =  handles.norm_amp;
t = ( 0:1:2^15-1)/handles.params.AWGSampleFreq;
calch1 = 1;             % calibration coefficient of the first analog input
calch2 = 1;             % calibration coefficient of the second analog input
chskew =0;
GHz =1e9;
MHz =1e6;
% measurement 
 
for k = 1:Flen

    retry_cnt = 0; is_trigger_ok =0 ;
    % generation of the output signal
    while( retry_cnt < (handles.retry_cnt +1) &&  is_trigger_ok ==0 ) 
        retry_cnt =retry_cnt +1;
        f = Fvec(1, k);    
        outdata = Umout*sin(2*pi*f*t);

        if ( handles.debug_mode == 1 ) 
            awg_signal = KeySight_AWG_Write2( outdata, params); 
            awg_signal = reshape(awg_signal, 1, length(awg_signal));
            channelin =awg_signal ; 
            [indata2, sims] = Channel( sims, channelin, sims.channel);
             indata = indata2(:, 1:size(awg_signal,2) );
            pause(2);
        else        
            outdata = ones(2,1) * outdata * (1 + 1j);
            awg_signal = KeySight_AWG_Write2( outdata, params);
            sims.store_data =0 ;  
%             pause(2);
            [indata2]       = SelTestVector( 0, k, sims, params ) ;      
            if( size(indata2,1) > 1 )
                if ( handles.signal == 1 )
                    signal = real( indata2(1,:));
                end
                if ( handles.signal == 2 )
                    signal = imag(indata2(1,:));
                end
                if ( handles.signal == 3 )
                    signal = real(indata2(2,:));
                end
                if ( handles.signal == 4 )
                    signal = imag(indata2(2,:));
                end
                
                if ( handles.reference == 5 )
                    reference = indata2(1,:);
                else
                    reference = indata2(handles.reference,:);
                end
            else
                signal = indata2; 
                reference = indata2;
            end
            reference = indata2(:, 1:size(outdata,2) );
            if ( handles.reference == 5 )
                reference =  Resample( outdata,  params.AWGSampleFreq, params.OSCFreq);
                reference = outdata;
                maxidx = min(length(reference), length(signal));
                signal = signal(1,1:maxidx);
                reference = reference(1,1:maxidx);
            end
            indata     = signal  ;
            outdata    = reference  ;
            indata = indata(:, 1:size(outdata,2));          
        end

        indata = detrend(indata, 'constant'); % I dont know what this(detrend)  means.

        % strobe the data
        uin = indata(1, round(0.1*length(indata)):round(0.9*length(indata)))*calch1;
        uout = outdata(1, round(0.1*length(indata)):round(0.9*length(indata)))*calch2; 

        uin = real(uin);
        uout = real(uout);
        % calculate the frequency response
        AFR = ampratiomeasure(uout, uin);
        PFR = phdiffmeasure(uout, uin);

        % correction of the phase error due to non-simultaneous sampling
        dphi = 2*pi*f*chskew;
        PFR = PFR - dphi;
        if ( AFR >= db2mag(handles.retry_thres) )
            is_trigger_ok = 1;
        end 
%         figure;plot(real(awg_signal));hold on;plot(real(uout),'g');plot(real(uin(:)),'r');
%          figure;plot(real(awg_signal(1:100)));hold on;plot(real(uout(1:100)),'g');plot(real(uin(1:100)),'r');
    end %while ( retry_cnt < (handles.retry_cnt +1)) 

    % save the data into frequency response vectors
    AFRvec(1, k) = AFR;
    PFRvec(1, k) = PFR;
     
    waitbar(k/Flen, hWtbr, ['Measurement at ' num2str(f/MHz) 'MHz'])
%     figure; plot(outdata(1:200)); hold on; plot(indata(1:200),'r');
%     figure; plot(outdata ); hold on; plot(indata ,'r');

    handles.PFRvec =PFRvec;
    handles.AFRvec =AFRvec;
    handles.awg_signal = awg_signal;
    handles.osc_data = real(indata);
    guidata(hObject, handles);
    display_measure(hObject, eventdata, handles,k);
end  
% handles.AFRvec_ch(handles.signal, :) = handles.AFRvec;
% close the waitbar
close(hWtbr)

%% plot the frequency response
% unwrap the phase and convert it from radians to degrees

handles.PFRvec =PFRvec;
handles.AFRvec =AFRvec;
guidata(hObject, handles);

function display_measure(hObject, eventdata, handles, k)
GHz=1e9;MHz=1e6;
Fvec = handles.Fvec;
PFRvec = unwrap(handles.PFRvec);
PFRvec = 180/pi*(PFRvec);

% convert the amplitude do dB
AFRvec = 20*log10(handles.AFRvec);


if ( handles.log_scale == 1 )
    semilogx(handles.amp_axes, Fvec/GHz, AFRvec, 'w', 'LineWidth', 2)
else
    plot(handles.amp_axes, Fvec/GHz, AFRvec, 'w', 'LineWidth', 2)
end

xlim(handles.amp_axes, [min(Fvec/GHz) max(Fvec/GHz)])
ylim(handles.amp_axes, [min(AFRvec)-10 max(AFRvec)+10])
if ( size(handles.prev_AFRvec) ==  size(handles.AFRvec) ) 
    prev_AFRvec = 20*log10(handles.prev_AFRvec);
    hold(handles.amp_axes, 'on');
    if ( handles.log_scale == 1 )
        semilogx(handles.amp_axes, handles.prev_Fvec/GHz, prev_AFRvec, 'y', 'LineWidth', 1)
    else
        plot(handles.amp_axes, handles.prev_Fvec/GHz, prev_AFRvec, 'y', 'LineWidth', 1)
    end
end 
hold(handles.amp_axes, 'off');
grid(handles.amp_axes, 'on');
 
% xlim(handles.amp_axes, [min(Fvec/GHz) max(Fvec/GHz)])
% ylim(handles.amp_axes, [min(AFRvec)-10 max(AFRvec)+10])
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel(handles.amp_axes, 'Frequency, GHz')
ylabel(handles.amp_axes, 'Magnitude, dB')
title(handles.amp_axes, 'Frequency response (gain)');
default_color(handles.amp_axes);

 
% if ( handles.log_scale == 1 )
%     semilogx(handles.phase_axes, Fvec/GHz, PFRvec, 'w', 'LineWidth', 2)
% else
%     plot(handles.phase_axes, Fvec/GHz, PFRvec, 'w', 'LineWidth', 2)
% end
% grid(handles.phase_axes, 'on');
% xlim(handles.phase_axes, [min(Fvec/GHz) max(Fvec/GHz)])
% ylim(handles.phase_axes, [min(PFRvec)-10 max(PFRvec)+10])
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
% xlabel(handles.phase_axes, 'Frequency, GHz')
% ylabel(handles.phase_axes, 'Phase, \circ')
% title(handles.phase_axes,  'Frequency response (phase)');
% default_color(handles.phase_axes);
% default_color(handles.phase_axes);

timeidx=[1:200];
timeidx2 = [1:round(max(timeidx)*handles.params.OSCFreq/handles.params.AWGSampleFreq)];
hold(handles.phase_axes, 'off');
plot(handles.phase_axes, GHz*timeidx/handles.params.AWGSampleFreq, handles.awg_signal(timeidx), 'w', 'LineWidth', 2)
hold(handles.phase_axes, 'on');
plot(handles.phase_axes, GHz* timeidx2/handles.params.OSCFreq, handles.osc_data(timeidx2), 'y', 'LineWidth', 2)
grid(handles.phase_axes, 'on');
%xlim(handles.phase_axes, [min(Fvec/GHz) max(Fvec/GHz)])
%ylim(handles.phase_axes, [min(PFRvec)-10 max(PFRvec)+10])
 if ( handles.debug_mode == 1 ) 
    ylim(handles.phase_axes, [-1.1 1.1]);
 else
     max_val = max(max(abs(handles.awg_signal)), max(abs(handles.osc_data)));
     max_val = 1.1 * max_val;
     ylim(handles.phase_axes, [-max_val max_val]);
 end
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel(handles.phase_axes, 'time, ns')
ylabel(handles.phase_axes, 'AWG(w), OSC(y) signal')
title(handles.phase_axes,  'AWG, OSC signal');
default_color(handles.phase_axes);
default_color(handles.phase_axes);




