function [imout]=removetrend(imagein)

mask=3;
mid=round(mask/2);
range=mask-1;
div=1/(mask*mask);
s = size(imagein);
imout=zeros(s(1),s(2));

for down = 1:s(1)-range;
   for across = 1:s(2)-range;
      tmp = imagein(down:down+range,across:across+range);
      imout(down+mid,across+mid) = div*sum(tmp(:));
   end;
end;


imout=imout-double(imagein);
%t=min(imout(:));
%if t < 0
   %imout=imout-t;
   %imout=imout*255/max(imout(:));
%end;
imout=histeq(uint8(imout));
