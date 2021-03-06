function varargout = Interface(varargin)
% INTERFACE MATLAB code for Interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Interface

% Last Modified by GUIDE v2.5 17-May-2021 11:13:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Interface_OpeningFcn, ...
                   'gui_OutputFcn',  @Interface_OutputFcn, ...
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


% --- Executes just before Interface is made visible.
function Interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Interface (see VARARGIN)

% Choose default command line output for Interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnImg.
function btnImg_Callback(hObject, eventdata, handles)
% hObject    handle to btnImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
[filename, path]=uigetfile(('*.bmp; *.png; *.jpg'),'Abrir Imagen');
img=imread(strcat(path, filename));
set(handles.lblImgName,'String',filename);
axes(handles.axesImg);
imshow(img);
handles.img=img;
guidata(hObject, handles);


% --- Executes on button press in btnSearch.
function btnSearch_Callback(hObject, eventdata, handles)
% hObject    handle to btnSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
%close all;
img=handles.img;
img_gray = rgb2gray(img); %Convertir a escala de grises

[sizeX,sizeY]=size(img_gray);
if (sizeX>800 &&sizeY>900)
    img = imresize(img, 0.25);
    img_gray = imresize(img_gray, 0.25);
end

img_grayD= double(img_gray);

[row, col]=size(img_grayD);

sobel = edge(double(img_grayD),'sobel'); %Detector de bordes sobel

se = strel('rectangle',[3,8]); %Elemento Estructural 
closeSobel = imclose(sobel,se); 

fillHoles = imfill(closeSobel,'holes'); %Relleno de agujeros

openSobel = imopen(fillHoles,se); %Morfologia Matematica

openSobelBor = imclearborder(openSobel,8);
openSobelFilt = bwareafilt(openSobelBor, [600, 10000]); %Se quedan los objetos que se encuentren en ese rango de imagen

labeledImage = bwlabel(openSobelFilt, 8);

regionProp = regionprops(labeledImage, img_gray, 'all');   

number = size(regionProp, 1);

for i = 1 : number          
		thisBoundingBox = regionProp(i).BoundingBox; 

		subImage = imcrop(img, thisBoundingBox);
       
        [x, y]= size(subImage);
        if(x >=20 && y >=100)
            axes(handles.axesImg);
            imshow(img);
            rectangle('Position',thisBoundingBox,'EdgeColor','r','LineWidth',1);
            axes(handles.axesPlate);
            imshow(subImage);
            handles.i=i;
            %
            break;
        end
        %regionProp(k,:)=[];
end
handles.img=img;
handles.img_gray=img_gray;
handles.sobel=sobel;
handles.closeSobel=closeSobel;
handles.fillHoles=fillHoles;
handles.openSobel=openSobel;
handles.openSobelBor=openSobelBor;
handles.openSobelFilt=openSobelFilt;
handles.subImage=subImage;
handles.regionProp=regionProp;
guidata(hObject, handles);

% --- Executes on button press in btnYes.
function btnYes_Callback(hObject, eventdata, handles)
% hObject    handle to btnYes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subImage=handles.subImage;
filepath='D:\Documentos\Maestria\1er Semestre\Vision Artificial\ProyectoOficial\placa\';
filename='plate.jpg';
file=strcat(filepath, filename);
imwrite(subImage,file);
msgbox('Se ha guardado la imagen','Completado');

% --- Executes on button press in btnNo.
function btnNo_Callback(hObject, eventdata, handles)
% hObject    handle to btnNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    regionProp=handles.regionProp;
    number = size(regionProp, 1);
    i=handles.i;
    regionProp(i,:)=[];
    img=handles.img;


    for k = 1 : number        
        thisBoundingBox = regionProp(k).BoundingBox; 

        subImage = imcrop(img, thisBoundingBox);

        [x, y]= size(subImage);
        if(x >=20 && y >=100)
            axes(handles.axesImg);
            imshow(img);
            rectangle('Position',thisBoundingBox,'EdgeColor','r','LineWidth',1);
            axes(handles.axesPlate);
            imshow(subImage);
            handles.i=k;
            handles.subImage=subImage;
            %
            break;
        else
        end
    end
catch
    msgbox('No se ha encontrado placa','Error','error');
end

handles.regionProp=regionProp;
guidata(hObject, handles);


% --- Executes on button press in btnProcess.
function btnProcess_Callback(hObject, eventdata, handles)
% hObject    handle to btnProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img=handles.img;
img_gray=handles.img_gray;
sobel=handles.sobel;
closeSobel=handles.closeSobel;
fillHoles=handles.fillHoles;
openSobel=handles.openSobel;
openSobelBor=handles.openSobelBor;
openSobelFilt=handles.openSobelFilt;
subImage=handles.subImage;

figure(1);
subplot(4,3,1),imshow(img),title('Imagen Original');
subplot(4,3,2),imshow(img_gray),title('Imagen Blanco y Negro');
subplot(4,3,3),imshow(sobel),title('Detector de Bordes Sobel');
subplot(4,3,4),imshow(closeSobel),title('Morfolog?a Matem?tica Close');
subplot(4,3,5),imshow(fillHoles),title('Rellenar Hoyos');
subplot(4,3,6),imshow(openSobel),title('Morfolog?a Matem?tica Open');
subplot(4,3,7),imshow(openSobelBor),title('Limpiar Bordes');
subplot(4,3,8),imshow(openSobelFilt),title('Eliminar Pixeles');
subplot(4,3,9),imshow(subImage),title('Sub-Imagen');
