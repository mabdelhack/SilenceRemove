function varargout = NoiseRemove(varargin)
% NOISEREMOVE MATLAB code for NoiseRemove.fig
%      NOISEREMOVE, by itself, creates a new NOISEREMOVE or raises the existing
%      singleton*.
%
%      H = NOISEREMOVE returns the handle to a new NOISEREMOVE or the handle to
%      the existing singleton*.
%
%      NOISEREMOVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOISEREMOVE.M with the given input arguments.
%
%      NOISEREMOVE('Property','Value',...) creates a new NOISEREMOVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NoiseRemove_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NoiseRemove_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NoiseRemove

% Last Modified by GUIDE v2.5 06-Feb-2017 03:10:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NoiseRemove_OpeningFcn, ...
                   'gui_OutputFcn',  @NoiseRemove_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before NoiseRemove is made visible.
function NoiseRemove_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NoiseRemove (see VARARGIN)
set(hObject,'WindowButtonDownFcn',{@MouseClickFcn,hObject});
set(hObject,'WindowButtonUpFcn',{@MouseReleaseFcn,hObject});
axes(handles.sound_plot);
cla(handles.sound_plot);
set(handles.sound_plot,'xlim',[0 2],'ylim',[-1 1],'unit','pixels');
set(handles.figure1,'unit','pixels')
% Choose default command line output for NoiseRemove
handles.output = hObject;

handles.origbut = 0;
handles.allsize = 1;
handles.click = 0;
set(handles.status, 'String', 'Ready');
if isfield(handles, 'startline')
    handles = rmfield(handles,'startline');
    
end
set(handles.figure1,'WindowButtonMotionFcn',{@MouseSearchFcn,hObject});

lrnFileName = 'lrn_pars.dat';
fp = fopen(lrnFileName, 'r+');
if (fp<0)
	
    handles.prec = 0;
    handles.trail = 0;
else
    D = csvread(lrnFileName);
    handles.prec = D(1);
    handles.trail = D(2);
end 

set(handles.acceptbutton,'Enable','off') ;
set(handles.playbut,'Enable','off') ;
set(handles.skipbutton,'Enable','off') ;
set(handles.revertbutton,'Enable','off') ;
set(handles.orig_rad,'Value',0) ;
set(handles.trim_rad,'Value',1) ;
set(handles.orig_rad,'Enable','off') ;
set(handles.trim_rad,'Enable','off') ;
set(handles.auto,'Value',0);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NoiseRemove wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NoiseRemove_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;

% --------------------------------------------------------------------
function load_folder_Callback(hObject, eventdata, handles)
% hObject    handle to load_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

workingfolder  = uigetdir;
if workingfolder ~=0

    soundfiles = dir(fullfile(workingfolder, '*.WAV'));
    disp(soundfiles);
    handles.workingfolder = workingfolder;
    handles.soundfiles = soundfiles;
    handles.remainingfiles = length(soundfiles);
    handles.f = 1;
    handles = mainfunction2(handles,hObject);
%     set(handles.loadbutton,'Enable','off');
    pause(0.01);
%     set(handles.loadbutton,'Enable','on') ;
    set(handles.acceptbutton,'Enable','on') ;
    set(handles.skipbutton,'Enable','on') ;
    set(handles.playbut,'Enable','on') ;
    set(handles.revertbutton,'Enable','on') ;
    set(handles.orig_rad,'Enable','on') ;
    set(handles.trim_rad,'Enable','on') ;
    
    auto = get(handles.auto,'Value');
    if auto == 1
        set(handles.status, 'String', 'Done!');
        set(handles.playbut,'Enable','off') ;
%         set(handles.loadbutton,'Enable','off') ;
        set(handles.acceptbutton,'Enable','off') ;
        set(handles.skipbutton,'Enable','off') ;
        set(handles.revertbutton,'Enable','off') ;
        set(handles.orig_rad,'Enable','off') ;
        set(handles.trim_rad,'Enable','off') ;
    end
