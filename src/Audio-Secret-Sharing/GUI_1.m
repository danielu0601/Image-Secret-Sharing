function varargout = GUI_1(varargin)
% GUI_1 MATLAB code for GUI_1.fig
%      GUI_1, by itself, creates a new GUI_1 or raises the existing
%      singleton*.
%
%      H = GUI_1 returns the handle to a new GUI_1 or the handle to
%      the existing singleton*.
%
%      GUI_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_1.M with the given input arguments.
%
%      GUI_1('Property','Value',...) creates a new GUI_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_1

% Last Modified by GUIDE v2.5 09-May-2018 17:06:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_1_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_1_OutputFcn, ...
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


% --- Executes just before GUI_1 is made visible.
function GUI_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_1 (see VARARGIN)

% Choose default command line output for GUI_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
filename = 'sample.wav';
[y_org, handles.Fs] = audioread(filename);
y_org = reshape(y_org,1,[]);
handles.y_idx = 1;

tic

dct_size = 1024;
len_o = length(y_org);
len_n = ceil(len_o/dct_size)*dct_size;
if len_n > len_o
    y_org(len_n) = 0;
end
len = len_n;

for i = 1:dct_size:len
    t_y(i:i+dct_size-1) = dct(y_org(i:i+dct_size-1));
end

Scale = [1 9 24 48 88 148 200 225 256];
n_y = zeros(9,len);
for j = 1:9
    counter = Scale(j);
    for i = 1:dct_size:len
        %t_y(i:i+dct_size-1) = idct( [t_y(i:i+dct_size-1)] );
        n_y(j, i:i+dct_size-1) = idct( [t_y(i:i+counter-1) zeros(1,dct_size-counter)] );
    end
end

toc

handles.y = n_y;
handles.p = audioplayer(n_y(9,:), handles.Fs);

% Update handles structure
guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = GUI_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
a = get(handles.slider1, 'Value');
set(handles.text5, 'String', [num2str(100*a, '%2.0f') '%']);


counter = ceil(6*a);

now_id = handles.p.CurrentSample;
now_id = now_id + handles.y_idx;
q = audioplayer(handles.y(counter, now_id:end), handles.Fs);
play(q);
pause(handles.p);
handles.p = q;
handles.y_idx = now_id;
guidata(hObject, handles);

pushbutton1_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
% Start
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resume(handles.p);

a = get(handles.slider1, 'Value');

% handles.peaks = peaks(35*a);
% handles.membrane = membrane;
% [x,y] = meshgrid(-8:0.5:8);
% r =sqrt(x.^2+y.^2) + eps;
% sinc = sin(r)./r;
% handles.sinc = sinc;
% handles.current_data =handles.peaks;
plot(handles.axes1, handles.y(ceil(6*a), :))


% --- Executes on button press in pushbutton2.
% Stop
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause(handles.p);



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = get(handles.slider1, 'Value');

counter = ceil(6*a);

handles.p = audioplayer(handles.y(counter, :), handles.Fs);
play(handles.p);
handles.y_idx = 1;
guidata(hObject, handles);

%pushbutton1_Callback(hObject, eventdata, handles)