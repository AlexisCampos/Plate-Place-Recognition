clc;
clear all;
%close all;
img= imread('D:\Documentos\Maestria\1er Semestre\Vision Artificial\ProyectoOficial\img\march3.jpg');
subplot(4,3,1),imshow(img),title('Imagen Original');
img_gray = rgb2gray(img); %Convertir a escala de grises

subplot(4,3,2),imshow(img_gray),title('Imagen BN');

[sizeX,sizeY]=size(img_gray);
if (sizeX>800 &&sizeY>900)
    img = imresize(img, 0.25);
    img_gray = imresize(img_gray, 0.25);
end

%figure(1)
%imshow(a)
img_grayD= double(img_gray);

[row, col]=size(img_grayD);

BW = edge(double(img_grayD),'sobel'); %Detector de bordes sobel
subplot(4,3,3),imshow(BW),title('Filtro Sobel');

se = strel('rectangle',[3,8]); %Elemento Estructural 
closeBW = imclose(BW,se); 
subplot(4,3,4),imshow(closeBW),title('Morfologia Close');

fillHolesBW = imfill(closeBW,'holes'); %Relleno de agujeros
subplot(4,3,5),imshow(fillHolesBW),title('Relleno de Agujeros');


openBW = imopen(fillHolesBW,se); %Morfologia Matematica
subplot(4,3,6),imshow(openBW),title('Morfologia Open');

openBW = imclearborder(openBW,8);
subplot(4,3,7),imshow(openBW),title('Limpiar Bordes');

openBW = bwareafilt(openBW, [400, 10000]); %Se quedan los objetos que se encuentren en ese rango de imagen
subplot(4,3,8),imshow(openBW),title('bwareopen');


labeledImage = bwlabel(openBW, 8);


regionProp = regionprops(labeledImage, img_gray, 'all');   

number = size(regionProp, 1)


for k = 1 : number          
		thisBoundingBox = regionProp(k).BoundingBox; 

		subImage = imcrop(img, thisBoundingBox);
        subplot(4,3,9),imshow(subImage),title('subimage');
        subplot(4,3,10),imshow(subImage),title('rectangle');
        imshow(img);
        rectangle('Position',thisBoundingBox,'EdgeColor','r','LineWidth',1);
        
        [x, y]= size(subImage);
        if(x >=21 && y >=100)
            
            subplot(4,3,11),imshow(subImage),title('subimage');
            imwrite(subImage,'plate.jpg');
            
            break;
        end
        %regionProp(k,:)=[];
end


    