end
guidata(hObject,handles);

% --- Executes on button press in acceptbutton.
function acceptbutton_Callback(hObject, eventdata, handles)
% hObject    handle to acceptbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isplaying(handles.player_orig)
    stop(handles.player_orig);
elseif isplaying(handles.player)
    stop(handles.player);
end
workingdir = handles.workingfolder;
soundfiles = handles.soundfiles;
rem = handles.remainingfiles;
f = handles.f;
if rem >=0
    
    curfile = fullfile(workingdir, soundfiles(f-1).name);
    for s = handles.segsave:length(handles.out)
        [cl, accept] = finished(handles.out{s},handles.fs);
%         uiwait(cl);
        if accept
            fname  = [curfile(1:end-4), '_' , num2str(s), '.WAV'];
            audiowrite(fname, handles.out{s} , handles.fs,'BitsPerSample',16);
            handles = learn_err(handles);
        %     handles.f = f+1;
        %     handles.remainingfiles = rem-1;
            
        else
            handles.segsave = s;
            break;
        end
    end
    if accept
        cla(handles.sound_plot);
        handles = rmfield(handles,'startline');
        handles =  mainfunction2(handles,hObject);
        if rem == 0
            set(handles.status, 'String', 'Done!');
        end
    end
end
guidata(hObject,handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runbutton.
function runbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MouseClickFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
if strcmp( get(handles.figure1,'selectionType') , 'normal')
    set(handles.figure1,'WindowButtonMotionFcn',{@MouseMoveFcn,hObject});
    mousepos=get(handles.sound_plot,'CurrentPoint');
    Ylim = get(handles.sound_plot,'ylim');
    Xlim = get(handles.sound_plot,'xlim');
    Xdiff = diff(Xlim);

    tolerance = Xdiff * 0.01;
    axis_pos = get(handles.sound_plot,'pos');


    % Figure out of the current point is over the axes or not -> logicals.
    tf1 = mousepos(1,1) <= Xlim(2) && mousepos(1,1) >= Xlim(1);
    tf2 = mousepos(1,2) <= Ylim(2) && mousepos(1,2) >= Ylim(1);
    lin = line([-100, -100], Ylim);
    if tf1 && tf2
        % Calculate the current point w.r.t. the axes.
        Cx = mousepos(1);
        if isfield(handles,'startline')
            for s = 1:length(handles.out)
                stX = get(handles.startline(s), 'xdata');
                enX = get(handles.endline(s), 'xdata');
                if Cx < stX + tolerance & Cx > stX - tolerance

                    set(gcf,'Pointer','left');
                    handles.click = 1;
                    handles.segmv = s;
                elseif Cx < enX + tolerance & Cx > enX - tolerance
                    set(gcf,'Pointer','left');
                    handles.click = 2;
                    handles.segmv = s;
                else
                    set(gcf,'Pointer','arrow');
    %                 handles.click = 0;
                    axes(handles.sound_plot); hold on;

    %                 handles = play_but(handles,Cx,1);
                end
            end
        end
    else
        set(gcf,'Pointer','arrow');
    %     set(handles.startline, 'xdata' , [Cx,Cx]);
    end
end
guidata(hObject,handles);


% --- Executes on mouse motion over figure - except title and menu.
function MouseMoveFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
mousepos=get(handles.sound_plot,'CurrentPoint');
Ylim = get(handles.sound_plot,'ylim');
Xlim = get(handles.sound_plot,'xlim');
Xdiff = diff(Xlim);

tolerance = Xdiff * 0.01;
axis_pos = get(handles.sound_plot,'pos');


% Figure out of the current point is over the axes or not -> logicals.
tf1 = mousepos(1,1) <= Xlim(2) && mousepos(1,1) >= Xlim(1);
tf2 = mousepos(1,2) <= Ylim(2) && mousepos(1,2) >= Ylim(1);
lin = line([-100, -100], Ylim);
if tf1 && tf2
    % Calculate the current point w.r.t. the axes.
    Cx = mousepos(1);
    if isfield(handles,'startline')
        s = handles.segmv;
        stX = get(handles.startline(s), 'xdata');
        enX = get(handles.endline(s), 'xdata');
        if handles.click == 1
            set(handles.startline(s), 'xdata' , [Cx,Cx]);
            handles.sttag(s,1).Position(1)= Cx;
            handles.sttag(s,2).Position(1)= Cx;
            set(gcf,'Pointer','left');
        elseif handles.click == 2
            set(handles.endline(s), 'xdata' , [Cx,Cx]);
            handles.entag(s,1).Position(1)= Cx;
            handles.entag(s,2).Position(1)= Cx;
            set(gcf,'Pointer','left');
        else
            set(gcf,'Pointer','arrow');
        end
    end
elseif mousepos(1,1) < Xlim(1)
    if isfield(handles,'startline')
        s = handles.segmv;
        stX = get(handles.startline(s), 'xdata');
        lims = xlim;
        if handles.click == 1
            set(handles.startline(s), 'xdata' , [1/handles.fs, 1/handles.fs]);
            set(gcf,'Pointer','left');
        else
            set(gcf,'Pointer','arrow');
        end
    end
elseif mousepos(1,1) > Xlim(2)
    if isfield(handles,'startline')
        s = handles.segmv;
        enX = get(handles.endline(s), 'xdata');
        lims = xlim;
        if handles.click == 2
            set(handles.endline(s), 'xdata' , [lims(2), lims(2)]);
            set(gcf,'Pointer','left');
        else
            set(gcf,'Pointer','arrow');
        end
    end
else
    set(gcf,'Pointer','arrow');
%     
end



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MouseReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
    if strcmp( get(handles.figure1,'selectionType') , 'normal')
    set(handles.figure1,'WindowButtonMotionFcn',{@MouseSearchFcn,hObject});
    mousepos=get(handles.sound_plot,'CurrentPoint');
    Xlim = get(handles.sound_plot,'xlim');
    Ylim = get(handles.sound_plot,'ylim');
    Xdiff = diff(Xlim);

    tolerance = Xdiff * 0.01;
    tf1 = mousepos(1,1) <= Xlim(2) && mousepos(1,1) >= Xlim(1);
    tf2 = mousepos(1,2) <= Ylim(2) && mousepos(1,2) >= Ylim(1);
    tog = get(handles.orig_rad,'Value');
    if tf1 && tf2
        if isfield(handles,'startline')
            Cx = mousepos(1);
            for s = 1:length(handles.out)
                stX = get(handles.startline(s), 'xdata');
                enX = get(handles.endline(s), 'xdata');
                if s > 1
                    enX2 = get(handles.endline(s-1), 'xdata');
                else
                    enX2 = 0;
                end
                if Cx < stX + tolerance & Cx > stX - tolerance

                    set(gcf,'Pointer','left');

                elseif Cx < enX + tolerance & Cx > enX - tolerance
                    set(gcf,'Pointer','left');

                elseif Cx < enX & Cx > enX2 & handles.click == 0
                    set(gcf,'Pointer','arrow');

                    axes(handles.sound_plot); hold on;
                    if Cx <= stX & tog == 0
                        Cx = stX(1);
                    end
    %                 handles.segmv = s;
                    handles = play_but(handles,Cx,s);

                end
                end


            handles = update_seg(handles);
        end
    end
end
guidata(hObject,handles);

% --- Executes on mouse motion over figure - except title and menu.
function MouseSearchFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
mousepos=get(handles.sound_plot,'CurrentPoint');
Ylim = get(handles.sound_plot,'ylim');
Xlim = get(handles.sound_plot,'xlim');
Xdiff = diff(Xlim);

tolerance = Xdiff * 0.01;
axis_pos = get(handles.sound_plot,'pos');


% Figure out of the current point is over the axes or not -> logicals.
tf1 = mousepos(1,1) <= Xlim(2) && mousepos(1,1) >= Xlim(1);
tf2 = mousepos(1,2) <= Ylim(2) && mousepos(1,2) >= Ylim(1);
lin = line([-100, -100], Ylim);
if isfield(handles,'player_orig')
    someplayer = ~isplaying(handles.player_orig);
else
    someplayer = 1;
end
if tf1 && tf2 && someplayer
    % Calculate the current point w.r.t. the axes.
    Cx = mousepos(1);
    if isfield(handles,'startline')
        for s = 1:length(handles.out)
            stX = get(handles.startline(s), 'xdata');
            enX = get(handles.endline(s), 'xdata');
            if Cx < stX + tolerance & Cx > stX - tolerance | ...
                Cx < enX + tolerance & Cx > enX - tolerance
                set(gcf,'Pointer','left');
            else
                set(gcf,'Pointer','arrow');
            end
        end
    end
else
    set(gcf,'Pointer','arrow');
%     set(handles.startline, 'xdata' , [Cx,Cx]);
end


% --- Executes on button press in origbut.
function origbut_Callback(hObject, eventdata, handles)
% hObject    handle to origbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of origbut
handles.origbut = get(hObject,'Value');
guidata(hObject,handles);

% --- Executes on button press in playbut.
function playbut_Callback(hObject, eventdata, handles)
% hObject    handle to playbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.playbut,'UserData',0);
for s = 1:length(handles.out)
    if get(handles.playbut,'UserData') == 1
        
        break;
    end
    handles = play_but(handles,0,s);
    pause(length(handles.out{s})/handles.fs+0.5);
    if get(handles.playbut,'UserData') == 1
        
        break;
    end
