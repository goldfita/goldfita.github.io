function [imout]=histequal(imagein)

imagein=uint8(double(imagein)+1);
s=size(imagein);
hist=zeros(1,256);

for down = 1:s(1);
   for across = 1:s(2);
      hist(imagein(down,across)) = hist(imagein(down,across)) + 1;
   end;
end;
cum=cumsum(hist);
cum=uint8(round(cum.*(255/max(cum))));

imout=zeros(s(1),s(2));
for down = 1:s(1);
   for across = 1:s(2);
      imout(down,across) = cum(imagein(down,across));
   end;
end;

imout=uint8(imout);