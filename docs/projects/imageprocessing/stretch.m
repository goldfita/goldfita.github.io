function [imout]=stretch(imagein)

s=size(imagein);
imagein=double(imagein);
imout=zeros(s(1),s(2));
a=min(imagein(:));%find min and max pixel values to determine stretch constants
b=max(imagein(:));

imagein = (imagein > a).*imagein;%set values less than a to zero
imagein = (imagein >= b)*255+(imagein<b).*imagein;%set values more than b to 255
imout = uint8(255*(a-imagein)/(a-b));%do the stretch
