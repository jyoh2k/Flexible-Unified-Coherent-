function varargout = Tbps_coherent(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tbps_coherent_OpeningFcn, ...
                   'gui_OutputFcn',  @Tbps_coherent_OutputFcn, ...
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


function Tbps_coherent_OpeningFcn(hObject, eventdata, handles, varargin)
handles.tgroup = uitabgroup('Parent', handles.figure1,'TabLocation', 'top');
handles.tab1 = uitab('Parent', handles.tgroup, 'Title', 'Main');
handles.tab2 = uitab('Parent', handles.tgroup, 'Title', 'Filter'); 
handles.tab3 = uitab('Parent', handles.tgroup, 'Title', 'TXParameter'); 
handles.tab4 = uitab('Parent', handles.tgroup, 'Title', 'RXParameter');
handles.tab5 = uitab('Parent', handles.tgroup, 'Title', 'PSD');
set(handles.uipanel1,'Parent',handles.tab1)
set(handles.uipanel2,'Parent',handles.tab2)
set(handles.uipanel5,'Parent',handles.tab3)
set(handles.uipanel3,'Parent',handles.tab4)
set(handles.uipanel15,'Parent',handles.tab5)
set(handles.uipanel2,'position',get(handles.uipanel1,'position'));
set(handles.uipanel5,'position',get(handles.uipanel1,'position'));
set(handles.uipanel3,'position',get(handles.uipanel1,'position'));
set(handles.uipanel15,'position',get(handles.uipanel1,'position'));

handles.output = hObject;
if nargin < 4
[sims, params] = DefaultSet( 6  )  ;
else
    [sims, params] = DefaultSet( 6  )  ;
%     params = varargin{2};
end
handles.sims =sims;
handles.params =params;

handles.sims.const_axes{1} = handles.const_axes1;
handles.sims.const_slider(1) = handles.const_slider1;
handles.sims.const_axes{2} = handles.const_axes2;
handles.sims.const_slider(2)= handles.const_slider2;
handles.sims.psd_axes = handles.axes3;
handles.sims.psd_text = handles.text20;
handles.sims.ber_axes = handles.axes4;
handles.sims.tau_axes = handles.axes5;
handles.sims.cpr_axes = handles.axes6;
handles.sims.sync_axes = handles.axes7;
handles.sims.sync_axes1 = handles.axes8;
handles.sims.figure_handle = handles;
handles.sims.psdhandle.figure1 = handles;
handles.sims.evm_text          = handles.edit5_1;
handles.sims.cpr_text          = handles.cpr_text;
handles.sims.const_text(1)     = handles.text17;
handles.sims.const_text(2)     = handles.text19;
handles.sims.consthandle(1).figure1= handles;
handles.sims.consthandle(2).figure1= handles;
handles.sims.consthandle(1).popupmenu1= handles.popupmenu1;
handles.sims.consthandle(2).popupmenu1= handles.popupmenu2;
handles.sims.dfe_axes{1} = handles.axes2_1;
handles.sims.dfe_axes1(1) = handles.axes2_2;
handles.sims.dfe_axes{2} = handles.axes2_3;
handles.sims.dfe_axes1(2) = handles.axes2_4;
handles.sims.dfe_axes{3} = handles.axes2_5;
handles.sims.dfe_axes1(3) = handles.axes2_6;
handles.sims.dfe_axes{4} = handles.axes2_7;
handles.sims.dfe_axes1(4) = handles.axes2_8;
handles.sims.dfe1_axes{1} = handles.axes3_1;
handles.sims.dfe1_axes1(1) = handles.axes3_2;
handles.sims.dfe1_axes{2} = handles.axes3_3;
handles.sims.dfe1_axes1(2) = handles.axes3_4;
handles.sims.dfe1_axes{3} = handles.axes3_5;
handles.sims.dfe1_axes1(3) = handles.axes3_6;
handles.sims.dfe1_axes{4} = handles.axes3_7;
handles.sims.dfe1_axes1(4) = handles.axes3_8; 
handles.sims.ber0_axes     = handles.ber0_axes; 
handles.sims.evm0_axes     = handles.evm0_axes; 
handles.sims.psd0_axes     = handles.psd_axes; 
handles.sims.plothandle{1}.axes1     = handles.ber0_axes;
handles.sims.plothandle{2}.axes1     = handles.evm0_axes;
handles.sims.plothandle{1}.text1     = handles.ber0_text;
handles.sims.plothandle{2}.text1     = handles.evm0_text;
handles.sims.plot_axes{1}     = handles.ber0_axes;
handles.sims.plot_axes{2}     = handles.evm0_axes;

handles.sims.psdhandle.popupmenu1= handles.popupmenu3;
handles.paramhandle ='';
set( handles.popupmenu1, 'String', {'Equalized' 'Received' 'After TPR' 'After Eq1' 'After CFE' 'After CPR' 'After CPR Sync'  'EyeDiagram' 'Level Analysis'  'All' '2D' });
set( handles.popupmenu2, 'String', {'Equalized' 'Received' 'After TPR' 'After Eq1' 'After CFE' 'After CPR' 'After CPR Sync'  'EyeDiagram' 'Level Analysis'  'All' '2D' });
run_10 = ['Run-' num2str(handles.sims.max_num_sim)];
set( handles.RunSbutton, 'String', {'Run' 'Stop' run_10 'Reset' 'Rerun' 'Stop on error' 'Run-1' }); 

set( handles.pushbutton1, 'Style', 'popupmenu'); 
set( handles.pushbutton1, 'String', {'Frequency response' 'Param save' 'Param load' });

set( handles.text0_3, 'String', 'Train Modulation');
set( handles.edit0_3, 'Style', 'popupmenu');
set( handles.edit0_3, 'String', {'Reserved' 'QPSK' 'Reserved' '16-QAM' '32-QAM' '64-QAM'}); 
set( handles.text0_4, 'String', 'Pilot type');
set( handles.edit0_4, 'Style', 'popupmenu');
set( handles.edit0_4, 'String', {'Disable' 'Block end' 'Block start' 'Reserved' 'Alamouti'}); 

set( handles.text0_5, 'String', 'Fiber Length(km)');
set( handles.edit0_5, 'Style', 'edit'); 
set( handles.text0_6, 'String', 'PTBC');
set( handles.edit0_6, 'String', { 'Dual Pol' 'PTBC'});
set( handles.edit0_6, 'Value', (handles.params.PTBC +1) );
set( handles.text0_7, 'String', 'TX mapping ');
set( handles.edit0_7, 'Style', 'popupmenu');
set( handles.edit0_7, 'String', {'XI  XQ  YI  YQ' 'YQ  YI  XQ  XI' ...
                                 'XI  XQ  YQ  YI' 'XQ  XI  YI  YQ' ...
                                 'XI  XQ  0   0' 'XQ  XI  0   0 '  ...
                                 '0   0   XI  XQ' ' 0   0   XQ  XI' ...
                                 'XI  XI  XI  XI'  ...
                                 'XI  XQ  XI  XQ'  ...
                                 'XQ  XI  XI  XQ'  ...
                                 'XQ  XI  XQ  XI'  ...
                                 'XI  XQ  XQ  XI'  ...
                                });
set( handles.text0_8, 'String', 'RX mapping ');
set( handles.edit0_8, 'Style', 'popupmenu');
set( handles.edit0_8, 'String', {'CH1  CH2  CH3  CH4 ' 'CH3  CH4  CH1  CH2' ...
                                 'CH1  CH2  ' 'CH2  CH1'   ...
                                 'CH3  CH4  ' 'CH4  CH3'   ...
                                });


set( handles.text0_13, 'String', 'Sweep');
set( handles.edit0_13, 'String', { ...
            'Disable' ...
            'DFE betaf' 'LPF NBandwidth' 'AGC Average'  'RX Roll-off' ...
            'CPR BLK' 'DFE1 betaf'  'TPR K1' 'TPR K2'  'CPR BLK1' ...
             '# FFE tap'  'Reserved' 'Reserved' ...  % 10,11,12
             'Reserved' 'Reserved' 'Reserved' 'Reserved' ...  % 13,14,15,16 
             'Reserved'  'CPR step' 'CPR fstep'  ...  % 17,18,19
             'Pass2Base LPF ' 'Given CFO' 'DFE Npostcursor'   ... % 20, 21, 22 
             'Post emp a(2)'  'Post emp a(3)' 'Post emp b num' ...
             'STBC betaf(1)' 'STBC betab'  'STBC betaf(t)'  'STBC K2'  ... % 26, 27, 28, 29
              'STBC TAU FRAC' 'STBC NFFE'  'STBC betab2' 'Reserved'  ... % 30, 31, 32, 33
              'Reserved' 'Test vector'  ... % 34, 35
             'Reserved' 'Reserved' 'Reserved' ...  %  36, 37, 38 
             'RX Skew(2)' 'RX Skew(3)' 'RX Skew(4)' ...  %  39, 40, 41 
             'TX Skew(2)' 'TX Skew(3)' 'TX Skew(4)' ...  %  42, 43, 44 
             'TX Skew(3,4)'  'RX Skew(3,4)' 'Fine searchlength '   ...  %  45, 46 
             });
set( handles.edit0_13, 'Style', 'popupmenu');
set( handles.edit0_13, 'Value', 1); 
set( handles.text0_14, 'String', 'Range');
set( handles.edit0_14, 'Style', 'edit'); 
set( handles.edit0_14, 'String', '0'); 
set( handles.text0_10, 'String', '# Tr. symbol');
set( handles.text0_11, 'String', '# Data symbol');
set( handles.text0_12, 'String', 'Block size(pilot)');
set( handles.text0_16, 'String', 'Testvector');
set( handles.edit0_16, 'String', '0'); 

set( handles.text0_15, 'String', 'Data file');
set( handles.edit0_15, 'Style', 'pushbutton'); 
set( handles.edit0_15, 'String', '0'); 



global FIXED_ARCHITECTURE;
if ( FIXED_ARCHITECTURE == 1 )
set( handles.text1_17, 'String', 'Fixed type');
set( handles.edit1_17, 'Style', 'popupmenu'); 
set( handles.edit1_17, 'String', {'Fixed architecture' 'Fixed point'}); 

set( handles.text1_18, 'String', 'Tx preemph');
set( handles.edit1_18, 'Style', 'popupmenu'); 
set( handles.edit1_18, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_19, 'String', 'TX Matched filter');
set( handles.edit1_19, 'Style', 'popupmenu'); 
set( handles.edit1_19, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_21, 'String', 'RX DCCancel');
set( handles.edit1_21, 'Style', 'popupmenu'); 
set( handles.edit1_21, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_22, 'String', 'RX AGC');
set( handles.edit1_22, 'Style', 'popupmenu'); 
set( handles.edit1_22, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_23, 'String', 'OFDE');
set( handles.edit1_23, 'Style', 'popupmenu'); 
set( handles.edit1_23, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_24, 'String', 'TPR');
set( handles.edit1_24, 'Style', 'popupmenu'); 
set( handles.edit1_24, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_25, 'String', 'Postemphasis');
set( handles.edit1_25, 'Style', 'popupmenu'); 
set( handles.edit1_25, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_26, 'String', 'Coarse sync');
set( handles.edit1_26, 'Style', 'popupmenu'); 
set( handles.edit1_26, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_27, 'String', 'CFR');
set( handles.edit1_27, 'Style', 'popupmenu'); 
set( handles.edit1_27, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_28, 'String', 'Matched filter');
set( handles.edit1_28, 'Style', 'popupmenu'); 
set( handles.edit1_28, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text1_29, 'String', 'Fine sync');
set( handles.edit1_29, 'Style', 'popupmenu'); 
set( handles.edit1_29, 'String', {'Floating' 'Fixed' 'Write tv'}); 
else 
set( handles.text0_17, 'String', 'RX type');
set( handles.edit0_17, 'Style', 'popupmenu'); 
set( handles.edit0_17, 'String', { 'Dual Pol' 'PTBC'});
set( handles.text0_18, 'String', 'Testmode');
set( handles.edit0_18, 'Style', 'popupmenu'); 
set( handles.edit0_18, 'String', { 'Disable' 'TestMode1'});
set( handles.text0_19, 'String', 'Testmode Framenumber');
set( handles.edit0_19, 'Style', 'edit'); 
set( handles.edit0_19, 'String', '10'); 
set( handles.text0_20, 'String', 'Reset Stat.');
set( handles.edit0_20, 'Style', 'pushbutton'); 
set( handles.edit0_20, 'String', 'Reset Stat.'); 

end 

manusetting(hObject, eventdata, handles);

set( handles.plot2, 'String', {'r' 'g' 'b' 'w' 'y' 'c' 'm' });


set( handles.text1_1, 'String', 'Resampling');
set( handles.edit1_1, 'String', {'PPG' 'Resample(I)'  'resample' 'interpolate' 'fft' 'linear'  'arbitrary' });
set( handles.edit1_1, 'Style', 'popupmenu');
set( handles.text1_7, 'String', 'TX Skew (ps)');
set( handles.edit1_7, 'Style', 'edit');
set( handles.text1_8, 'String', 'AWG correction');
set( handles.edit1_8, 'String', {'Disable' 'Enable'});
set( handles.edit1_8, 'Style', 'popupmenu');


set( handles.text0_25, 'String', 'DFE analysis');
set( handles.edit0_25, 'String', {'Disable' 'Enable'});
set( handles.edit0_25, 'Style', 'popupmenu');

set( handles.text0_26, 'String', 'STBC analysis');
set( handles.edit0_26, 'String', {'Disable' 'Enable'});
set( handles.edit0_26, 'Style', 'popupmenu');

set( handles.text0_27, 'String', 'Constellation analysis');
set( handles.edit0_27, 'String', {'Disable' 'Enable'});
set( handles.edit0_27, 'Style', 'popupmenu');

set( handles.text0_28, 'String', 'TPR analysis');
set( handles.edit0_28, 'String', {'Disable' 'Enable'});
set( handles.edit0_28, 'Style', 'popupmenu');

set( handles.text0_29, 'String', 'CPR analysis');
set( handles.edit0_29, 'String', {'Disable' 'Enable'});
set( handles.edit0_29, 'Style', 'popupmenu');

set( handles.text0_30, 'String', 'Sync analysis');
set( handles.edit0_30, 'String', {'Disable' 'Enable'});
set( handles.edit0_30, 'Style', 'popupmenu');

set( handles.text0_31, 'String', 'BER analysis');
set( handles.edit0_31, 'String', {'Disable' 'Enable'});
set( handles.edit0_31, 'Style', 'popupmenu');


set( handles.text0_32, 'String', 'Spectrum analysis');
set( handles.edit0_32, 'String', {'Disable' 'Enable'});
set( handles.edit0_32, 'Style', 'popupmenu');


set( handles.text2_1, 'String', 'RX Skew (ps)');
set( handles.edit2_1, 'Style', 'edit');

set( handles.text2_2, 'String', 'RX Structure');
%set( handles.edit2_2, 'Value', 0);
set( handles.edit2_2, 'String', {'Blind'  'Data-aided Eq' 'Data-aided (skew)'});
set( handles.edit2_2, 'Style', 'popupmenu');
set( handles.text2_3, 'String', 'GSOP');
set( handles.edit2_3, 'Style', 'popupmenu');
set( handles.edit2_3, 'String', {'Disable'  'Enable'});

set( handles.edit2_9, 'String', {'Disable' 'Enable' 'Seperate'});
set( handles.text2_14, 'String', 'Initial TPR');
set( handles.edit2_14, 'Style', 'popupmenu');
set( handles.edit2_14, 'String', {'Disable'  'Enable'});

set( handles.edit2_16, 'String', {'Disable' 'Sep 2ov', 'Sep 1ov' 'Non 2ov' 'Non 1ov' 'Sep/Sep 2Ov' 'Sep/Sep 1Ov'   });

set( handles.edit3_3, 'String', {'4-th power V-V' '8-th power V-V (16QAM)' '8-th power V-V (16QAM)' 'BPS ' 'Pilot based ' 'Pilot based(AC)'  });

set( handles.text4_7, 'String', 'Skew Comp.');
set( handles.edit4_7, 'Style', 'popupmenu');
set( handles.edit4_7, 'String', {'Disable' 'Real 4x4' 'Widely complex'});
 
set( handles.text6_1, 'String', 'OSC scale(mV)');
set( handles.text6_2, 'String', 'OSC Freq. GSaps');
set( handles.text6_3, 'String', 'Store OSC data');
set( handles.edit6_3, 'Style', 'popupmenu');
set( handles.edit6_3, 'String', {'Disable' 'Always' '10 dataset' });
set( handles.text6_9, 'String', 'Estimate skew'); 
set( handles.edit6_9, 'String', 'Estimate'); 
% set( handles.edit6_9, 'Style', 'pushbutton'); 
set( handles.edit6_9, 'Style', 'popupmenu');
set( handles.edit6_9, 'String', {'Estimate' 'Estimate 0' 'Estimate 90' 'Estimate All' });

set( handles.text6_10, 'String', 'Postemphasis'); 
set( handles.edit6_10, 'String', 'Estimate'); 
set( handles.edit6_10, 'Style', 'popupmenu');
set( handles.edit6_10, 'String', {'STBC '  });
UpdateDisplay(hObject, eventdata, handles);
guidata(hObject, handles);

 


function varargout = Tbps_coherent_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.const_axes1;
varargout{2} = handles.const_slider1;
varargout{3} = handles.const_axes2;
varargout{4} = handles.const_slider2;
varargout{5} = handles.axes3;
varargout{6} = handles.axes4;
varargout{7} = handles.axes5;
varargout{8} = handles.axes6;
varargout{9} = handles.axes7;
varargout{10} = handles.axes8;
varargout{11} = handles;
%varargout{1} = handles.output;


function const_slider1_Callback(hObject, eventdata, handles)
frame = get(handles.figure1,  'UserData');

mapper_list =  QAMMapperList (  frame) ;
signal_str = get( handles.popupmenu1,  'String' );
signal_type = get( handles.popupmenu1,  'Value' ) ;      
frame.upper_right_idx = find(frame.mapper_tx2(1,:) ==frame.upper_right_data);
const_axes = handles.const_axes1;

iInv = get( hObject,  'Value' ) ;
subShowConst(const_axes, frame, signal_str,signal_type,1, mapper_list, iInv );
 
 

function const_slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function popupmenu1_Callback(hObject, eventdata, handles)
frame = get(handles.figure1,  'UserData'); 
signal_str = get( hObject,  'String' );
signal_type = get( hObject,  'Value' ) ;   

if ( strcmp(signal_str{signal_type} ,  'Level Analysis') ) 
    frame = get(handles.figure1,  'UserData');    
    frame.cur_stream = 1;
    GuiLevelAnalysis( 'Genbutton_Callback',  'Level analysis', handles.sims, handles.params, frame);
end
if ( strcmp(signal_str{signal_type} ,  'All') )     
    equalized = frame.recovered2(1,:); 
    mapper_list =  QAMMapperList (  frame) ;
    frame.upper_right_idx = find(frame.mapper_tx2(1,:) ==frame.upper_right_data);
    SubShowConstellationA( equalized,  handles.const_axes1,  frame, 1, mapper_list , 1);
end
if ( strcmp(signal_str{signal_type} ,  '2D') )     
    equalized = frame.recovered2(1,:); 
    %equalized = frame.recovered2(1,frame.params.NTrainingSymbol+1:end); 
    figure;
    count=hist2d(real(equalized(1,:)),imag(equalized(1,:)), 100);
    imagesc( count);
end
if ( strcmp(signal_str{signal_type} ,  'Eyediagram') )
    %frame = get(handles.figure1,  'UserData');
    params = frame.params;
    equalized = frame.recovered2(1,:);
    subShowEyediagram(equalized, params.RXSampleFreq, params.RXoversample);
end

function subShowEyediagram(equalized, RXSampleFreq,RXoversample)

    resample_rate = 10;
    equalized_resample = resample(equalized, resample_rate, 1);
    max_abs = ceil(max(abs(equalized_resample)) * 10 ) * 0.1;
    equalized_resample1 =  equalized_resample/max(abs(equalized_resample));
    eyeObj = commscope.eyediagram('SamplingFrequency', ...
                    RXSampleFreq * resample_rate,  ...
                    'AmplitudeResolution', 0.00500, ...
                    'PlotType', '2D Color', ...
                    'MinimumAmplitude', -max_abs, ...
                    'MaximumAmplitude', max_abs, ...
                    'OperationMode', 'Complex', ...
                    'SamplesPerSymbol', RXoversample * resample_rate );
    eyeObj.update(  equalized_resample);
    eyescope(eyeObj); 
    


function SubShowConstellationA( equalized, const_axes,  frame, synchronized, mapper_list, stridx  )
MaxStep = 1; 
d = floor(1.0/MaxStep*size(equalized,2));
x = ( 1:d );
plot  (const_axes, equalized(:, x), 'y*');
hold(const_axes, 'on');
ylim  (const_axes, [-1.7 1.7]);
xlim  (const_axes, [-1.7 1.7]);
if ( synchronized == 1 )
    upper_right_idx = frame.upper_right_idx ;
    plot  (const_axes, equalized(:, intersect(x,upper_right_idx)), 'go' );
    if ( frame.BER < 0.1 )
        plot  (const_axes, equalized(:, intersect(x, frame.error_const_idx{stridx})), 'm*' );
    end
end
plot  (const_axes, mapper_list, 'ro' );
hold(const_axes, 'off');
default_color(const_axes);



function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function const_slider2_Callback(hObject, eventdata, handles)
frame = get(handles.figure1,  'UserData');

mapper_list =  QAMMapperList (  frame) ;
signal_str = get( handles.popupmenu2,  'String' );
signal_type = get( handles.popupmenu2,  'Value' ) ;      
if ( size( frame.mapper_tx2,1) == 1)
    frame.upper_right_idx = find(frame.mapper_tx2(1,:) ==frame.upper_right_data);
else
    frame.upper_right_idx = find(frame.mapper_tx2(2,:) ==frame.upper_right_data);
end
const_axes = handles.const_axes2;

iInv = get( hObject,  'Value' ) ;
subShowConst(const_axes, frame, signal_str,signal_type,2, mapper_list, iInv);
 

function subShowConst(const_axes, frame, signal_str,signal_type,iaxes, mapper_list, iInv)
synchronized = 0 ;

upper_right_idx = frame.upper_right_idx ; 
if ( strcmp(signal_str{signal_type} ,  'Equalized') )
    equalized = frame.recovered2(iaxes,:);
    synchronized = 1 ;
    upper_right_idx = frame.upper_right_idx ;
    
end
if ( strcmp(signal_str{signal_type} ,  'Received') )
    equalized = frame.received(iaxes,:);
end
if ( strcmp(signal_str{signal_type} ,  'After TPR') )
    equalized = frame.resampledout(iaxes, 1:2:end);
end
if ( strcmp(signal_str{signal_type} ,  'After CFE') )
    equalized = frame.cfo_recovered(iaxes, 1:2:end);
end
if ( strcmp(signal_str{signal_type} ,  'After CPR') )
    equalized = frame.phase_error_recovered(iaxes, 1:2:end);
    synchronized = 1 ;
    upper_right_idx = frame.upper_right_idx ;
end
if ( strcmp(signal_str{signal_type} ,  'After CPR Sync') )
    equalized = frame.phase_error_recovered_sync(iaxes, 1:2:end);
    synchronized = 1 ;
    upper_right_idx = frame.upper_right_idx ;
end
if ( strcmp(signal_str{signal_type} ,  'After CPR0') )
    equalized = frame.phase_error_recovered(iaxes, 1:2:end);
    synchronized = 1 ;
    idx_offset = frame.fsfs.start_of_frame;
    
    upper_right_idx = frame.upper_right_idx ;%+ idx_offset -1 ;
end
if ( strcmp(signal_str{signal_type} ,  'After Eq1') )
    synchronized = 1 ;
    equalized = frame.cfo_recovered_eq(iaxes, 1:2:end);
end
if ( strcmp(signal_str{signal_type} ,  'After FrameStart') )
    equalized = frame.cfo_recovered_sync(iaxes, 1:2:end);
end
Step = 0.05;
MaxStep = 1/Step +1;
% MaxStep = 1;
% iInv = get( hObject,  'Value' ) ;
slider_inv =  floor ( iInv * 1/Step + 0.5 ) +1 ;
d = floor(1.0/MaxStep*size(equalized,2));
x = ( 1:d )+ d*(slider_inv-1);
plot  (const_axes, equalized(:, x), 'y*');
hold(const_axes, 'on');
ylim  (const_axes, [-1.7 1.7]); 
xlim  (const_axes, [-1.7 1.7]); 
if ( synchronized == 1 &&  frame.params.searchfineframe.en ==  1)    
    plot  (const_axes, equalized(:, intersect(x,upper_right_idx)), 'go' );
    if ( frame.BER < 0.1 && frame.BER ~=0 )
        plot  (const_axes, equalized(:, intersect(x, frame.error_const_idx{iaxes})), 'm*' );
    end
end
plot  (const_axes, mapper_list, 'ro' );
hold(const_axes, 'off');
default_color(const_axes);


function const_slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function popupmenu2_Callback(hObject, eventdata, handles)
frame = get(handles.figure1,  'UserData'); 
signal_str = get( hObject,  'String' );
signal_type = get( hObject,  'Value' ) ;   

if ( strcmp(signal_str{signal_type} ,  'Level Analysis') ) 
    frame = get(handles.figure1,  'UserData');
    frame.cur_stream = 2;
    GuiLevelAnalysis( 'Genbutton_Callback',  'Level analysis', handles.sims, handles.params, frame);
end
if ( strcmp(signal_str{signal_type} ,  'All') )     
    equalized = frame.recovered2(2,:); 
    mapper_list =  QAMMapperList (  frame) ;
    frame.upper_right_idx = find(frame.mapper_tx2(2,:) ==frame.upper_right_data);
    SubShowConstellationA( equalized,  handles.const_axes2,  frame, 1, mapper_list, 2);
end
if ( strcmp(signal_str{signal_type} ,  '2D') )     
    equalized = frame.recovered2(2,:); 
    %equalized = frame.recovered2(2,frame.params.NTrainingSymbol+1:end); 
    figure;
    count=hist2d(real(equalized(1,:)),imag(equalized(1,:)), 100);
    imagesc( count);
end
if ( strcmp(signal_str{signal_type} ,  'Eyediagram') )
    %frame = get(handles.figure1,  'UserData');
    params = frame.params;
    equalized = frame.recovered2(2,:);
    subShowEyediagram(equalized, params.RXSampleFreq, params.RXoversample);
end

function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu3_Callback(hObject, eventdata, handles)
signals = get(handles.figure1,  'UserData');

signal_str = get( hObject,  'String' );
signal_type = get( hObject,  'Value' ) ;  
psd_axes = handles.axes3;
Welch =1;
if ( strcmp(signal_str{signal_type} ,  'Received(X)') )
    in = signals.received(1,:);
    Rs = handles.params.OSCFreq;
end
if ( strcmp(signal_str{signal_type} ,  'Received(Y)') )
    in = signals.received(2,:);
    Rs = handles.params.OSCFreq; 
end
if ( strcmp(signal_str{signal_type} ,  'Transmitted(X)') )
    in = signals.txsignal.txout(1,:);
    Rs = handles.params.TXSampleFreq; 
end
if ( strcmp(signal_str{signal_type} ,  'Transmitted(Y)') )
    in = signals.txsignal.txout(2,:);
    Rs = handles.params.TXSampleFreq; 
end
if ( strcmp(signal_str{signal_type} ,  'PostEmphasis') )
    in = signals.postemphasis(1,:); Rs = handles.params.OSCFreq; 
end
if ( strcmp(signal_str{signal_type} ,  'Matched Filter out') )
    in = signals.in_filter(1,:); Rs = handles.params.RXSampleFreq; 
end

draw_psd ( psd_axes, in, Rs, Welch);
grid(psd_axes,'on');
default_color(psd_axes);

function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function draw_psd (axes, in, Rs, Welch)
% if ( version('-release') == '2019a' )
if ( Welch == 0 )
        [pxx,w] = periodogram(in);
    freq = fftshift(fft(in));
    pxx = abs(freq);
    w=[-Rs/2:Rs/length(in): Rs/2-Rs/length(in)];
    plot  ( axes, w,mag2db(pxx/max(pxx)), 'y');
else
%     Hs=spectrum.periodogram;
    Hs=spectrum.welch;
%     psd(Hs,in(1,:), 'Fs',Rs, 'CenterDC', 1)
    Hpsd = psd(Hs, in(1,:), 'Fs', Rs, 'CenterDC', 1);
    Pw=Hpsd.Data;
    Fw=Hpsd.Frequencies;
    plot(axes, Fw,mag2db(Pw), 'y', 'LineWidth', 2);
%     global SW_PATH;
%     save( [SW_PATH '/Results/Spectrum/Pw.mat'], 'Pw');
end




% --- Executes on button press in RunSbutton.
function RunSbutton_Callback(hObject, eventdata, handles)
global SW_DEBUG_ONLY

if ( get( hObject, 'Value') == 2 || get( hObject, 'Value') == 4 )
    pause(0.1);
    return
end


[handles.sims, handles.params] = update_ParameterSet(hObject, eventdata, handles);
disp2(handles.sims.logfile, 'Parameter updated');
 
sims = handles.sims ;
params = handles.params ; 
%sims.testvector = testvector;

if ( params.RXDSP_PTBC == 1 )
params.NRXStream = 1;
else 
params.NRXStream = 2;
end  
[sims, params]=  ReInit ( sims, params  ); 
guidata(hObject, handles);
pause(0.5); 

simout.out = zeros(1,2);
sims.en_disp_result =2;
for simseq=1:length(sims.X_coor)
    [sims, params]=  SweepSim ( sims, params, simseq  );
   
    handles.sims = sims;
    handles.params = params;
    UpdateDisplay(hObject, eventdata, handles);
    guidata(hObject, handles);
    pause(0.5);

    %-------------------- Generate TX or read tx pattern  --------------------------
    if ( params.AWGResampleMethod == 0 )
         [txsignal, params] = SelPtnFile ( sims.testvector, sims, params );
    else
        if ( sims.gen_tx == 1 && testvector == 0 )
            [txout,  txsignal]= TxTop( sims, params, 0 ) ;
            txsignal = GenAWG( txsignal, handles.sims.txdata_file , sims, params);
            frameout.txsignal = txsignal;
            set( handles.figure1, 'UserData', frameout);
            guidata(hObject, handles);
            pause(5);
        else
            if ( simseq == 1 )
                [txsignal, params] = SelPtnFile ( sims.testvector, sims, params );
            end
        end
    end
                 
    %-------------------- RX Top                          --------------------------
    idx=1; EVM_best = 0;
    while( get( hObject, 'Value') ~= 2  && ( get( hObject, 'Value') ~= 5 ||  idx ==1 ))
        pause(0.5);
        if ( get( hObject, 'Value') == 5  )
            [channelout]       = handles.channelout;
        else
            [channelout]       = SelTestVector( sims.testvector, idx, sims, params ) ;
            handles.channelout = channelout;        
            guidata(hObject, handles);
        end
        [recovered, frameout, sims] =  RxTop( channelout, txsignal, sims, params) ; 
        if ( params.testmode ~= 1)
            simout             = SimAnalysis( sims, simout, frameout, idx );   
            simout.out(simseq, 1) = mean(simout.BER);
            simout.out(simseq, 2) = mean(simout.EVM); 
        end 
        if ( sims.mode == 0 ) 
            sims .X_val= idx;
        end 
        disp_result(simout, frameout, sims, params);
        % if ( mean(frameout.EVM) < EVM_best    )
            % params.dfe.filtertap =frameout.dfeout.filtercoef;   
            % EVM_best = mean(frameout.EVM);
        % end
        if ( get( hObject, 'Value') == 3 && idx >=  sims.max_num_sim  )
            break;
        end
        if ( get( hObject, 'Value') == 6 && idx >=  2  )
            if (  frameout.BER > 0.004)
                break;
            end
        end
        if ( get( hObject, 'Value') == 7  )
            break;
        end
        idx = idx + 1;
        if ( get( hObject, 'Value') == 4  )
            idx = 1;
            set( hObject, 'Value', 1) ;
        end
    end % while( get( hObject, 'Value') ~= 2  
end % for simseq=1:length(sims.X_coor)
%if ( simseq ~= 1)    
    sims.en_disp_result =1;
    disp_result(simout, frameout, sims, params);
%end


handles.sims = sims;
handles.params = params; 
handles.frameout = frameout;
draw_sweep (hObject, eventdata, handles, simout);
guidata(hObject, handles);
set( hObject, 'Value', 1);


function   draw_sweep (hObject, eventdata, handles, simout)
draw_new_plot = get( handles.plot1, 'Value') ; 
color_list =[ 'r' 'g' 'b' 'w' 'y'  'c' 'm'];  
color = color_list( get( handles.plot2, 'Value') );
if ( length(handles.sims.X_coor) > 2 )
    handles.sims.plot_mode  =1 ;
    handles.sims.Ylabel ='BER';
%     handles.sims.plothandle{1}.text1 = 'BER';
    simout.color =[color 's-'];
    simout.title =handles.sims.Ylabel;
    simout.legend =handles.sims.Xlabel;
    DrawSimout( simout, handles.sims, handles.params, draw_new_plot);

    handles.sims.plot_mode  =2 ;
    handles.sims.Ylabel ='EVM';
%     handles.sims.plothandle{1}.text1 = 'BER';
    simout.color =[color 'o-'];
    simout.title =handles.sims.Ylabel;
    simout.legend =handles.sims.Xlabel;
    DrawSimout( simout, handles.sims, handles.params, draw_new_plot);

end


function pushbutton1_Callback(hObject, eventdata, handles)
if ( get( hObject, 'Value') == 1  )
    handles.freqhandle= FrequencyResponse_SineSweep( 'pushbutton2_Callback',  'Freq Res', handles.sims, handles.params);
end
if ( get( hObject, 'Value') == 2  ) % Save
    global SW_PATH;
    [FileName, PathName] = uiputfile([ SW_PATH './InitFiles/*.mat']);
    if isequal(FileName,0) || isequal(PathName,0)
        disp2(handles.sims.logfile, 'User clicked Cancel.')
    else
        params1 = handles.params;
        save([PathName, FileName],  'params1');
        disp2(handles.sims.logfile, ['Saved in File ', FileName]);
    end
end
if ( get( hObject, 'Value') == 3  ) % Load
    global SW_PATH;
    [FileName, PathName] = uigetfile([ SW_PATH './InitFiles/*.mat']);
    if isequal(FileName,0) || isequal(PathName,0)
        disp2(handles.sims.logfile, 'User clicked Cancel.')
    else
        disp2(handles.sims.logfile, ['Loading File ', FileName]);
        load (  [PathName,FileName] );
        handles.params = params1;
    end
    UpdateDisplay(hObject, eventdata, handles);
    guidata(hObject, handles);
end
manusetting(hObject, eventdata, handles);
set( hObject, 'Value',1);
guidata(hObject, handles);





function val = get_value(handles1)
val = get(handles1, 'Value');

function val = get_string(handles1)
val = str2num(get(handles1, 'String'));

function val_list = get_regexp(handles1)
str = get(handles1, 'String');
if ( size( regexp( str, ':'),1) ~= 0 )
   index  =regexp( str, ':', 'split');
   val_list = str2num(index{1}):str2num(index{2}):str2num(index{3});
else
   val_list = str2num(str);
end 


function sims = get_simmode(sims,mode)
sims.mode  = mode;
if ( sims.mode == 0 )
    sims.X_coor            = 0;
end


function [sims, params] = update_ParameterSet(hObject, eventdata, handles)
GHz=1e9;MHz=1e6;km=1e3;
handles.params.Nbitspersymbol  = get_value (handles.edit0_1);
handles.params.BaudFreq        = get_string(handles.edit0_2) * GHz;
handles.params.Nbitspersymbol_Tr  = get_value (handles.edit0_3);
handles.params.en_block_termination = get_value(handles.edit0_4)-1;
%handles.params.fec.en          = get_value(handles.edit0_3) -1 ;
%if( handles.params.fec.en  == 2 )
    %handles.params.fec.en   = 1;
    %handles.params.fec.FEC_mode =0;
%end
%handles.params.ps.en           = get_value(handles.edit0_4) -1 ;
%handles.params.cfr.CFEtype     = get_value(handles.edit0_6)  ;
handles.sims.channel.fiber_length      = get_string(handles.edit0_5) *km  ;
if ( get_string(handles.edit0_5) ~= 0 )
    handles.params.OFDE.en = 1;
else 
    handles.params.OFDE.en = 0;
end
handles.params.TXmapping       = get_value(handles.edit0_7);
handles.params.RXmapping       = get_value(handles.edit0_8);

handles.params.NTXStream         = get_string(handles.edit0_9);
handles.params.NRXStream         = handles.params.NTXStream;
handles.params.NTrainingSymbol   = get_string(handles.edit0_10);
handles.params.NDataSymbol           = get_string(handles.edit0_11);
handles.params.NSymbol           = handles.params.NTrainingSymbol +handles.params.NDataSymbol; 
handles.params.block_size        = get_string(handles.edit0_12);
% handles.sims.mode              = get_value(handles.edit0_13) ;

handles.sims.X_coor            = get_regexp(handles.edit0_14) ;
handles.sims                   = get_simmode( handles.sims,get_value(handles.edit0_13)-1);
handles.sims.dataf.data_file = get(handles.edit0_15, 'UserData');
handles.sims.testvector          = get_string(handles.edit0_16);

global FIXED_ARCHITECTURE;
if (FIXED_ARCHITECTURE == 1 )
handles.params.fixed_type        = get_value(handles.edit1_17)-1;
handles.params.txpreemp.fixed_bit  = get_value(handles.edit1_18)-1;
handles.params.TXMatchedfilter.fixed_bit  = get_value(handles.edit1_19)-1;
handles.params.DCCancel.fixed_bit= get_value( handles.edit1_21) -1;
handles.params.AGC.fixed_bit     = get_value( handles.edit1_22) -1;
handles.params.OFDE.fixed_bit    = get_value( handles.edit1_23) -1;
handles.params.tpr.fixed_bit     = get_value( handles.edit1_24) -1;
handles.params.rxpostemp.fixed_bit    = get_value( handles.edit1_25) -1;
handles.params.searchframe.fixed_bit    = get_value( handles.edit1_26) -1;
handles.params.cfr.fixed_bit    = get_value( handles.edit1_27) -1;
handles.params.RXMatchedfilter.fixed_bit    = get_value( handles.edit1_28) -1 ;
handles.params.searchfineframe.fixed_bit    = get_value( handles.edit1_29) -1;
if ( params.RXDSP_PTBC == 1)
handles.params.stbc.fixed_bit    = get_value( handles.edit1_30) -1;
handles.params.cpr.fixed_bit    = get_value( handles.edit1_31) -1;
handles.sims.write_tv           = get_value( handles.edit1_32) -1;
else
handles.params.dfe.fixed_bit    = get_value( handles.edit1_30) -1;
handles.params.cpr.fixed_bit    = get_value( handles.edit1_31) -1;
end 
else 
handles.params.RXDSP_PTBC        = get_value(handles.edit0_17)-1;
handles.params.testmode          = get_value(handles.edit0_18)-1;
handles.params.NFrames          = get_string(handles.edit0_19);
end
 

handles.params.TXSampleFreq = handles.params.BaudFreq  * 2;
handles.params.AWGResampleMethod =get_value(handles.edit1_1) -1 ;
handles.params.AWGSampleFreq = get_string(handles.edit1_2) *GHz;
handles.params.TXMatchedfilter.en           = get_value(handles.edit1_3) -1 ;
handles.params.TXMatchedfilter.alpha = get_string(handles.edit1_4) ; 
% handles.params.TXUpsampling.en       = get_value(handles.edit1_7)-1 ; 

txskew            = get_string( handles.edit1_7) ;
txskew_ps(1) = complex(0, txskew(1));
if ( length(txskew) >  1)
    txskew_ps(2) = complex(txskew(2), txskew(3));
end
handles.params.txskew.skew_ps = txskew_ps;

handles.params.AWGcorrection =get_value(handles.edit1_8) -1 ;
handles.sims.show_dfe =get_value(handles.edit0_25) -1 ;
handles.sims.show_stbc =get_value(handles.edit0_26) -1 ;
handles.sims.show_constellation =get_value(handles.edit0_27) -1 ;
handles.sims.show_tpr =get_value(handles.edit0_28) -1 ;
handles.sims.show_cpr =get_value(handles.edit0_29) -1 ;
handles.sims.show_sync =get_value(handles.edit0_30) -1 ;

handles.sims.txdata_file = get(handles.edit1_6, 'UserData');


rxskew            = get_string( handles.edit2_1) ;
rxskew_ps(1) = complex(0, rxskew(1));
if ( length(rxskew) >  1)
    rxskew_ps(2) = complex(rxskew(2), rxskew(3));
end
handles.params.skew.skew_ps = rxskew_ps;
handles.params.RXSampleFreq    = handles.params.BaudFreq   * 2;

handles.params.RXStructure   = get_value( handles.edit2_2) -1 ;
handles.params.gsop.en       = get_value( handles.edit2_3) -1 ;
handles.params.RXMatchedfilter.en    = get_value( handles.edit2_4) -1 ;
handles.params.RXMatchedfilter.alpha = get_string( handles.edit2_5);
% alpha=handles.params.RXMatchedfilter.alpha ;       
% resp_sample =8; 
% os_factor = handles.params.RXoversample;
% handles.params.RXMatchedfilter.time_resp =  SRRC( os_factor,alpha, resp_sample);
             
handles.params.rxpostemp.en            = get_value( handles.edit2_6) -1;
handles.params.AGC.en            = get_value( handles.edit2_7) -1;
handles.params.DCCancel.en       = get_value( handles.edit2_8) -1;

handles.params.tpr.en            = get_value( handles.edit2_9) >1;
handles.params.tpr.seperate_tpr  = get_value( handles.edit2_9) == 3;
handles.params.tpr.TPEtype       = get_value( handles.edit2_10);
handles.params.tpr.L             = get_string( handles.edit2_11);
handles.params.tpr.K1            = get_string( handles.edit2_12);
handles.params.tpr.K2            = get_string( handles.edit2_13);
handles.params.tpr.cal_init_tpr  = get_value( handles.edit2_14)-1;
handles.params.tpr.settling_time = get_string( handles.edit2_15);

handles.params.searchfineframe.type = get_value( handles.edit2_16)-2;
handles.params.searchfineframe.en = 1;
if ( get_value( handles.edit2_16) == 1 )
handles.params.searchfineframe.en = 0;
end

handles.params.searchframe.en = handles.params.searchfineframe.en;

handles.params.cpr.en      = get_value( handles.edit3_1) -1;
handles.params.cpr.PCtype2 = get_value( handles.edit3_2);
handles.params.cpr.CPEtype = get_value( handles.edit3_3);
handles.params.cpr.PCtype  = get_value( handles.edit3_4);
handles.params.cpr.STEP    = get_string( handles.edit3_5);
handles.params.cpr.BLK     = get_string( handles.edit3_6);
handles.params.cpr.fCPEtype= get_value( handles.edit3_7);
handles.params.cpr.fPCtype = get_value( handles.edit3_8);
handles.params.cpr.fSTEP   = get_string( handles.edit3_9);
handles.params.cpr.fBLK    = get_string( handles.edit3_10);

handles.params.cfr.en      = get_value( handles.edit3_11) -1;
handles.params.cfr.CarrierFreqOff =  get_string( handles.edit3_12) * MHz;
handles.params.cfr.CPEtype = get_value( handles.edit3_13);
handles.params.cfr.PCtype  = get_value( handles.edit3_14);
handles.params.cfr.STEP    = get_string( handles.edit3_15);
handles.params.cfr.BLK     = get_string( handles.edit3_16);


handles.params.dfe.en  = get_value( handles.edit4_1) -1;
handles.params.dfe.is_training_seq_init =0;
if( handles.params.dfe.en  == 2 )
    handles.params.dfe.en   = 1;
    handles.params.dfe.is_training_seq_init =1;
end
handles.params.dfe.type = get_value( handles.edit4_2);
handles.params.dfe.update_type = get_value( handles.edit4_3);
handles.params.dfe.Nffe = get_string( handles.edit4_4);
handles.params.dfe.betaf = get_string( handles.edit4_6);
%handles.params.dfe.lambda = get_string( handles.edit4_7);
handles.params.dfe.skewcomp_en = get_value( handles.edit4_7)-1;
handles.params.dfe.PRL = get_string( handles.edit4_8);
if ( get_string( handles.edit4_5) == 0 )
    handles.params.dfe.betab = 0 ;
    handles.params.dfe.Nfbe = 1;
else
    handles.params.dfe.betab = handles.params.dfe.betaf ;
    handles.params.dfe.Nfbe = get_string( handles.edit4_5) ;
end

if ( handles.params.RXDSP_PTBC == 0)

    handles.params.dfe1.en  = get_value( handles.edit4_9) -1;
    handles.params.dfe1.is_training_seq_init =0;
    if( handles.params.dfe1.en  == 2 )
        handles.params.dfe1.en   = 1;
        handles.params.dfe1.is_training_seq_init =1;
    end
     
    handles.params.dfe1.type = get_value( handles.edit4_10);
    handles.params.dfe1.update_type = get_value( handles.edit4_11);
    handles.params.dfe1.Nffe = get_string( handles.edit4_12);
    handles.params.dfe1.betaf = get_string( handles.edit4_14);
  % handles.params.dfe1.lambda = get_string( handles.edit4_15);
    handles.params.dfe1.skewcomp_en = get_value( handles.edit4_15)-1;
    handles.params.dfe1.PRL = get_string( handles.edit4_16);
    if ( get_string( handles.edit4_13) == 0 )
        handles.params.dfe1.betab = 0 ;
        handles.params.dfe1.Nfbe = 1;
    else
        handles.params.dfe1.betab = handles.params.dfe1.betaf ;
        handles.params.dfe1.Nfbe =get_string( handles.edit4_13);
    end
else
    %handles.params.cpr.window = get_string( handles.edit4_7) ;
    %handles.params.cpr.interval = get_string( handles.edit4_8) ;

    handles.params.stbc.en  = get_value( handles.edit4_9) -1;
    handles.params.stbc.is_training_seq_init = 0;
    if( handles.params.stbc.en  == 2 )
        handles.params.stbc.en   = 1;
        handles.params.stbc.is_training_seq_init =1;
    end
    handles.params.stbc.h_init_en  = get_value( handles.edit4_10) -1;
    bps  = get_string( handles.edit4_11) ;
    handles.params.stbc.BPS_window = bps(1);
    handles.params.stbc.BPS_step   = bps(2);
    handles.params.stbc.BPS_range  = bps(3);
    handles.params.stbc.rx_in_org    = get_value( handles.edit4_12)-1 ;
    handles.params.stbc.Nffe  = get_string( handles.edit4_13) ;
    handles.params.stbc.betaf  = get_string( handles.edit4_14) ;
    betab  = get_string( handles.edit4_15) ;
    handles.params.stbc.betab  = betab(1);
    handles.params.stbc.betab2 = betab(2);
    handles.params.stbc.PRL  = get_string( handles.edit4_16) ;
end 

handles.params.OSCScale = get_string( handles.edit6_1);
handles.params.OSCFreq         = get_string( handles.edit6_2)*GHz; 
handles.sims.store_data                = get_value( handles.edit6_3) -1;
handles.sims.dataf.data_file = handles.sims.dataf.data_file ;
sims=handles.sims;
params=handles.params;
guidata(hObject, handles);


 

 
function UpdateDisplay(hObject, eventdata, handles)
params = handles.params;
sims = handles.sims;
GHz=1e9;MHz=1e6;km=1e3;
set( handles.edit0_1, 'Value', params.Nbitspersymbol);
set( handles.edit0_2, 'String', num2str(params.BaudFreq/GHz));
set( handles.edit0_3, 'Value', params.Nbitspersymbol_Tr);
set( handles.edit0_4, 'Value', params.en_block_termination +1);
set( handles.edit0_5, 'String', num2str(sims.channel.fiber_length/km));
set( handles.edit0_6, 'Value', params.PTBC + 1 );
set( handles.edit0_7, 'Value', params.TXmapping );
set( handles.edit0_8, 'Value', params.RXmapping );
set( handles.edit0_9, 'String', num2str(params.NTXStream) );
set( handles.edit0_10, 'String', num2str(params.NTrainingSymbol));
set( handles.edit0_11, 'String', num2str(params.NDataSymbol));
set( handles.edit0_12, 'String', num2str(params.block_size));
set( handles.edit0_15, 'String', sims.dataf_filename);
set( handles.edit0_15, 'UserData',  sims.dataf.data_file);

global FIXED_ARCHITECTURE;
if (FIXED_ARCHITECTURE == 1 )
set( handles.edit0_17, 'Value', (params.fixed_type)+1);
set( handles.edit0_18, 'Value', (params.txpreemp.fixed_bit)+1);
set( handles.edit0_19, 'Value', (params.TXMatchedfilter.fixed_bit)+1);
set( handles.edit0_21, 'Value', (params.DCCancel.fixed_bit)+1);
set( handles.edit0_22, 'Value', (params.AGC.fixed_bit)+1);
set( handles.edit0_23, 'Value', (params.OFDE.fixed_bit)+1);
set( handles.edit0_24, 'Value', (params.tpr.fixed_bit)+1);
set( handles.edit0_25, 'Value', (params.rxpostemp.fixed_bit)+1);
set( handles.edit0_26, 'Value', (params.searchframe.fixed_bit)+1);
set( handles.edit0_27, 'Value', (params.cfr.fixed_bit)+1);
set( handles.edit0_28, 'Value', (params.RXMatchedfilter.fixed_bit)+1);
set( handles.edit0_29, 'Value', (params.searchfineframe.fixed_bit)+1);
if (params.RXDSP_PTBC == 1)
set( handles.edit0_30, 'Value', (params.stbc.fixed_bit)+1);
set( handles.edit0_31, 'Value', (params.cpr.fixed_bit)+1);
set( handles.edit0_32, 'Value', (sims.write_tv )+1);
else
set( handles.edit0_30, 'Value', (params.dfe.fixed_bit)+1);
set( handles.edit0_31, 'Value', (params.cpr.fixed_bit)+1);
end 
else 
set( handles.edit0_17, 'Value', (params.RXDSP_PTBC)+1);
set( handles.edit0_18, 'Value', (params.testmode)+1);
set( handles.edit0_19, 'String', num2str(params.NFrames));
end

 

set( handles.edit1_1, 'Value', ( params.AWGResampleMethod)+1);
set( handles.edit1_2, 'String', num2str( params.AWGSampleFreq/GHz));
set( handles.edit1_3, 'Value', ( params.TXMatchedfilter.en + 1));
set( handles.edit1_4, 'String', num2str( params.TXMatchedfilter.alpha)); 
set( handles.edit1_6, 'String', sims.txdata_filename);
set( handles.edit1_6, 'UserData',  sims.txdata_file); 
txskew = num2str(imag(params.txskew.skew_ps(1)));
if ( length(params.txskew.skew_ps) ~= 1)
    txskew = [txskew  '  ' num2str(real(params.txskew.skew_ps(2)))];
    txskew = [txskew '  ' num2str(imag(params.txskew.skew_ps(2)))];
end 
set( handles.edit1_7, 'String', txskew);
set( handles.edit1_8, 'Value', ( params.AWGcorrection)+1);
set( handles.edit0_25, 'Value', ( sims.show_dfe)+1);
set( handles.edit0_26, 'Value', ( sims.show_stbc)+1);
set( handles.edit0_27, 'Value', ( sims.show_constellation)+1);
set( handles.edit0_28, 'Value', ( sims.show_tpr)+1);
set( handles.edit0_29, 'Value', ( sims.show_cpr)+1);
set( handles.edit0_30, 'Value', ( sims.show_sync)+1);
set( handles.edit0_31, 'Value', ( sims.show_ber)+1);
set( handles.edit0_32, 'Value', ( sims.show_psd)+1);

rxskew = num2str(imag(params.skew.skew_ps(1)));
if ( length(params.txskew.sft) ~= 1)
    rxskew = [rxskew  '  ' num2str(real(params.skew.skew_ps(2)))];
    rxskew = [rxskew '  ' num2str(imag(params.skew.skew_ps(2)))];
end 
set( handles.edit2_1, 'String', rxskew );
% set( handles.edit2_2, 'String', num2str( params.RXSampleFreq/GHz)); 
set( handles.edit2_2, 'Value', ( params.RXStructure+1)); 
set( handles.edit2_3, 'Value', ( params.gsop.en+1)); 
set( handles.edit2_4, 'Value', ( params.RXMatchedfilter.en + 1));
set( handles.edit2_5, 'String', num2str( params.RXMatchedfilter.alpha)); 
set( handles.edit2_6, 'Value', ( params.rxpostemp.en+1)); 
set( handles.edit2_7, 'Value', ( params.AGC.en+1)); 
set( handles.edit2_8, 'Value', ( params.DCCancel.en+1)); 

tpr_en = 1; 
if ( params.tpr.en ==1 )
    tpr_en = 2 + params.tpr.seperate_tpr; 
end
set( handles.edit2_9, 'Value', ( tpr_en ));
set( handles.edit2_10, 'Value', ( params.tpr.TPEtype)); 
set( handles.edit2_11, 'String', num2str( params.tpr.L)); 
set( handles.edit2_12, 'String', num2str( params.tpr.K1)); 
set( handles.edit2_13, 'String', num2str( params.tpr.K2)); 
set( handles.edit2_14, 'Value', ( params.tpr.cal_init_tpr +1)); 
set( handles.edit2_15, 'String', num2str( params.tpr.settling_time));  

en = params.searchfineframe.type * params.searchfineframe.en ;
en = en + params.searchfineframe.en ;
set( handles.edit2_16, 'Value', en +1 );



set( handles.edit3_1, 'Value', ( params.cpr.en +1)); 
set( handles.edit3_2, 'Value', ( params.cpr.PCtype2)); 
set( handles.edit3_3, 'Value', ( params.cpr.CPEtype)); 
set( handles.edit3_4, 'Value', ( params.cpr.PCtype)); 
set( handles.edit3_5, 'String', num2str( params.cpr.STEP)); 
set( handles.edit3_6, 'String', num2str( params.cpr.BLK));  
set( handles.edit3_7, 'Value', ( params.cpr.fCPEtype)); 
set( handles.edit3_8, 'Value', ( params.cpr.fPCtype)); 
set( handles.edit3_9, 'String', num2str( params.cpr.fSTEP)); 
set( handles.edit3_10, 'String', num2str( params.cpr.fBLK));  

set( handles.edit3_11, 'Value', ( params.cfr.en + 1));  
set( handles.edit3_12, 'String', num2str(params.cfr.CarrierFreqOff/MHz));  
set( handles.edit3_13, 'Value', ( params.cfr.CPEtype)); 
set( handles.edit3_14, 'Value', ( params.cfr.PCtype)); 
set( handles.edit3_15, 'String', num2str( params.cfr.STEP)); 
set( handles.edit3_16, 'String', num2str( params.cfr.BLK));  


set( handles.edit4_1, 'Value', ( params.dfe.en + params.dfe.is_training_seq_init * params.dfe.en + 1));
set( handles.edit4_2, 'Value', ( params.dfe.type));  
set( handles.edit4_3, 'Value', ( params.dfe.update_type));  
set( handles.edit4_4, 'String', num2str( params.dfe.Nffe));  
if ( params.dfe.betab == 0 )
    set( handles.edit4_5, 'String', num2str( 0));  
else
    set( handles.edit4_5, 'String', num2str( params.dfe.Nfbe));  
end
set( handles.edit4_6, 'String', num2str( params.dfe.betaf));  
%set( handles.edit4_7, 'String', num2str( params.dfe.lambda)); 
set( handles.edit4_7, 'Value', ( params.dfe.skewcomp_en)+1); 
set( handles.edit4_8, 'String', num2str( params.dfe.PRL)); 


if ( params.RXDSP_PTBC == 0)
    set( handles.edit4_9, 'Value', ( params.dfe1.en + params.dfe1.is_training_seq_init * params.dfe1.en + 1));
    set( handles.edit4_10, 'Value', ( params.dfe1.type));  
    set( handles.edit4_11, 'Value', ( params.dfe1.update_type));  
    set( handles.edit4_12, 'String', num2str( params.dfe1.Nffe));  
    if ( params.dfe1.betab == 0 )
        set( handles.edit4_13, 'String', ( 0));  
    else
        set( handles.edit4_13, 'String', num2str( params.dfe1.Nfbe));  
    end
    set( handles.edit4_14, 'String', num2str( params.dfe1.betaf));  
   %set( handles.edit4_15, 'String', num2str( params.dfe1.lambda)); 
    set( handles.edit4_15, 'Value', ( params.dfe1.skewcomp_en)+1); 
    set( handles.edit4_16, 'String', num2str( params.dfe1.PRL));
else

    %set( handles.edit4_7, 'String', num2str(params.cpr.window));
    %set( handles.edit4_8, 'String', num2str(params.cpr.interval));

    set( handles.edit4_12, 'Value', ( params.stbc.rx_in_org)+1);  
    set( handles.edit4_9, 'Value', ( params.stbc.en + params.stbc.is_training_seq_init * params.stbc.en + 1));
    set( handles.edit4_10, 'Value', ( params.stbc.h_init_en)+1);  
    bps  = [ num2str(params.stbc.BPS_window) ' ' ...
             num2str(params.stbc.BPS_step) ' ' ...
             num2str(params.stbc.BPS_range)];
    set( handles.edit4_11, 'String', bps );
    set( handles.edit4_12, 'Value', ( params.stbc.rx_in_org)+1);  
    set( handles.edit4_13, 'String', num2str( params.stbc.Nffe));  
    set( handles.edit4_14, 'String', num2str( params.stbc.betaf, '%1.3g '));  
         
    %if ( params.stbc.update_type == 2 )  
        set( handles.edit4_15, 'String', [num2str( params.stbc.betab) ' ' num2str(params.stbc.betab2)]);  
    %else
        %set( handles.edit4_15, 'String', num2str( params.stbc.betab));  
    %end   
    set( handles.edit4_16, 'String', num2str( params.stbc.PRL));
end 

set( handles.edit6_1, 'String', num2str( params.OSCScale));  
set( handles.edit6_2, 'String', num2str( params.OSCFreq/GHz));
set( handles.edit6_3, 'Value', ( sims.store_data + 1));
handles.sims = sims;
handles.params = params;
guidata(hObject, handles);




 
function Genbutton_Callback(hObject, eventdata, handles) 
[handles.sims, handles.params] = update_ParameterSet(hObject, eventdata, handles);
disp2(handles.sims.logfile, 'Parameter updated');
sims = handles.sims ;
params = handles.params ; 
[sims, params]=  ReInit ( sims, params  );  
handles.sims = sims;
handles.params = params;
guidata(hObject, handles);
[txout,  txsignal]= TxTop( sims, params, 0) ;   
GenAWG( txsignal, handles.sims.txdata_file , sims, params);

function uipushtool1_ClickedCallback(hObject, eventdata, handles)
 global SW_PATH
[FileName, PathName] = uiputfile([ SW_PATH './Results/Figures/SingleCarrier']);
if ( PathName ~= 0 )
    saveas(gcf,  [PathName FileName '.fig' ], 'fig');
    pause(1);
    img =getframe(gcf);
    imwrite(img.cdata, [PathName FileName '.png' ]);
end


function RunSbutton_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_16_Callback(hObject, eventdata, handles)


function edit4_16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_14_Callback(hObject, eventdata, handles)

function edit4_14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_15_Callback(hObject, eventdata, handles)


function edit4_15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_13_Callback(hObject, eventdata, handles)


function edit4_13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_12_Callback(hObject, eventdata, handles)


function edit4_12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_11_Callback(hObject, eventdata, handles)


function edit4_11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_9_Callback(hObject, eventdata, handles)


function edit4_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_10_Callback(hObject, eventdata, handles)


function edit4_10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_8_Callback(hObject, eventdata, handles)


function edit4_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_6_Callback(hObject, eventdata, handles)


function edit4_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_7_Callback(hObject, eventdata, handles)

function edit4_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_5_Callback(hObject, eventdata, handles)


function edit4_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_4_Callback(hObject, eventdata, handles)


function edit4_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_3_Callback(hObject, eventdata, handles)


function edit4_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_1_Callback(hObject, eventdata, handles)


function edit4_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_2_Callback(hObject, eventdata, handles)


function edit4_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_13_Callback(hObject, eventdata, handles)


function edit3_13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_16_Callback(hObject, eventdata, handles)


function edit3_16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_15_Callback(hObject, eventdata, handles)


function edit3_15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_14_Callback(hObject, eventdata, handles)


function edit3_14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_11_Callback(hObject, eventdata, handles)

function edit3_11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_12_Callback(hObject, eventdata, handles)


function edit3_12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_7_Callback(hObject, eventdata, handles)


function edit3_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_10_Callback(hObject, eventdata, handles)


function edit3_10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_9_Callback(hObject, eventdata, handles)


function edit3_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_8_Callback(hObject, eventdata, handles)


function edit3_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_3_Callback(hObject, eventdata, handles)


function edit3_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_6_Callback(hObject, eventdata, handles)

function edit3_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_5_Callback(hObject, eventdata, handles)


function edit3_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_4_Callback(hObject, eventdata, handles)


function edit3_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_1_Callback(hObject, eventdata, handles)

function edit3_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_2_Callback(hObject, eventdata, handles)


function edit3_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_10_Callback(hObject, eventdata, handles)


function edit2_10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_15_Callback(hObject, eventdata, handles)

function edit2_15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_16_Callback(hObject, eventdata, handles)


function edit2_16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_14_Callback(hObject, eventdata, handles)


function edit2_14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_13_Callback(hObject, eventdata, handles)


function edit2_13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_12_Callback(hObject, eventdata, handles)


function edit2_12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_9_Callback(hObject, eventdata, handles)


function edit2_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_11_Callback(hObject, eventdata, handles)


function edit2_11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_3_Callback(hObject, eventdata, handles)


function edit2_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_8_Callback(hObject, eventdata, handles)


function edit2_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_1_Callback(hObject, eventdata, handles)


function edit2_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_7_Callback(hObject, eventdata, handles)


function edit2_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_6_Callback(hObject, eventdata, handles)
if ( get( hObject, 'Value') == 3) 
[FileName,PathName]  = uigetfile([ '*.*']);
if isequal(FileName,0) || isequal(PathName,0)
    disp2(handles.sims.logfile, 'User clicked Cancel.')
else
    disp2(handles.sims.logfile, ['Setting TX File ', FileName,' in Path', PathName]);
    handles.params.rxpostemp.filename = [PathName,FileName];
%     handles.sims.txdata_filename = [FileName];
%     set( hObject, 'String',  handles.sims.txdata_filename);
%     set( hObject, 'UserData',  handles.sims.txdata_file);
    guidata(hObject, handles);
end
end


function edit2_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_5_Callback(hObject, eventdata, handles)


function edit2_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_2_Callback(hObject, eventdata, handles)


function edit2_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_4_Callback(hObject, eventdata, handles)


function edit2_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_9_Callback(hObject, eventdata, handles)


function edit0_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_8_Callback(hObject, eventdata, handles)


function edit0_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_7_Callback(hObject, eventdata, handles)

function edit0_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit0_6_Callback(hObject, eventdata, handles)
handles.params.PTBC      = get_value(hObject)-1;
manusetting(hObject, eventdata, handles);
UpdateDisplay(hObject, eventdata, handles);
guidata(hObject, handles);

function manusetting(hObject, eventdata, handles)
global FIXED_ARCHITECTURE;
if ( FIXED_ARCHITECTURE == 1 )
if (handles.params.RXDSP_PTBC == 1)
set( handles.text0_30, 'String', 'STBC');
set( handles.edit0_30, 'Style', 'popupmenu'); 
set( handles.edit0_30, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text0_31, 'String', 'CPR');
set( handles.edit0_31, 'Style', 'popupmenu'); 
set( handles.edit0_31, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text0_32, 'String', 'FPGA write tv');
set( handles.edit0_32, 'Style', 'popupmenu'); 
set( handles.edit0_32, 'String', {'Disable' 'Write tv'}); 
else
set( handles.text0_30, 'String', 'Equalizer');
set( handles.edit0_30, 'Style', 'popupmenu'); 
set( handles.edit0_30, 'String', {'Floating' 'Fixed' 'Write tv'}); 

set( handles.text0_31, 'String', 'CPR');
set( handles.edit0_31, 'Style', 'popupmenu'); 
set( handles.edit0_31, 'String', {'Floating' 'Fixed' 'Write tv'}); 
end 
end 

if ( handles.params.RXDSP_PTBC == 1)

    set( handles.text4_9, 'String', 'STBC Decoder');
    set( handles.text4_10, 'String', 'Initial H Cal.');
    set( handles.edit4_10, 'Style', 'popupmenu');
    set( handles.edit4_10, 'String', {'Disable' 'Enable' });
    set( handles.text4_11, 'String', 'BPS (W,Test,range]');
    set( handles.edit4_11, 'Style', 'edit');
    set( handles.text4_12, 'String', 'STBC type');
    set( handles.edit4_12, 'Style', 'popupmenu');
    set( handles.edit4_12, 'String', {'New' 'Original' 'New BPS' 'Analytic' 'Org BPS ' 'Ov2' 'Ov2 BPS' });
    set( handles.text4_13, 'String', 'Nffe #tap');
    set( handles.text4_14, 'String', 'amplitude update rate');
    set( handles.text4_15, 'String', 'phase update rate(Pro. Int)');
    set( handles.edit4_15, 'Style', 'edit');
    set( handles.text4_16, 'String', 'PRL');
else 
    set( handles.text4_9, 'String', 'Symbol Eq.');
    set( handles.edit4_9,  'Style', 'popupmenu');
    set( handles.edit4_9,  'String', {'Disable' 'Enable' 'Training Enable' });
    set( handles.text4_10, 'String', 'Equalizer type');
    set( handles.edit4_10,  'Style', 'popupmenu');
    set( handles.edit4_10,  'String', {'LMS' 'CMA' 'MMA' 'RDE' 'RLS' });
    set( handles.text4_11, 'String', 'MIMO type');
    set( handles.edit4_11,  'Style', 'popupmenu');
    set( handles.edit4_11,  'String', {'MIMO' 'Pol demux' 'SISO' });
    set( handles.text4_12, 'String', 'FFE Tap #');
    set( handles.edit4_12, 'Style', 'edit');
    set( handles.text4_13, 'String', 'FBE Tap #');
    set( handles.edit4_13, 'Style', 'edit');
    set( handles.text4_14, 'String', 'Update Rate');
    set( handles.edit4_14, 'Style', 'edit');
    set( handles.text4_15, 'String', 'Skew Comp.');
    set( handles.edit4_15, 'Style', 'popupmenu');
    set( handles.edit4_15, 'String', {'Disable' 'Real 4x4' 'Widely complex'});
    set( handles.text4_16, 'String', 'PRL');
end 
guidata(hObject, handles);

function edit0_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit0_5_Callback(hObject, eventdata, handles)

function edit0_4_Callback(hObject, eventdata, handles)

function edit0_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit0_3_Callback(hObject, eventdata, handles)


function edit0_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_2_Callback(hObject, eventdata, handles)

function edit0_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit0_1_Callback(hObject, eventdata, handles)


function edit0_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_1_Callback(hObject, eventdata, handles)


function edit1_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_7_Callback(hObject, eventdata, handles)

function edit1_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_6_Callback(hObject, eventdata, handles)
[FileName,PathName]  = uiputfile([ '*.*']);
if isequal(FileName,0) || isequal(PathName,0)
    disp2(handles.sims.logfile, 'User clicked Cancel.')
else
    disp2(handles.sims.logfile, ['Setting TX File ', FileName,' in Path', PathName]);
    handles.sims.txdata_file = [PathName,FileName];
    handles.sims.txdata_filename = [FileName];
    set( hObject, 'String',  handles.sims.txdata_filename);
    set( hObject, 'UserData',  handles.sims.txdata_file);
    guidata(hObject, handles);
end





function edit1_4_Callback(hObject, eventdata, handles)


function edit1_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_2_Callback(hObject, eventdata, handles)


function edit1_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_5_Callback(hObject, eventdata, handles)


function edit1_5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_3_Callback(hObject, eventdata, handles)


function edit1_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Tbps_coherent_Callback(hObject, eventdata, handles)
% hObject    handle to Tbps_coherent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit67_Callback(hObject, eventdata, handles)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit67 as text
%        str2double(get(hObject,'String')) returns contents of edit67 as a double


% --- Executes during object creation, after setting all properties.
function edit67_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit68_Callback(hObject, eventdata, handles)
% hObject    handle to edit68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit68 as text
%        str2double(get(hObject,'String')) returns contents of edit68 as a double


% --- Executes during object creation, after setting all properties.
function edit68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit69_Callback(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit69 as text
%        str2double(get(hObject,'String')) returns contents of edit69 as a double


% --- Executes during object creation, after setting all properties.
function edit69_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit70_Callback(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit70 as text
%        str2double(get(hObject,'String')) returns contents of edit70 as a double


% --- Executes during object creation, after setting all properties.
function edit70_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit71_Callback(hObject, eventdata, handles)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit71 as text
%        str2double(get(hObject,'String')) returns contents of edit71 as a double


% --- Executes during object creation, after setting all properties.
function edit71_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu83.
function popupmenu83_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu83 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu83


% --- Executes during object creation, after setting all properties.
function popupmenu83_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu84.
function popupmenu84_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu84 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu84 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu84


% --- Executes during object creation, after setting all properties.
function popupmenu84_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu84 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu85.
function popupmenu85_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu85 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu85 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu85


% --- Executes during object creation, after setting all properties.
function popupmenu85_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu85 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit72_Callback(hObject, eventdata, handles)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit72 as text
%        str2double(get(hObject,'String')) returns contents of edit72 as a double


% --- Executes during object creation, after setting all properties.
function edit72_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit73_Callback(hObject, eventdata, handles)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit73 as text
%        str2double(get(hObject,'String')) returns contents of edit73 as a double


% --- Executes during object creation, after setting all properties.
function edit73_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit74_Callback(hObject, eventdata, handles)
% hObject    handle to edit74 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit74 as text
%        str2double(get(hObject,'String')) returns contents of edit74 as a double


% --- Executes during object creation, after setting all properties.
function edit74_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit74 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit75_Callback(hObject, eventdata, handles)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit75 as text
%        str2double(get(hObject,'String')) returns contents of edit75 as a double


% --- Executes during object creation, after setting all properties.
function edit75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit76_Callback(hObject, eventdata, handles)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit76 as text
%        str2double(get(hObject,'String')) returns contents of edit76 as a double


% --- Executes during object creation, after setting all properties.
function edit76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu86.
function popupmenu86_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu86 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu86 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu86


% --- Executes during object creation, after setting all properties.
function popupmenu86_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu86 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu87.
function popupmenu87_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu87 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu87 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu87


% --- Executes during object creation, after setting all properties.
function popupmenu87_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu87 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu88.
function popupmenu88_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu88 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu88 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu88


% --- Executes during object creation, after setting all properties.
function popupmenu88_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu88 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu89.
function popupmenu89_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu89 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu89 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu89


% --- Executes during object creation, after setting all properties.
function popupmenu89_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu89 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit77_Callback(hObject, eventdata, handles)
% hObject    handle to edit77 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit77 as text
%        str2double(get(hObject,'String')) returns contents of edit77 as a double


% --- Executes during object creation, after setting all properties.
function edit77_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit77 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit78_Callback(hObject, eventdata, handles)
% hObject    handle to edit78 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit78 as text
%        str2double(get(hObject,'String')) returns contents of edit78 as a double


% --- Executes during object creation, after setting all properties.
function edit78_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit78 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu90.
function popupmenu90_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu90 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu90


% --- Executes during object creation, after setting all properties.
function popupmenu90_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu91.
function popupmenu91_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu91 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu91 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu91


% --- Executes during object creation, after setting all properties.
function popupmenu91_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu91 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit79_Callback(hObject, eventdata, handles)
% hObject    handle to edit79 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit79 as text
%        str2double(get(hObject,'String')) returns contents of edit79 as a double


% --- Executes during object creation, after setting all properties.
function edit79_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit79 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu92.
function popupmenu92_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu92 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu92 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu92


% --- Executes during object creation, after setting all properties.
function popupmenu92_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu92 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit80_Callback(hObject, eventdata, handles)
% hObject    handle to edit80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit80 as text
%        str2double(get(hObject,'String')) returns contents of edit80 as a double


% --- Executes during object creation, after setting all properties.
function edit80_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit81_Callback(hObject, eventdata, handles)
% hObject    handle to edit81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit81 as text
%        str2double(get(hObject,'String')) returns contents of edit81 as a double


% --- Executes during object creation, after setting all properties.
function edit81_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu93.
function popupmenu93_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu93 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu93 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu93


% --- Executes during object creation, after setting all properties.
function popupmenu93_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu93 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu94.
function popupmenu94_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu94 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu94 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu94


% --- Executes during object creation, after setting all properties.
function popupmenu94_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu94 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit82_Callback(hObject, eventdata, handles)
% hObject    handle to edit82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit82 as text
%        str2double(get(hObject,'String')) returns contents of edit82 as a double


% --- Executes during object creation, after setting all properties.
function edit82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit83_Callback(hObject, eventdata, handles)
% hObject    handle to edit83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit83 as text
%        str2double(get(hObject,'String')) returns contents of edit83 as a double


% --- Executes during object creation, after setting all properties.
function edit83_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu95.
function popupmenu95_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu95 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu95 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu95


% --- Executes during object creation, after setting all properties.
function popupmenu95_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu95 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu96.
function popupmenu96_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu96 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu96 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu96


% --- Executes during object creation, after setting all properties.
function popupmenu96_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu96 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu97.
function popupmenu97_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu97 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu97 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu97


% --- Executes during object creation, after setting all properties.
function popupmenu97_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu97 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu98.
function popupmenu98_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu98 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu98 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu98


% --- Executes during object creation, after setting all properties.
function popupmenu98_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu98 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit84_Callback(hObject, eventdata, handles)
% hObject    handle to edit84 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit84 as text
%        str2double(get(hObject,'String')) returns contents of edit84 as a double


% --- Executes during object creation, after setting all properties.
function edit84_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit84 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu99.
function popupmenu99_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu99 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu99 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu99


% --- Executes during object creation, after setting all properties.
function popupmenu99_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu99 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit85_Callback(hObject, eventdata, handles)
% hObject    handle to edit85 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit85 as text
%        str2double(get(hObject,'String')) returns contents of edit85 as a double


% --- Executes during object creation, after setting all properties.
function edit85_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit85 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit86_Callback(hObject, eventdata, handles)
% hObject    handle to edit86 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit86 as text
%        str2double(get(hObject,'String')) returns contents of edit86 as a double


% --- Executes during object creation, after setting all properties.
function edit86_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit86 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit87_Callback(hObject, eventdata, handles)
% hObject    handle to edit87 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit87 as text
%        str2double(get(hObject,'String')) returns contents of edit87 as a double


% --- Executes during object creation, after setting all properties.
function edit87_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit87 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu100.
function popupmenu100_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu100 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu100


% --- Executes during object creation, after setting all properties.
function popupmenu100_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit88_Callback(hObject, eventdata, handles)
% hObject    handle to edit88 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit88 as text
%        str2double(get(hObject,'String')) returns contents of edit88 as a double


% --- Executes during object creation, after setting all properties.
function edit88_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit88 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu101.
function popupmenu101_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu101 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu101 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu101


% --- Executes during object creation, after setting all properties.
function popupmenu101_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu101 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu102.
function popupmenu102_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu102 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu102 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu102


% --- Executes during object creation, after setting all properties.
function popupmenu102_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu102 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit89_Callback(hObject, eventdata, handles)
% hObject    handle to edit89 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit89 as text
%        str2double(get(hObject,'String')) returns contents of edit89 as a double


% --- Executes during object creation, after setting all properties.
function edit89_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit89 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu103.
function popupmenu103_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu103 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu103 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu103


% --- Executes during object creation, after setting all properties.
function popupmenu103_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu103 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu104.
function popupmenu104_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu104 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu104 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu104


% --- Executes during object creation, after setting all properties.
function popupmenu104_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu104 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit90_Callback(hObject, eventdata, handles)
% hObject    handle to edit90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit90 as text
%        str2double(get(hObject,'String')) returns contents of edit90 as a double


% --- Executes during object creation, after setting all properties.
function edit90_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit91_Callback(hObject, eventdata, handles)
% hObject    handle to edit91 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit91 as text
%        str2double(get(hObject,'String')) returns contents of edit91 as a double


% --- Executes during object creation, after setting all properties.
function edit91_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit91 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu105.
function popupmenu105_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu105 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu105 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu105


% --- Executes during object creation, after setting all properties.
function popupmenu105_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu105 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit92_Callback(hObject, eventdata, handles)
% hObject    handle to edit92 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit92 as text
%        str2double(get(hObject,'String')) returns contents of edit92 as a double


% --- Executes during object creation, after setting all properties.
function edit92_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit92 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit93_Callback(hObject, eventdata, handles)
% hObject    handle to edit93 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit93 as text
%        str2double(get(hObject,'String')) returns contents of edit93 as a double


% --- Executes during object creation, after setting all properties.
function edit93_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit93 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit94_Callback(hObject, eventdata, handles)
% hObject    handle to edit94 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit94 as text
%        str2double(get(hObject,'String')) returns contents of edit94 as a double


% --- Executes during object creation, after setting all properties.
function edit94_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit94 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu106.
function popupmenu106_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu106 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu106 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu106


% --- Executes during object creation, after setting all properties.
function popupmenu106_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu106 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu107.
function popupmenu107_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu107 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu107 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu107


% --- Executes during object creation, after setting all properties.
function popupmenu107_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu107 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu108.
function popupmenu108_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu108 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu108 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu108


% --- Executes during object creation, after setting all properties.
function popupmenu108_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu108 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit95_Callback(hObject, eventdata, handles)
% hObject    handle to edit95 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit95 as text
%        str2double(get(hObject,'String')) returns contents of edit95 as a double


% --- Executes during object creation, after setting all properties.
function edit95_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit95 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu109.
function popupmenu109_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu109 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu109 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu109


% --- Executes during object creation, after setting all properties.
function popupmenu109_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu109 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit96_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_1 as text
%        str2double(get(hObject,'String')) returns contents of edit1_1 as a double


% --- Executes during object creation, after setting all properties.
function edit96_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit97_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_7 as text
%        str2double(get(hObject,'String')) returns contents of edit1_7 as a double


% --- Executes during object creation, after setting all properties.
function edit97_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in edit1_6.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit98_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_4 as text
%        str2double(get(hObject,'String')) returns contents of edit1_4 as a double


% --- Executes during object creation, after setting all properties.
function edit98_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit99_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2 as text
%        str2double(get(hObject,'String')) returns contents of edit1_2 as a double


% --- Executes during object creation, after setting all properties.
function edit99_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in edit1_5.
function popupmenu110_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns edit1_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from edit1_5


% --- Executes during object creation, after setting all properties.
function popupmenu110_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in edit1_3.
function popupmenu111_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns edit1_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from edit1_3


% --- Executes during object creation, after setting all properties.
function popupmenu111_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_9_Callback(hObject, eventdata, handles) 
if ( get(hObject,'Value' )== 4)
     CalculateEqualizerSkew( handles.frameout, handles.sims, handles.params, 1 ); % RX Skew
     CalculateEqualizerSkew( handles.frameout, handles.sims, handles.params, 2 ); % RX Skew
     CalculateEqualizerSkew( handles.frameout, handles.sims, handles.params, 3 ); % RX Skew
else    
     CalculateEqualizerSkew( handles.frameout, handles.sims, handles.params,  get(hObject,'Value' ) ); % RX Skew 
end
CalculateEqualizerSkew( handles.frameout, handles.sims, handles.params, 5 ); %TX Skew




% --- Executes during object creation, after setting all properties.
function edit6_9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_10_Callback(hObject, eventdata, handles)
global SW_PATH;
[FileName, PathName] = uiputfile([ SW_PATH './InitFiles/*.mat']);
emphasis_file = [PathName,FileName];
GetPostEmphasis_stbc(handles.frameout.stbcout, emphasis_file, handles.params.stbc);
disp2(handles.sims.logfile, ['File ' emphasis_file ' written.']); 
% hObject    handle to edit6_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_10 as text
%        str2double(get(hObject,'String')) returns contents of edit6_10 as a double


% --- Executes during object creation, after setting all properties.
function edit6_10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_11_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_11 as text
%        str2double(get(hObject,'String')) returns contents of edit6_11 as a double


% --- Executes during object creation, after setting all properties.
function edit6_11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_12_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_12 as text
%        str2double(get(hObject,'String')) returns contents of edit6_12 as a double


% --- Executes during object creation, after setting all properties.
function edit6_12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_13_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_13 as text
%        str2double(get(hObject,'String')) returns contents of edit6_13 as a double


% --- Executes during object creation, after setting all properties.
function edit6_13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_14_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_14 as text
%        str2double(get(hObject,'String')) returns contents of edit6_14 as a double


% --- Executes during object creation, after setting all properties.
function edit6_14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_15_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_15 as text
%        str2double(get(hObject,'String')) returns contents of edit6_15 as a double


% --- Executes during object creation, after setting all properties.
function edit6_15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_16_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_16 as text
%        str2double(get(hObject,'String')) returns contents of edit6_16 as a double


% --- Executes during object creation, after setting all properties.
function edit6_16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit100_Callback(hObject, eventdata, handles)
% hObject    handle to edit100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit100 as text
%        str2double(get(hObject,'String')) returns contents of edit100 as a double


% --- Executes during object creation, after setting all properties.
function edit100_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit101_Callback(hObject, eventdata, handles)
% hObject    handle to edit101 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit101 as text
%        str2double(get(hObject,'String')) returns contents of edit101 as a double


% --- Executes during object creation, after setting all properties.
function edit101_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit101 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit102_Callback(hObject, eventdata, handles)
% hObject    handle to edit102 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit102 as text
%        str2double(get(hObject,'String')) returns contents of edit102 as a double


% --- Executes during object creation, after setting all properties.
function edit102_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit102 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu112.
function popupmenu112_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu112 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu112


% --- Executes during object creation, after setting all properties.
function popupmenu112_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu113.
function popupmenu113_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu113 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu113 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu113


% --- Executes during object creation, after setting all properties.
function popupmenu113_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu113 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu114.
function popupmenu114_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu114 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu114 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu114


% --- Executes during object creation, after setting all properties.
function popupmenu114_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu114 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit103_Callback(hObject, eventdata, handles)
% hObject    handle to edit103 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit103 as text
%        str2double(get(hObject,'String')) returns contents of edit103 as a double


% --- Executes during object creation, after setting all properties.
function edit103_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit103 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu115.
function popupmenu115_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu115 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu115 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu115


% --- Executes during object creation, after setting all properties.
function popupmenu115_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu115 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit115_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_9 as text
%        str2double(get(hObject,'String')) returns contents of edit0_9 as a double


% --- Executes during object creation, after setting all properties.
function edit115_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit116_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_8 as text
%        str2double(get(hObject,'String')) returns contents of edit0_8 as a double


% --- Executes during object creation, after setting all properties.
function edit116_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit117_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_7 as text
%        str2double(get(hObject,'String')) returns contents of edit0_7 as a double


% --- Executes during object creation, after setting all properties.
function edit117_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu116_Callback(hObject, eventdata, handles)


function popupmenu116_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in edit0_5.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in edit0_4.
function popupmenu117_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns edit0_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from edit0_4


% --- Executes during object creation, after setting all properties.
function popupmenu117_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in edit0_3.
function popupmenu118_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns edit0_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from edit0_3


% --- Executes during object creation, after setting all properties.
function popupmenu118_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit118_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_2 as text
%        str2double(get(hObject,'String')) returns contents of edit0_2 as a double


% --- Executes during object creation, after setting all properties.
function edit118_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in edit0_1.
function popupmenu119_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns edit0_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from edit0_1


% --- Executes during object creation, after setting all properties.
function popupmenu119_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit119_Callback(hObject, eventdata, handles)
% hObject    handle to edit119 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit119 as text
%        str2double(get(hObject,'String')) returns contents of edit119 as a double


% --- Executes during object creation, after setting all properties.
function edit119_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit119 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_10_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_10 as text
%        str2double(get(hObject,'String')) returns contents of edit0_10 as a double


% --- Executes during object creation, after setting all properties.
function edit0_10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_11_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_11 as text
%        str2double(get(hObject,'String')) returns contents of edit0_11 as a double


% --- Executes during object creation, after setting all properties.
function edit0_11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_12_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_12 as text
%        str2double(get(hObject,'String')) returns contents of edit0_12 as a double


% --- Executes during object creation, after setting all properties.
function edit0_12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_13_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_13 as text
%        str2double(get(hObject,'String')) returns contents of edit0_13 as a double


% --- Executes during object creation, after setting all properties.
function edit0_13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_14_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_14 as text
%        str2double(get(hObject,'String')) returns contents of edit0_14 as a double


% --- Executes during object creation, after setting all properties.
function edit0_14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_15_Callback(hObject, eventdata, handles)
[FileName,PathName]  = uigetfile([ '*.*']);
if isequal(FileName,0) || isequal(PathName,0)
    disp2(handles.sims.logfile, 'User clicked Cancel.')
else
    disp2(handles.sims.logfile, ['Setting Data  File ', FileName,' in Path', PathName]);
    handles.sims.dataf.data_file = [PathName,FileName];
    handles.sims.dataf_filename = [FileName];
    set( hObject, 'String',  handles.sims.dataf_filename);
    set( hObject, 'UserData',  handles.sims.dataf.data_file);
    guidata(hObject, handles);
end



% hObject    handle to edit0_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_15 as text
%        str2double(get(hObject,'String')) returns contents of edit0_15 as a double


% --- Executes during object creation, after setting all properties.
function edit0_15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_16_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_16 as text
%        str2double(get(hObject,'String')) returns contents of edit0_16 as a double


% --- Executes during object creation, after setting all properties.
function edit0_16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_17_Callback(hObject, eventdata, handles)
handles.params.RXDSP_PTBC      = get_value(hObject)-1;
if ( handles.params.RXDSP_PTBC == 1 )
    params.stbc.en   = 1;
else
    params.stbc.en   = 0;
end  
manusetting(hObject, eventdata, handles);
UpdateDisplay(hObject, eventdata, handles);
guidata(hObject, handles);

 


function edit0_17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_18_Callback(hObject, eventdata, handles)
handles.params.testmode        = get_value(hObject)-1;
if ( handles.params.testmode == 1 )
    handles.params.NSignalSymbol     = 64;
    handles.params.NDataSymbol     = 0;
else 
    handles.params.NSignalSymbol     = 64;
    handles.params.NDataSymbol       = 85760;
end 
UpdateDisplay(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit0_18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_19_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_19 as text
%        str2double(get(hObject,'String')) returns contents of edit0_19 as a double


% --- Executes during object creation, after setting all properties.
function edit0_19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_20_Callback(hObject, eventdata, handles)
handles.sims.signal_fail_cnt = 0;
handles.sims.Totframe        = 0;
handles.sims.hamming_corr_cnt= 0;
disp_result(handles.sims, handles.frameout, handles.sims, handles.params);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit0_20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_21_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_21 as text
%        str2double(get(hObject,'String')) returns contents of edit0_21 as a double


% --- Executes during object creation, after setting all properties.
function edit0_21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_22_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_22 as text
%        str2double(get(hObject,'String')) returns contents of edit0_22 as a double


% --- Executes during object creation, after setting all properties.
function edit0_22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_23_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_23 as text
%        str2double(get(hObject,'String')) returns contents of edit0_23 as a double


% --- Executes during object creation, after setting all properties.
function edit0_23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_24_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_24 as text
%        str2double(get(hObject,'String')) returns contents of edit0_24 as a double


% --- Executes during object creation, after setting all properties.
function edit0_24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_25_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_25 as text
%        str2double(get(hObject,'String')) returns contents of edit0_25 as a double


% --- Executes during object creation, after setting all properties.
function edit0_25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_26_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_26 as text
%        str2double(get(hObject,'String')) returns contents of edit0_26 as a double


% --- Executes during object creation, after setting all properties.
function edit0_26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_27_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_27 as text
%        str2double(get(hObject,'String')) returns contents of edit0_27 as a double


% --- Executes during object creation, after setting all properties.
function edit0_27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_28_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_28 as text
%        str2double(get(hObject,'String')) returns contents of edit0_28 as a double


% --- Executes during object creation, after setting all properties.
function edit0_28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_29_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_29 as text
%        str2double(get(hObject,'String')) returns contents of edit0_29 as a double


% --- Executes during object creation, after setting all properties.
function edit0_29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_30_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_30 as text
%        str2double(get(hObject,'String')) returns contents of edit0_30 as a double


% --- Executes during object creation, after setting all properties.
function edit0_30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_31_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_31 as text
%        str2double(get(hObject,'String')) returns contents of edit0_31 as a double


% --- Executes during object creation, after setting all properties.
function edit0_31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_32_Callback(hObject, eventdata, handles)
% hObject    handle to edit0_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0_32 as text
%        str2double(get(hObject,'String')) returns contents of edit0_32 as a double


% --- Executes during object creation, after setting all properties.
function edit0_32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_8_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_8 as text
%        str2double(get(hObject,'String')) returns contents of edit1_8 as a double


% --- Executes during object creation, after setting all properties.
function edit1_8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_9_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_9 as text
%        str2double(get(hObject,'String')) returns contents of edit1_9 as a double


% --- Executes during object creation, after setting all properties.
function edit1_9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit145_Callback(hObject, eventdata, handles)
% hObject    handle to edit145 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit145 as text
%        str2double(get(hObject,'String')) returns contents of edit145 as a double


% --- Executes during object creation, after setting all properties.
function edit145_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit145 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_10_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_10 as text
%        str2double(get(hObject,'String')) returns contents of edit1_10 as a double


% --- Executes during object creation, after setting all properties.
function edit1_10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_11_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_11 as text
%        str2double(get(hObject,'String')) returns contents of edit1_11 as a double


% --- Executes during object creation, after setting all properties.
function edit1_11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_12_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_12 as text
%        str2double(get(hObject,'String')) returns contents of edit1_12 as a double


% --- Executes during object creation, after setting all properties.
function edit1_12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_13_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_13 as text
%        str2double(get(hObject,'String')) returns contents of edit1_13 as a double


% --- Executes during object creation, after setting all properties.
function edit1_13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_14_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_14 as text
%        str2double(get(hObject,'String')) returns contents of edit1_14 as a double


% --- Executes during object creation, after setting all properties.
function edit1_14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_15_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_15 as text
%        str2double(get(hObject,'String')) returns contents of edit1_15 as a double


% --- Executes during object creation, after setting all properties.
function edit1_15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_16_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_16 as text
%        str2double(get(hObject,'String')) returns contents of edit1_16 as a double


% --- Executes during object creation, after setting all properties.
function edit1_16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_17_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_17 as text
%        str2double(get(hObject,'String')) returns contents of edit1_17 as a double


% --- Executes during object creation, after setting all properties.
function edit1_17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_18_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_18 as text
%        str2double(get(hObject,'String')) returns contents of edit1_18 as a double


% --- Executes during object creation, after setting all properties.
function edit1_18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_19_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_19 as text
%        str2double(get(hObject,'String')) returns contents of edit1_19 as a double


% --- Executes during object creation, after setting all properties.
function edit1_19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_20_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_20 as text
%        str2double(get(hObject,'String')) returns contents of edit1_20 as a double


% --- Executes during object creation, after setting all properties.
function edit1_20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_21_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_21 as text
%        str2double(get(hObject,'String')) returns contents of edit1_21 as a double


% --- Executes during object creation, after setting all properties.
function edit1_21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_22_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_22 as text
%        str2double(get(hObject,'String')) returns contents of edit1_22 as a double


% --- Executes during object creation, after setting all properties.
function edit1_22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_23_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_23 as text
%        str2double(get(hObject,'String')) returns contents of edit1_23 as a double


% --- Executes during object creation, after setting all properties.
function edit1_23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_24_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_24 as text
%        str2double(get(hObject,'String')) returns contents of edit1_24 as a double


% --- Executes during object creation, after setting all properties.
function edit1_24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_25_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_25 as text
%        str2double(get(hObject,'String')) returns contents of edit1_25 as a double


% --- Executes during object creation, after setting all properties.
function edit1_25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_32_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_32 as text
%        str2double(get(hObject,'String')) returns contents of edit1_32 as a double


% --- Executes during object creation, after setting all properties.
function edit1_32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_26_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_26 as text
%        str2double(get(hObject,'String')) returns contents of edit1_26 as a double


% --- Executes during object creation, after setting all properties.
function edit1_26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_27_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_27 as text
%        str2double(get(hObject,'String')) returns contents of edit1_27 as a double


% --- Executes during object creation, after setting all properties.
function edit1_27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_28_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_28 as text
%        str2double(get(hObject,'String')) returns contents of edit1_28 as a double


% --- Executes during object creation, after setting all properties.
function edit1_28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_29_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_29 as text
%        str2double(get(hObject,'String')) returns contents of edit1_29 as a double


% --- Executes during object creation, after setting all properties.
function edit1_29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_30_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_30 as text
%        str2double(get(hObject,'String')) returns contents of edit1_30 as a double


% --- Executes during object creation, after setting all properties.
function edit1_30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_31_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_31 as text
%        str2double(get(hObject,'String')) returns contents of edit1_31 as a double


% --- Executes during object creation, after setting all properties.
function edit1_31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_1_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_1 as text
%        str2double(get(hObject,'String')) returns contents of edit6_1 as a double


% --- Executes during object creation, after setting all properties.
function edit6_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_2_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_2 as text
%        str2double(get(hObject,'String')) returns contents of edit6_2 as a double


% --- Executes during object creation, after setting all properties.
function edit6_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_3_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_3 as text
%        str2double(get(hObject,'String')) returns contents of edit6_3 as a double


% --- Executes during object creation, after setting all properties.
function edit6_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_4_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_4 as text
%        str2double(get(hObject,'String')) returns contents of edit6_4 as a double


% --- Executes during object creation, after setting all properties.
function edit6_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_5_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_5 as text
%        str2double(get(hObject,'String')) returns contents of edit6_5 as a double


% --- Executes during object creation, after setting all properties.
function edit6_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_6 as text
%        str2double(get(hObject,'String')) returns contents of edit6_6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_7_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_7 as text
%        str2double(get(hObject,'String')) returns contents of edit6_7 as a double


% --- Executes during object creation, after setting all properties.
function edit6_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_8_Callback(hObject, eventdata, handles)
% hObject    handle to edit6_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6_8 as text
%        str2double(get(hObject,'String')) returns contents of edit6_8 as a double


% --- Executes during object creation, after setting all properties.
function edit6_8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot1.
function plot1_Callback(hObject, eventdata, handles)
% hObject    handle to plot1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot1


% --- Executes on selection change in plot2.
function plot2_Callback(hObject, eventdata, handles)
% hObject    handle to plot2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plot2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot2


% --- Executes during object creation, after setting all properties.
function plot2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
