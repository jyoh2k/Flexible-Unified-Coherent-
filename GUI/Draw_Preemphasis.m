function varargout = Draw_Preemphasis(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Draw_Preemphasis_OpeningFcn, ...
                   'gui_OutputFcn',  @Draw_Preemphasis_OutputFcn, ...
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


function Draw_Preemphasis_OpeningFcn(hObject, eventdata, handles, varargin)
handles.sims =  varargin{3};
handles.params =  varargin{4};
handles.output = hObject;
%handles.sims.logfile = ['preemphashs.log'];
global SW_PATH
handles.sims.freq_filename = [SW_PATH 'FreqResp.mat'];
handles.sims.pre_filename = [SW_PATH 'Preemphasis.mat'];
set( handles.edit1_1, 'String', 'FreqResp.mat');
set( handles.edit1_4, 'String', 'Preemphasis.mat');
guidata(hObject, handles);


function varargout = Draw_Preemphasis_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


function pushbutton2_Callback(hObject, eventdata, handles)
Preemphasis = handles.Preemphasis;
save(handles.sims.pre_filename, 'Preemphasis');
disp2(handles.sims.logfile, ['Saved matfile File ', handles.sims.pre_filename ]);


function pushbutton1_Callback(hObject, eventdata, handles)
handles = update_ParameterSet(hObject, eventdata, handles);
handles.Fvec2 = (1:handles.npoint) /handles.npoint * handles.params.AWGSampleFreq/2;
guidata(hObject, handles);

[Preemphasis,Fvec3] =  get_preemp (handles.AFRvec, hObject, eventdata, handles);
handles.Preemphasis  =Preemphasis;
guidata(hObject, handles);
display_preemph(Preemphasis, Fvec3, hObject, eventdata, handles,'w');
hold(handles.axes2, 'off');


function [Preemphasis,Fvec2] =  get_preemp (AFRvec, hObject, eventdata, handles)  
Fvec_ext =[ handles.Fvec  handles.Fvec(end) + handles.Fvec];
AFRvec_ext = zeros(size(AFRvec,1), size(AFRvec,2) *2);
AFRvec_ext(:, 1:size(AFRvec,2)) = AFRvec;
FreqResp_AWG = interp1( Fvec_ext, AFRvec_ext, handles.Fvec2, 'linear');
FreqResp_AWG = FreqResp_AWG ./sqrt(sum(FreqResp_AWG .^2));
 
display_preemph(FreqResp_AWG,  handles.Fvec2, hObject, eventdata, handles,'y');
hold(handles.axes2, 'on');
GHz=1e9; 
maxidx = round(handles.freq_th * GHz / handles.params.AWGSampleFreq * 2 * handles.npoint );
Preemp = 1 ./ FreqResp_AWG;
if (handles.freq_th ~= 0 )
   Preemp(1:maxidx) = 1 ./ FreqResp_AWG(1:maxidx);
end
Preemp(maxidx+1:end) = 0;
% display_preemph(Preemp,  handles.Fvec2, hObject, eventdata, handles,'g');
%Normalize
Preemphasis = Preemp ./sqrt(sum(Preemp .^2)); 
% display_preemph(Preemphasis,  handles.Fvec2, hObject, eventdata, handles,'r');
% Smoothing
if (handles.smoothing ~= 0 )
    Preemphasis = smooth(Preemphasis, handles.smoothing);
end
% display_preemph(Preemphasis,  handles.Fvec2, hObject, eventdata, handles);

Fvec2 =  handles.Fvec2;
guidata(hObject, handles);


function edit1_1_Callback(hObject, eventdata, handles)
[FileName,PathName]  = uigetfile([ '*.*']);
if isequal(FileName,0) || isequal(PathName,0)
    disp2(handles.sims.logfile, 'User clicked Cancel.')
else
    disp2(handles.sims.logfile, ['Loading File ', FileName,' in Path', PathName]);
    handles.sims.freq_filename = [PathName,FileName];
    set( hObject, 'String', FileName);
    load(handles.sims.freq_filename);
    handles.Fvec = Fvec;
    handles.PFRvec = PFRvec;
    handles.AFRvec = AFRvec;
end
guidata(hObject, handles);
display_preemph(AFRvec, Fvec, hObject, eventdata, handles,'c');




function edit1_5_Callback(hObject, eventdata, handles)



function edit1_5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_4_Callback(hObject, eventdata, handles)
[FileName,PathName]  = uiputfile([ '*.*']);
if isequal(FileName,0) || isequal(PathName,0)
    disp2(handles.sims.logfile, 'User clicked Cancel.')
else
    disp2(handles.sims.logfile, ['Loading File ', FileName,' in Path', PathName]);
    handles.sims.pre_filename = [PathName,FileName];
    set( hObject, 'String', FileName);
end
guidata(hObject, handles);




function edit1_3_Callback(hObject, eventdata, handles)



function edit1_3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_2_Callback(hObject, eventdata, handles)



function edit1_2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function val = get_value(handles1)
val = get(handles1, 'Value');

function val = get_string(handles1)
val = str2num(get(handles1, 'String'));

function handles = update_ParameterSet(hObject, eventdata, handles)
    GHz=1e9;MHz=1e6;
    handles.filename  = get(handles.edit1_1, 'String');
    handles.freq_th    = get_string (handles.edit1_2);
    handles.smoothing    = get_string (handles.edit1_3);
    handles.npoint    = get_string (handles.edit1_5);
    guidata(hObject, handles);

    
    

function display_preemph(Preemphasis, Fvec3, hObject, eventdata, handles, colr )
GHz=1e9; 
plot(handles.axes2, Fvec3/GHz,  Preemphasis, colr, 'LineWidth', 2)
grid(handles.axes2, 'on');
xlim(handles.axes2, [min(Fvec3/GHz) max(Fvec3/GHz)]);
%ylim(handles.phase_axes, [min(PFRvec)-10 max(PFRvec)+10])
xlabel(handles.axes2, 'Frequency, GHz');
ylabel(handles.axes2, 'Amplitude');
default_color(handles.axes2);