end
guidata(hObject,handles);


% --- Executes on button press in auto.
function auto_Callback(hObject, eventdata, handles)
% hObject    handle to auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto
auto = get(hObject,'Value');
if auto == 1
    set(handles.acceptbutton,'Enable','off') ;
else
    set(handles.acceptbutton,'Enable','on') ;
end


% --- Executes on button press in skipbutton.
function skipbutton_Callback(hObject, eventdata, handles)
% hObject    handle to skipbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isplaying(handles.player_orig)
    stop(handles.player_orig);
elseif isplaying(handles.player)
    stop(handles.player);
end
workingdir = handles.workingfolder;
soundfiles = handles.soundfiles;
rem = handles.remainingfiles;
f = handles.f;
if rem >=0
    
    curfile = fullfile(workingdir, soundfiles(f-1).name);
    handles.out = handles.orig;
    audiowrite(curfile, handles.out , handles.fs,'BitsPerSample',16);
%     handles.f = f+1;
%     handles.remainingfiles = rem-1;
    cla(handles.sound_plot);
    handles = rmfield(handles,'startline');
    handles =  mainfunction2(handles,hObject);
    if rem == 0
        set(handles.status, 'String', 'Done!');
    end
end
guidata(hObject,handles);


% --- Executes on button press in revertbutton.
function revertbutton_Callback(hObject, eventdata, handles)
% hObject    handle to revertbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.sound_plot);
handles.f = handles.f -1 ;
handles.remainingfiles = handles.remainingfiles + 1;
handles = mainfunction2(handles,hObject);
guidata(hObject,handles);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
key = eventdata.Key;
if isfield(handles,'startline')
    
    if strcmp(key,'space')
        for s = 1:length(handles.out)
            handles = play_but(handles,0,s);
        end
        guidata(hObject,handles);
    end
end
% pause;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function playbut_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to playbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function splitbut_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to splitbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uitoggletool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom xon;


% --------------------------------------------------------------------
function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan xon;
