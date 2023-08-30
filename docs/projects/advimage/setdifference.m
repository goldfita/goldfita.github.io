function newset=setdifference(set1,set2)
%Todd Goldfinger
%finds the difference of 2 equal dimension binary sets

%use previous functions to implement differencing
newset=setintersection(set1,setcomplement(set2));