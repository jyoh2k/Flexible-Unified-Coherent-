function varargout = GuiLevelAnalysis(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiLevelAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiLevelAnalysis_OutputFcn, ...
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
 


function GuiLevelAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.current_data = 0;
handles.sims =  varargin{3};
handles.params =  varargin{4};
handles.frame =  varargin{5};
handles.params.acc = 0; 
handles.params.update_ratio = 1;
set( handles.edit1_2, 'String', {'1' '2'  '3'   });
set( handles.edit1_2, 'Style', 'popupmenu'); 
guidata(hObject, handles);


 
function varargout = GuiLevelAnalysis_OutputFcn(hObject, eventdata, handles) 
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

function putfile(hObject, eventdata, handles,lut1) 
    global SW_PATH
    [FileName, PathName] = uiputfile([ SW_PATH './InitFiles/*.mat']);
    if isequal(FileName,0) || isequal(PathName,0)
        disp2(handles.sims.logfile, 'User clicked Cancel.')
    else        
         save([PathName, FileName],  'lut1');
        disp2(handles.sims.logfile, ['Saved in File ', FileName]);
    end 
 


function savebutton_Callback(hObject, eventdata, handles)
global SW_PATH
level = handles.level;
lut3 = handles.lut3;
if ( handles.params.NTXStream  == 2 && handles.frame.cur_stream == 2 )
    filename = [SW_PATH './RunFiles/predistortion2_lut.m'];
    str=['function lut=predistortion2_lut()  ' sprintf('    \n') ];
else
    filename = [SW_PATH './RunFiles/predistortion_lut.m'];
    str=['function lut=predistortion_lut()  ' sprintf('    \n') ];
end
str=[str 'lut = [ ...  '  sprintf('    \n')];
lut3_nan =lut3;
lut3_nan(isnan(lut3)) =0;
 for ilut=1:size(handles.lut3, 1) 
            str=[str,  num2str(lut3_nan(ilut,1:end-1), '  %d'), sprintf('    \t') ..., 
                             num2str(lut3_nan(ilut, end), '%1.3f'), sprintf('    ;  ... \n')];
             
 end
str=[str '];  '  sprintf('    \n')];
str=[str ' lut(:,end) = lut(:, end) *1.0; '  sprintf('    \n')];
str=[str 'end '  sprintf('    \n')];
dlmwrite(filename,str, 'delimiter','');
open(filename);
%  putfile(hObject, eventdata, handles,lut3) 
        


function savebutton_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_2_Callback(hObject, eventdata, handles)

function edit1_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function runbutton_Callback(hObject, eventdata, handles)
params =handles.params;
frame =handles.frame;
sims =handles.sims;
if (  params.NTXStream == 1)
    trainingseq = frame.txsignal.trainingseq(:, params.NTrainingSymbol+1:end);
    equalized = frame.recovered(:, params.NTrainingSymbol+1:end);   
else        
    trainingseq = frame.txsignal.mapper2(frame.cur_stream, params.NTrainingSymbol+1:end);
    equalized = frame.recovered2(frame.cur_stream, params.NTrainingSymbol+1:end);   
end 

level = get(handles.edit1_2, 'Value');  
is_real = 2-get(handles.edit1_3, 'Value') ;  
diff_b = params.lutpredistortion.lut(:,end) * handles.params.acc;
level_b = size(params.lutpredistortion.lut ,2)-1;
update_ratio =  handles.params.update_ratio  ;
if ( isreal(trainingseq) == 0 )
    [lut, num_map] = GetLut( params, level);
    if ( level ~= level_b )
        diff_b = zeros( 1, size(lut,1) );
    end 
    [var_level_r, mean_level_r, dif_level_r] = SubLevelAnalysis(  is_real, handles.axes1,  real(trainingseq), real(equalized), level, lut, num_map, update_ratio, real(diff_b));
    [var_level_i, mean_level_i, dif_level_i] = SubLevelAnalysis(  1 - is_real, handles.axes1, imag(trainingseq), imag(equalized), level, lut, num_map, update_ratio, imag(diff_b));    
    var_level = complex(var_level_r,var_level_i);
    mean_level = complex(mean_level_r,mean_level_i);
    dif_level = complex(dif_level_r,dif_level_i);    
    [~, map_list]= QAMMapper2List(params);
    xlim(handles.axes1, [map_list(1) *1.4 map_list(end) *1.4 ]);
else
    [lut, num_map] = GetLutr( params, trainingseq, level);
    if ( level ~= level_b )
        diff_b = zeros( 1, size(lut,1) );
    end 
    [var_level_r, mean_level_r, dif_level_r] = SubLevelAnalysis(  is_real, handles.axes1,  real(trainingseq), real(equalized), level, lut, num_map, update_ratio, diff_b);
    var_level = var_level_r;
    mean_level = mean_level_r;
    dif_level = dif_level_r;
end


if ( isreal(trainingseq) == 0 )
    [lut1] = GetLut1( params, level);
    handles.level = level;
    handles.lut3 = get_lut( lut1, dif_level );
    if (is_real)
        Display_LUT(handles.text2, level, handles.lut3(:, 1:end-1), var_level_r, mean_level_r, dif_level_r, num_map);
    else
        Display_LUT(handles.text2, level, handles.lut3(:, 1:end-1), var_level_i, mean_level_i, dif_level_i, num_map);
    end
else
    handles.level = level;
    handles.lut3 = [lut dif_level'];
    Display_LUT(handles.text2, level, lut, var_level, mean_level, dif_level, num_map);
end 

guidata(hObject, handles);




function runbutton_CreateFcn(hObject, eventdata, handles)



function [var_level, mean_level, dif_level] = SubLevelAnalysis( en_display, axes1, trainingseq, equalized, level, lut, num_map, update_ratio, diff_b)

constraint_memory = level -1;
 mapper_in = zeros(constraint_memory +1, size(trainingseq,2));
 idx = 1; 
 for ich=1:size(trainingseq,1)
     mapper_in(constraint_memory+1,:) = trainingseq(ich, :);
     for imem=constraint_memory:-1:1
         mapper_in(imem,:) =  [0 mapper_in(imem+1, 1:end-1)];
     end
     %% Main part : offset 
     max_nb0 = 0;
     base_val = 10;
     color_str = {'y' 'r' 'g' 'b'  'm' 'c' 'k' 'r' 'g' 'b' 'y' 'm' 'g' 'c'};
     
     for ilut=1:size(lut, 1)
         if ( mod(ilut,  num_map^(level-1)) == 1  ||  level == 1)
%              figure;
            base_val = base_val + max_nb0 * 1.2;
         end
         symbol_idx =1:min(size(mapper_in,2),size(equalized,2));
         for imem=1:constraint_memory+1
             symbol_idx = intersect( symbol_idx, find(mapper_in(imem,:) == lut( ilut, imem)));
         end
         mean_level(idx) = mean(equalized(symbol_idx) );
         var_level(idx) = var(equalized(symbol_idx) );
         dif_level(idx) =  (lut( ilut, imem) -   mean_level(idx)  ) * update_ratio  +  diff_b(idx);
         idx = idx +1;
         [nb0, xb0] =hist( equalized(symbol_idx),32);   
         if ( en_display == 1 )
             plot(  axes1, xb0, nb0+base_val,[ color_str{mod(idx,4)+1} '-'],'LineWidth', 2  );
             hold (axes1, 'on');
         end
         max_nb0 = max(max_nb0, max(nb0)+100);
        
     end     
 end
default_color(axes1);

if ( en_display == 1 )
    % xlim(axes1,  [-5.5 5.5]);
    ylim(axes1,  [-10  max_nb0 + base_val ]);
    hold (axes1, 'off');
end
 
function lut3 = get_lut( lut, dif_level )

lut3 =zeros(size(lut,1), size(lut,2)+1);
lut3(:, 1:end-1) =lut;
lut3(:, end) = dif_level;
 


function Display_LUT(text2handles, level, lut, var_level, mean_level, dif_level, num_map)
        str='';
        for ilut=size(lut, 1):-1:1
            if (  isnan(dif_level(ilut)) == 0 ) 
            if ( mod(ilut, num_map^(level-1)) == 0  ||  level == 1)
                 str=[str, sprintf('    \n')];
            end
            str=[str,  num2str(real(lut(ilut,:)), ' %d'), sprintf('    \t') ..., 
                             num2str(dif_level(ilut), '%1.3f'), sprintf('    \n')];
            end
        end
 

set(text2handles, 'String', str);


function [lut,num_map] = GetLut( params, level)
[~, map_list]= QAMMapper2List(params);
lut = map_list;
num_map = length(map_list);
for ilevel =1:level-1
    lut2=[];
    for imap=1:size(map_list)
        lut3 = zeros(size(lut, 1), size(lut,2)+1);
        lut3(:, 1:end-1) = lut;
        lut3(:, end) = map_list(imap);
        lut2 = [lut2; lut3];
    end
    lut =lut2;
end


function [lut, num_map] = GetLutr( params,trainingseq, level)
[~, map_list]= QAMMapper2List(params);
map_list=[];
for map_val=-10:10
    if (  isempty(find(trainingseq == map_val)) == 0)
        map_list=[map_list; map_val;];
    end
end

lut = map_list;
num_map = length(map_list);
for ilevel =1:level-1
    lut2=[];
    for imap=1:size(map_list)
        lut3 = zeros(size(lut, 1), size(lut,2)+1);
        lut3(:, 1:end-1) = lut;
        lut3(:, end) = map_list(imap);
        lut2 = [lut2; lut3];
    end
    lut =lut2;
end

function [lut] = GetLut1( params, level)
[~, ~, ~, map_list]= QAMMapper2List(params);
lut = map_list;
for ilevel =1:level-1
    lut2=[];
    for imap=1:size(map_list)
        lut3 = zeros(size(lut, 1), size(lut,2)+1);
        lut3(:, 1:end-1) = lut;
        lut3(:, end) = map_list(imap);
        lut2 = [lut2; lut3];
    end
    lut =lut2;
end


 
function edit1_3_Callback(hObject, eventdata, handles)  







 
function edit1_3_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function accmenu_Callback(hObject, eventdata, handles)
if ( get(hObject, 'Value') == 1 )
    handles.params.acc  = 1;
    handles.params.update_ratio  = 1;
end
if ( get(hObject, 'Value') == 2 )
    handles.params.acc  = 1;
    handles.params.update_ratio  = 0.5;
end
if ( get(hObject, 'Value') == 3 )
    handles.params.acc  = 1;
    handles.params.update_ratio  = 0.25;
end
if ( get(hObject, 'Value') == 4 )
    handles.params.acc  = 0;
    handles.params.update_ratio  = 1;
end
guidata(hObject, handles);



function accmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
