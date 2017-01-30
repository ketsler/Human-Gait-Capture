function varargout = Skeleton(varargin)
% SKELETON MATLAB code for Skeleton.fig
%      SKELETON, by itself, creates a new SKELETON or raises the existing
%      singleton*.
%
%      H = SKELETON returns the handle to a new SKELETON or the handle to
%      the existing singleton*.
%
%      SKELETON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SKELETON.M with the given input arguments.
%
%      SKELETON('Property','Value',...) creates a new SKELETON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Skeleton_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Skeleton_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Skeleton

% Last Modified by GUIDE v2.5 18-Feb-2013 21:18:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Skeleton_OpeningFcn, ...
                   'gui_OutputFcn',  @Skeleton_OutputFcn, ...
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
% Define global variable
global Slider_max;      %max slider value
Slider_max = 100;
global Slider_min;      %min slider value
Slider_min = 0;
global Xlim;            %axis informatoin
Xlim = [-3000, 3000];
global Ylim;
Ylim = [-2000, 2000];
global Zlim;
Zlim = [-2000, 2000];
global Start_animation;
Start_animation = false;



% --- Executes just before Skeleton is made visible.
function Skeleton_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Skeleton (see VARARGIN)

% Choose default command line output for Skeleton
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject, 'Menubar','figure');
% UIWAIT makes Skeleton wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Skeleton_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --- Executes during object creation, after setting all properties.
function ShowSkeleton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ShowSkeleton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ShowSkeleton
global Xlim;
global Ylim;
global Zlim;
set(hObject, 'Xlim', Xlim,'Ylim',Ylim,'Zlim',Zlim,'Units','normalized',...
    'Xtick', (Xlim(1):500:Xlim(2)),'Ytick',(Ylim(1):400:Ylim(2)), 'Ztick',(Zlim(1):400:Zlim(2)),...
    'View',[-37.5,30.0]);
%     'Xtick', (Xlim(1):500:Xlim(2)),'Ytick',(Ylim(1):400:Ylim(2)), 'Ztick',(Zlim(1):400:Zlim(2)),...
grid on;
hold on;


% --- Executes on slider movement.
function slider_time_Callback(hObject, eventdata, handles)
% hObject    handle to slider_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%% Delete previous skeleton information and write new skeleton
% current value of the slider
current_value = round(get(hObject, 'Value'));
if current_value == 0
    current_value = 1;
end
% current all children of the axes
H_all_children = get(handles.ShowSkeleton, 'children');
% current all line children of the axes
H_line_children = findobj(H_all_children,'type','line');
% remove previous skeleton
delete(H_line_children);
% plot the new skeleton
global Skeleton_data;
global Frame_index;
global Dimension;
global List;
% display the new value in edit box
set(handles.edit_frame, 'string', num2str(current_value));
% plot all skeletons of the current frame  
for j=1:Frame_index(current_value,2)
    drawSkeleton(handles.ShowSkeleton, Skeleton_data(Frame_index(current_value,3) ...
        + Dimension*(j-1):Frame_index(current_value,3) + Dimension*j - 1, 1:3), List);
end





% --- Executes during object creation, after setting all properties.
function slider_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global Slider_max;
slider_step = 1/(Slider_max);    %the slider step
set(hObject, 'Min', 0, 'Max', Slider_max, 'Sliderstep',[slider_step, slider_step]);

function edit_frame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame as text
%        str2double(get(hObject,'String')) returns contents of edit_frame as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_file as text
%        str2double(get(hObject,'String')) returns contents of edit_file as a double


% --- Executes during object creation, after setting all properties.
function edit_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Tframe_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Tframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Tframe as text
%        str2double(get(hObject,'String')) returns contents of edit_Tframe as a double


% --- Executes during object creation, after setting all properties.
function edit_Tframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Tframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Function used to draw a skeleton in a given axes
function drawSkeleton(hObject, Skeleton_frame, List)
nb_edge = size(List,1);
nb_joint = size(Skeleton_frame, 1);
%% First plot all joints
for i=1:nb_joint
    line(Skeleton_frame(i,1),Skeleton_frame(i,2), Skeleton_frame(i,3),'marker','.', 'markersize',20,'Color','b','Parent',hObject);
end
%% Then plot all edges
for i=1:nb_edge
    line( [Skeleton_frame(List(i,1),1), Skeleton_frame(List(i,2),1)],  [Skeleton_frame(List(i,1),2), Skeleton_frame(List(i,2),2)], [Skeleton_frame(List(i,1),3),Skeleton_frame(List(i,2),3)],...
          'LineStyle', '-', 'Color','k','LineWidth',2,'Parent', hObject);
