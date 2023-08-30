in=randn(1,10000);
in=in/max(abs(in))*.9999;
outfloat=filter(.8:-.1:.1,1,in);
outfixed=fpfir(in,length(in));
plot(outfloat(:)-outfixed(:));
title('Error');