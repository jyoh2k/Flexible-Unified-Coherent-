function varargout = Constellations(varargin)

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Constellations_OpeningFcn, ...
                   'gui_OutputFcn',  @Constellations_OutputFcn, ...
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
 


function Constellations_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.current_data = 0;
guidata(hObject, handles);


 
function varargout = Constellations_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.axes1;
varargout{2} = handles.text1;
varargout{3} = handles.slider1;
varargout{4} = handles;
% varargout{1} = handles.output;


 
function slider1_Callback(hObject, eventdata, handles) 
frame = get(handles.figure1,  'UserData');

mapper_list =  QAMMapperList (  frame.params ) ;
signal_str = get(handles.popupmenu1 ,  'String' );
signal_type = get(handles.popupmenu1 ,  'Value' ) ; 
synchronized = 0 ;
    
frame.upper_right_idx = find(frame.mapper_tx2(frame.iaxes,:) ==frame.upper_right_data);

if ( strcmp(signal_str{signal_type} ,  'Equalized') )
    equalized = frame.recovered2(frame.iaxes,:);
    synchronized = 1 ;
    upper_right_idx = frame.upper_right_idx ;
    
end
if ( strcmp(signal_str{signal_type} ,  'Received') )
    equalized = frame.received;
end
if ( strcmp(signal_str{signal_type} ,  'After TPR') )
    equalized = frame.resampledout(1, 1:2:end);
end
if ( strcmp(signal_str{signal_type} ,  'After CFE') )
    equalized = frame.cfo_recovered(frame.iaxes, 1:2:end);
end
if ( strcmp(signal_str{signal_type} ,  'After CPR0') )
    equalized = frame.phase_error_recovered_sync(frame.iaxes, 1:2:end);
    synchronized = 1 ;
    upper_right_idx = frame.upper_right_idx ;
end
if ( strcmp(signal_str{signal_type} ,  'After CPR') )
    equalized = frame.phase_error_recovered(frame.iaxes, 1:2:end);
    synchronized = 1 ;
    idx_offset = frame.fsfs.start_of_frame;
    
    upper_right_idx = frame.upper_right_idx ;%+ idx_offset -1 ;
end
if ( strcmp(signal_str{signal_type} ,  'After Eq1') )
    equalized = frame.cfo_recovered_eq(frame.iaxes, 1:2:end);
end
if ( strcmp(signal_str{signal_type} ,  'After FrameStart') )
    equalized = frame.cfo_recovered_sync(frame.iaxes, 1:2:end);
end
Step = 0.05;
MaxStep = 1/Step +1;
iInv = get( hObject,  'Value' ) ;
slider_inv =  floor ( iInv * 1/Step + 0.5 ) +1 ;
d = floor(1.0/MaxStep*size(equalized,2));
x = ( 1:d )+ d*(slider_inv-1);
plot  (handles.axes1, equalized(:, x), 'y*');
hold(handles.axes1, 'on');
ylim  (handles.axes1, [-1.7 1.7]); 
xlim  (handles.axes1, [-1.7 1.7]); 
if ( synchronized == 1 )    
    plot  (handles.axes1, equalized(:, intersect(x,upper_right_idx)), 'go' );
%     if ( frame.BER < 0.1 )
%         plot  (handles.axes1, equalized(:, intersect(x, frame.error_const_idx)), 'm*' );
%     end
end
plot  (handles.axes1, mapper_list, 'ro' );
hold(handles.axes1, 'off');
default_color(handles.axes1);

 


 
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function Constellation_Callback(hObject, eventdata, handles)

function popupmenu1_Callback(hObject, eventdata, handles)
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
