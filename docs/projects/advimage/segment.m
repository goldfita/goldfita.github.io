function segimg=segment(img,R,G,B,Rrange,Grange,Brange)
%Segments a color image in RGB space
%R,G, and B are the red-green-blue components in the
%  color cube.  Rrange,Grange, and Brange give the
%  absolute distance from R,G, and B in each color
%  plane that will be kept.  This area will show up
%  as white in the image returned.

%split into RGB color planes
imgR=img(:,:,1);
imgG=img(:,:,2);
imgB=img(:,:,3);

%remove color outside the cube range
segimgR=imgR>(R-Rrange) & imgR<(R+Rrange);
segimgG=imgG>(G-Grange) & imgG<(G+Grange);
segimgB=imgB>(B-Brange) & imgB<(B+Brange);

%put the planes back together
s=size(img);
segimg=double(segimgR).*double(segimgR).*double(segimgB);