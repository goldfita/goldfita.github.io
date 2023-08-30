function webimg=toWebSafe(img)
% convert an RGB image to a websafe image

s=size(img);
webimg=zeros([s(1) s(2) s(3)]);
webimg(:,:,:)=and(double(img(:,:,:)>=42),double(img(:,:,:)<=84))*51.0;
webimg(:,:,:)=and(double(img(:,:,:)>=85),double(img(:,:,:)<=127))*102.0+webimg;
webimg(:,:,:)=and(double(img(:,:,:)>=128),double(img(:,:,:)<=171))*153.0+webimg;
webimg(:,:,:)=and(double(img(:,:,:)>=172),double(img(:,:,:)<=212))*204.0+webimg;
webimg(:,:,:)=double(img(:,:,:)>=213)*255.0+webimg;
webimg=uint8(webimg);