function newimg=mydilate(img,struct)
%Todd Goldfinger
%dilates a binary image using a 3x3 structuring element

newstruct=struct([3 2 1],:);
newstruct=newstruct(:,[3 2 1]);

s=size(img);
%make the image have an larger border so there are no
%index out of bound problems
newimg=zeros(s(1)+2,s(2)+2);
newimg(2:s(1)+1,2:s(2)+1)=img;
tmpimg=newimg;
%only look at object points
[r,c]=find(tmpimg==1);
for i=1:length(r)
   %ignore the image boundary
   if (r(i)~=s(1)+1) & (r(i)~=2) & (c(i)~=s(2)+1) & (c(i)~=2)
      %if the pixel before and after a row, or column are different, we're on the border 
		if (tmpimg(r(i)-1,c(i)) ~= tmpimg(r(i)+1,c(i)) | (tmpimg(r(i),c(i)-1) ~= tmpimg(r(i),c(i)+1)))
      	newimg(r(i)-1:r(i)+1,c(i)-1:c(i)+1)=newstruct | tmpimg(r(i)-1:r(i)+1,c(i)-1:c(i)+1);
   	end
	end
end
%fix the image size
newimg=newimg(2:s(1)+1,2:s(2)+1);