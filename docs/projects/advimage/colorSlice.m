function newimg=colorSlice(img,low,high,R,G,B)
%convert a range of gray scale values in a gray scale
%image to color
%
%low and high give the range of values to change
%R,G,B are the RGB values to replace the gray values

s=size(img);
newimg=zeros([s(1),s(2),3]);
newimg(:,:,1)=img;
newimg(:,:,2)=img;
newimg(:,:,3)=img;
newimg(:,:,1)=and(double(newimg(:,:,1)>=low),double(newimg(:,:,1)<=high))*R+newimg(:,:,1);
newimg(:,:,2)=and(double(newimg(:,:,2)>=low),double(newimg(:,:,2)<=high))*G+newimg(:,:,2);
newimg(:,:,3)=and(double(newimg(:,:,3)>=low),double(newimg(:,:,3)<=high))*B+newimg(:,:,3);
newimg=uint8(newimg);