end

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% open the data and process it
global File_name;
global File_path;
[File_name, File_path] = uigetfile({'*.txt'});
set(handles.edit_file, 'string', File_name);  %display the file loaded
File_path = [File_path, File_name];           %path to data
fid = fopen(File_path, 'r');
global Slider_max;
global Dimension; %% Number of joints of data
global Software_platform; 
global List;  
Software_platform = fgetl(fid); %% Software platform name
Slider_max = str2double(fgetl(fid)); %% Total number of frames
Dimension = str2double(fgetl(fid)); %% Total number of joints per frame
if( strcmp(Software_platform,'Microsoft Kinect SDK') && Dimension == 20)
    List = [1, 2; 2, 3; 3, 4; 3, 5; 5, 6; 6, 7; 7, 8; 3, 9; 9, 10; 10, 11; 11, 12;...
        1, 13; 13, 14; 14, 15; 15, 16; 1, 17; 17, 18; 18, 19; 19, 20];
elseif( strcmp(Software_platform,'Microsoft Kinect SDK') && Dimension == 15)
    List = [1, 2; 2, 3; 2,4; 4, 5; 5, 6; 2, 7; 7, 8; 8, 9;...
        1,10; 10, 11; 11, 12; 1, 13; 13, 14;14, 15];
elseif( strcmp(Software_platform,'OpenNI/NITE') && Dimension == 15)
    List = [3, 2; 2, 1; 2, 4; 2, 7; 4, 5; 5, 6; 7, 8; 8, 9; 3, 10; 10, 11;...
        11, 12; 3, 13; 13, 14; 14, 15];
else
    msgbox('Unknown software platform and dimension combination!!!');
    return;
end
slider_step = 1/(Slider_max);
%update slider and edit text
set(handles.slider_time, 'Max', Slider_max,'Sliderstep',[slider_step, slider_step]);
set(handles.edit_Tframe, 'string', num2str(Slider_max));
set(handles.total_frame, 'string', num2str(Slider_max));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First round: Obtain the index matrix which is useful when accessing
% skeleton data
global Frame_index;
Frame_index = zeros(Slider_max, 3);
for i=1:Slider_max
    Frame_index(i,1) = i;   %index of frame
    fgetl(fid);
    Frame_index(i,2) = str2double(fgetl(fid)); %# of skeleton per frame
    if( Frame_index(i,2) == -1)
        Frame_index(i,2) = 0;
    end
    if( i == 1)             % start location of data per frame
        Frame_index(i,3) = 1;
    else
        Frame_index(i,3) = Dimension * Frame_index(i-1,2) + Frame_index(i-1,3);
    end
    for j=1:Frame_index(i,2)
        temp = fscanf(fid, '%f\n', [3 Dimension]);
    end
end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second round: Now obtain the skeleton data
global Skeleton_data;
Skeleton_data = zeros(Frame_index(Slider_max, 3)+...
    Dimension*Frame_index(Slider_max,2)-1,3);
fid = fopen(File_path, 'r');
fgetl(fid); fgetl(fid); fgetl(fid);
for i=1:Slider_max
    fgetl(fid); fgetl(fid);
    for j=1:Frame_index(i,2)
        temp = fscanf(fid,'%f\n',[3 Dimension]);  %read the data for each user
        Skeleton_data(Frame_index(i,3) + Dimension*(j-1):Frame_index(i,3) + Dimension*j - 1,...
            1:3) = temp';
    end
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we reset axes properties
global Xlim;
global Ylim;
global Zlim;
shift = 100;
Xlim(1) = min(Skeleton_data(:,1))-shift;
Xlim(2) = max(Skeleton_data(:,1))+shift;
Ylim(1) = min(Skeleton_data(:,2))-shift;
Ylim(2) = max(Skeleton_data(:,2))+shift;
Zlim(1) = min(Skeleton_data(:,3))-shift;
Zlim(2) = max(Skeleton_data(:,3))+shift;
axis(handles.ShowSkeleton, 'equal');
set(handles.ShowSkeleton, 'Xlim', Xlim,'Ylim',Ylim,'Zlim',Zlim,'View',[-37.5,30.0]);  %reset axes
title(handles.ShowSkeleton, 'Skeleton');
delete(get(handles.ShowSkeleton, 'Children'));
grid on;
hold on;
set(handles.slider_time, 'value', 0);  %reset slider
set(handles.edit_frame, 'string', '0'); %reset text


% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% now start to animate the skeleton data
global Skeleton_data;
global Frame_index;
global Dimension;
global Start_animation;
global List;
Start_animation = true;
%% Avi file
aviobj = avifile('RSAUs.avi','compression','None');
aviobj.fps = 15;
aviobj.quality = 10;

