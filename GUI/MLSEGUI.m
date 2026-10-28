function varargout = MLSEGUI(varargin)

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MLSEGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MLSEGUI_OutputFcn, ...
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
 


function MLSEGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.current_data = 0;
guidata(hObject, handles);


 
function varargout = MLSEGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.axes1;
varargout{2} = handles;





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
