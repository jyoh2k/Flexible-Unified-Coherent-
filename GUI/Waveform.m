function varargout = Waveform(varargin)
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Waveform_OpeningFcn, ...
                   'gui_OutputFcn',  @Waveform_OutputFcn, ...
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


function Waveform_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

set( handles.popupmenu1, 'String', {'Equalized(DFE)' 'After TPR'  'Equalized(FFE)'  'EyeDiagram(DFE)'  'MLSE analysis'  'Level analysis'  });
guidata(hObject, handles);



function varargout = Waveform_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.axes1;
varargout{2} = handles.text1;
varargout{3} = handles.axes2;
varargout{4} = handles;


function popupmenu1_Callback(hObject, eventdata, handles)
signal_str = get(hObject,  'String' );
signal_type = get(hObject,  'Value' ) ;
frame = get(handles.figure1,  'UserData');
params=frame.params;
if ( signal_type == 1 )
    equalized_dfe = frame.equalized_dfe(1, 1:end);
end
if ( signal_type == 2 )
    equalized_dfe = frame.resampledout(1, 1:frame.params.RXoversample:end);
end
if ( signal_type == 3 )
    equalized_dfe = frame.equalized_ffe(1, 1:frame.params.RXoversample:end);
end
% transmitted   = frame.txsignal.mapper(1,:); 
transmitted   = frame.txsignal.trainingseq(1,:);
if ( signal_type == 4 ) % Eye diagram    
    equalized_ffe = frame.equalized_ffe(1, round(params.NTrainingSymbol*params.RXoversample*1.2):end);
    equalized_dfe = frame.equalized_dfe(1, round(params.NTrainingSymbol *1.2):end); frame.params.RXoversample  = 1;
    SubShowEyediagram( equalized_dfe, transmitted,1, handles.axes1, handles.text1, handles, handles.axes2, frame.params, frame );
end
if ( signal_type < 4 )
    SubShowWaveform( equalized_dfe, transmitted,1, handles.axes1, handles.text1, handles, handles.axes2, frame.params, frame );
end
if ( signal_type == 5 )
    frame = get(handles.figure1,  'UserData');
    MLSEAnalysis( handles.sims, handles.params, frame);
end
if ( signal_type == 6 )
    frame = get(handles.figure1,  'UserData');
    GuiLevelAnalysis( 'Genbutton_Callback',  'Level analysis', frame.sims, frame.params, frame);
end


function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Waveform_Callback(hObject, eventdata, handles)
% hObject    handle to Waveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
global SW_PATH
[FileName, PathName] = uiputfile([ SW_PATH './Results/Figures/Parameter']);
if ( PathName ~= 0 )
    saveas(gcf,  [PathName FileName '.fig' ], 'fig');
    saveas(gcf,  [PathName FileName '.jpg' ], 'jpg');
    saveas(gcf,  [PathName FileName '.tif' ], 'tif');
    pause(0.1);
    img =getframe(gcf);
    imwrite(img.cdata, [PathName FileName '.png' ]);
%     printf(gcf, '-djpeg100', 'mask_image.jpg', '-r0');
%    img= getframe(gcf); [CurrentFigureData, CurrentFigureMap] = frame2im(imag);
end