%disable irrelevant slider or buttons
set(handles.slider_time, 'Enable','off');
set(handles.pushbutton_load, 'Enable', 'off');
set(handles.pushbutton_exit, 'Enable', 'off');
set(handles.edit_frame, 'Enable', 'off');
%obtain current slider values
current_value = round(get(handles.slider_time, 'value'));
max_value = round(get(handles.slider_time, 'max'));
%start displaying skeleton data


%%now process the validity mask
%%SkeletonW = LoadSkeleton('04_01_01_01.txt', 3);
%%V = WalkingForward(SkeletonW);

for j=1:5
    for i=1:max_value
        if( i == 0)
            i = i + 1;
        end
        set(handles.slider_time, 'value', i); %update the slider
        set(handles.edit_frame, 'string', num2str(i)); %update text
        % current all children of the axes
        H_all_children = get(handles.ShowSkeleton, 'children');
        % current all line children of the axes
        H_line_children = findobj(H_all_children,'type','line');
        % remove previous skeleton
        delete(H_line_children);
        % plot all skeletons of the current frame  
        %%if( V(i) > 0)
            for j=1:Frame_index(i,2)
                drawSkeleton(handles.ShowSkeleton, Skeleton_data(Frame_index(i,3) ...
                    + Dimension*(j-1):Frame_index(i,3) + Dimension*j - 1, 1:3), List);
            end
        %%end
        F = getframe(handles.ShowSkeleton);
        aviobj = addframe(aviobj,F);
        pause(0.0001);
        if( ~Start_animation )
            break;
        end
    end
end
aviobj = close(aviobj);
%able disabled slider or buttons
set(handles.slider_time, 'Enable','on');
set(handles.pushbutton_load, 'Enable', 'on');
set(handles.pushbutton_exit, 'Enable', 'on');
set(handles.edit_frame, 'Enable','on');


% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Start_animation;
Start_animation = false;


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);



function total_frame_Callback(hObject, eventdata, handles)
% hObject    handle to total_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of total_frame as text
%        str2double(get(hObject,'String')) returns contents of total_frame as a double


% --- Executes during object creation, after setting all properties.
function total_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to total_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global Slider_max;
set(hObject, 'string', num2str(Slider_max));


% --- Executes on button press in SaveToFile.
function SaveToFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveToFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Skeleton_data;
global Frame_index; %[global index, number of skeleton, start location of skeleton data]
global Software_platform;
global Dimension;
[FileName,PathName] = uiputfile('.txt');
FilePath = [PathName, FileName];
% get the left range and right range of the clip
left_range = str2double(get(handles.edit_left, 'string'));
right_range = str2double(get(handles.edit_right, 'string'));
% check validity of ranges
 if( right_range <= left_range || left_range < 1) %|| right_range > size(Skeleton_data,1)/20+1)
     msgbox('Range error!!!','error','error');
     return;
 end
% save the corresponding range
length = right_range - left_range;
fid = fopen(FilePath, 'wt');
fprintf(fid, '%s\r%d\r%d\r', Software_platform, length, Dimension);
% for i=1:length
%     fprintf(fid, '%d\r', i); % index of frame
%     fprintf(fid, '%d\r', 1); % number of skeleton
%     for j=1:Dimension
%         fprintf(fid, '%f %f %f\r', Skeleton_data( (left_range+i-2)*Dimension+j, 1),...
%             Skeleton_data( (left_range+i-2)*Dimension+j, 3),...
%             Skeleton_data( (left_range+i-2)*Dimension+j, 2));
%     end
% end
for i=1:length
    fprintf(fid, '%d\r', i); % index of frame
    fprintf(fid, '%d\r', 1); % number of skeleton
    for j=1:Dimension
        left = Frame_index(left_range + i - 1, 3);
        fprintf(fid, '%f %f %f\r', Skeleton_data( left + j - 1, 1),...
            Skeleton_data( left + j - 1, 2),...
            Skeleton_data( left + j - 1, 3));
    end
end
fclose(fid);



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over SaveToFile.
function SaveToFile_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SaveToFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_left_Callback(hObject, eventdata, handles)
% hObject    handle to edit_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_left as text
%        str2double(get(hObject,'String')) returns contents of edit_left as a double


% --- Executes during object creation, after setting all properties.
function edit_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_right_Callback(hObject, eventdata, handles)
% hObject    handle to edit_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_right as text
%        str2double(get(hObject,'String')) returns contents of edit_right as a double


% --- Executes during object creation, after setting all properties.
function edit_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
