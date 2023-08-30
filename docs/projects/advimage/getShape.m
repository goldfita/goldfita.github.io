function z=getShape(img)
%a = E[i] / cos(s)
%z(x,y) = z(x-1,y) + [i(x,y) - a cos(s)] / a sin(s)

img=double(img);
E=mean(img(:));
s=80*pi/180;
dim=size(img);
z=zeros(dim(1),dim(2));

for row=2:dim(1)
   z(row,:)=z(row-1,:)+(img(row,:)-E)/(E*tan(s));
end
