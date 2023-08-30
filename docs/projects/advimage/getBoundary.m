function bnd=getBoundary(img);
%returns an image with the boundary of img using the erosion method
%img is a binary image

struct=ones(3,3);
erodedImg=myerode(img,struct);
imshow(erodedImg);
bnd=uint8(double(img)-double(erodedImg));
bnd=(bnd>0);