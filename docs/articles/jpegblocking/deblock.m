[r,c] = size(img);
shift = 6;
im = zeros(r+shift,c+shift);
rnew = r+shift;
cnew = c+shift;
im(shift/2+1:rnew-shift/2,shift/2+1:cnew-shift/2) = img;
outsum = zeros(size(img));
quality = 60;
weights = [1:shift/2+1, shift/2:-1:1];
weights = (weights'*weights).^2;

for srow=1:shift+1
  for scol=1:shift+1
    out = encode(im(srow:srow+r-1,scol:scol+c-1),quality);
    outsum = outsum + out*weights(srow,scol);
  end
end
outsum = round(outsum/sum(weights(:)));


