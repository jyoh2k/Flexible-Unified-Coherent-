function varargout = PSD(varargin)

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PSD_OpeningFcn, ...
                   'gui_OutputFcn',  @PSD_OutputFcn, ...
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
 


function PSD_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.current_data = 0;
guidata(hObject, handles);


 
function varargout = PSD_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.axes1;
varargout{2} = handles.text1;
varargout{3} = handles;
% varargout{1} = handles.output;



function Constellation_Callback(hObject, eventdata, handles)

function psdpopupmenu_Callback(hObject, eventdata, handles)
signals = get(handles.figure1,  'UserData');

signal_str = get( hObject,  'String' );
signal_type = get( hObject,  'Value' ) ;  
SubShowPSD(1, signals, signals.params, signals.txsignal, handles.axes1, signal_str{signal_type}); 
% Welch =0 ;
%if ( strcmp(signal_str{signal_type} ,  'Received') )
%    in = signals.received;
%    Rs = signals.params.OSCFreq;  
%end
%if ( strcmp(signal_str{signal_type} ,  'Received Welch') )
%    in = signals.received;
%    Rs = signals.params.OSCFreq;  
%    Welch =1;
%end 
%if ( strcmp(signal_str{signal_type} ,  'Eq Welch') )
%    in = signals.equalized;
%    Rs = signals.params.RXSampleFreq;
%    Welch =1;
%end 
% 
%if ( strcmp(signal_str{signal_type} ,  'Transmitted') )
%    in = signals.txsignal.awg_signal;
%    Rs = signals.params.AWGSampleFreq;
%end
%if ( strcmp(signal_str{signal_type} ,  'Transmitted Welch') )
%    in = signals.txsignal.awg_signal;
%    Rs = signals.params.AWGSampleFreq; 
%    Welch =1;
%end 
%if ( strcmp(signal_str{signal_type} ,  'TX DSP out') )
%    in = signals.txsignal.txout;
%    Rs = signals.params.TXSampleFreq;
%end
%if ( strcmp(signal_str{signal_type} ,  'ADC In') )
%    in = signals.ADCin; Rs = signals.params.OSCFreq;
%end
%if ( strcmp(signal_str{signal_type} ,  'ADC In Welch') )
%    in = signals.ADCin; Rs = signals.params.OSCFreq; 
%    Welch =1;
%end
%if ( strcmp(signal_str{signal_type} ,  'DAC Out') )
%    in = signals.channel.DACout; Rs = signals.channel.SampleFreq;
%end
%if ( strcmp(signal_str{signal_type} ,  'Wireless RF Out') )
%    in = signals.channel.TXRFout;Rs = signals.channel.SampleFreq;
%end
%if ( strcmp(signal_str{signal_type} ,  'LNA Out') )
%    in = signals.channel.rx_lna_out;Rs = signals.channel.SampleFreq;
%end   
%if ( strcmp(signal_str{signal_type} ,  'Mixer Out') )
%    in = signals.channel.rx_mixer_out;Rs = signals.channel.SampleFreq;
%end   
%if ( strcmp(signal_str{signal_type} ,  'PostEmphais') )
%    in = signals.postemphasis; Rs = signals.params.OSCFreq;    
%end
%if ( strcmp(signal_str{signal_type} ,  'PostEmphais Welch') )
%    in = signals.postemphasis; Rs =signals.params.OSCFreq;    
%    Welch =1;
%end
%if ( strcmp(signal_str{signal_type} ,  'Fiber Out') )
%    in = signals.channel.fiber_out; Rs = signals.channel.SampleFreq;
%end
%if ( strcmp(signal_str{signal_type} ,  'Fiber In') )
%    in = signals.channel.fiber_in; Rs = signals.channel.SampleFreq; 
%end
%if ( strcmp(signal_str{signal_type} ,  'ADC Out') )
%    in = signals.channel.ADC_out; Rs = signals.channel.SampleFreq;
%end
%if ( strcmp(signal_str{signal_type} ,  'PD Out') )
%    in = signals.channel.pd_out; Rs = signals.channel.SampleFreq;
%end
%% signals.postemphasis  = frame.postemphasis;
%GHz =1e9;
%draw_psd ( handles.axes1, in, Rs, Welch);
%% ylim  (handles.axes1, [-150 15]); 
%xlabel(handles.axes1,'Freq. (GHz)', 'Color','white');
%grid(handles.axes1, 'on');
%default_color(handles.axes1);
%
%
%function draw_psd (axes, in, Rs, Welch)
%% if ( version('-release') == '2019a' )
%if ( Welch == 0 )
%        [pxx,w] = periodogram(in);
%    freq = fftshift(fft(in));
%    pxx = abs(freq);
%    w=[-Rs/2:Rs/length(in): Rs/2-Rs/length(in)];        
%    plot  ( axes, w,mag2db(pxx/max(pxx)), 'y');
%else
%%     Hs=spectrum.periodogram;
%    Hs=spectrum.welch;
%%     psd(Hs,in(1,:), 'Fs',Rs, 'CenterDC', 1)
%   if ( size(in,2) == 1 )
%       in  = reshape(in(:,1), 1, length(in(:)));
%   end
%    Hpsd = psd(Hs, in(1,:), 'Fs', Rs, 'CenterDC', 1);
%    Pw=Hpsd.Data;
%    Fw=Hpsd.Frequencies;
%    plot(axes, Fw,mag2db(Pw), 'y', 'LineWidth', 2);
%    global SW_PATH;
%    save( [SW_PATH '/Pw.mat'], 'Pw');
%end
 


function psdpopupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles) 
global SW_PATH
[FileName, PathName] = uiputfile([ SW_PATH './Results/Figures/*']);
if ( PathName ~= 0 )
    saveas(handles.axes1,  [PathName FileName '.fig' ], 'fig');
    img =getframe(gcf);
%      img =getframe(handles.axes1);
    imwrite(img.cdata, [PathName FileName '.png' ]);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over psdpopupmenu.
function psdpopupmenu_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to psdpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on psdpopupmenu and none of its controls.
function psdpopupmenu_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to psdpopupmenu (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
