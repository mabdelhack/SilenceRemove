function varargout = finished(varargin)
% FINISHED MATLAB code for finished.fig
%      FINISHED, by itself, creates a new FINISHED or raises the existing
%      singleton*.
%
%      H = FINISHED returns the handle to a new FINISHED or the handle to
%      the existing singleton*.
%
%      FINISHED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINISHED.M with the given input arguments.
%
%      FINISHED('Property','Value',...) creates a new FINISHED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before finished_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to finished_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help finished

% Last Modified by GUIDE v2.5 29-Jan-2017 18:39:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @finished_OpeningFcn, ...
                   'gui_OutputFcn',  @finished_OutputFcn, ...
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

% --- Executes just before finished is made visible.
function finished_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to finished (see VARARGIN)

% Choose default command line output for finished

handles.output = hObject;
handles.accept = 0;
handles.plot = varargin{1};
handles.fs = varargin{2};
axes(handles.fin);
time = 0:1/handles.fs:length(handles.plot)/handles.fs;
plot(time(1:end-1), handles.plot, 'Color' , [0 , 0, 1]);
xlim([time(1) , time(end-1)]);
halfheight = max(abs(handles.plot));
ylim([-halfheight , halfheight]);
set(handles.fin,'XTick',0:(floor(time(end-1)/10)+1):floor(time(end)));
handles.plfin = audioplayer(handles.plot,handles.fs);
handles = play_but1(handles);
% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using finished.

% UIWAIT makes finished wait for user response (see UIRESUME)
uiwait(handles.fingui);


% --- Outputs from this function are returned to the command line.
function varargout = finished_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.accept;

% The figure can be deleted now
delete(handles.fingui);

% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.output = 1;
handles.accept = 1;
guidata(hObject, handles);
uiresume(handles.fingui);
% close(handles.fingui);


% --- Executes on button press in goback.
function goback_Callback(hObject, eventdata, handles)
% hObject    handle to goback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.accept = 0;
guidata(hObject, handles);
uiresume(handles.fingui);
% close(handles.fingui);


% --- Executes when user attempts to close fingui.
function fingui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fingui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject)
else
    delete(hObject);
end
