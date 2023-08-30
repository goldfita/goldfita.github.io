function newset=setintersection(set1,set2)
%Todd Goldfinger
%finds the intersection of 2 equal dimension binary sets

newset=uint8(double(set1).*double(set2));
newset=(newset==1);