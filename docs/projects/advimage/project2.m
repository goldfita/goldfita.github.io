% Read in the image
% set myfile='filename'
image = imread(myfile,'bmp');
imageDub = double(rgb2gray(image));

% Calculate the mean image intensity
EIntensMean = mean(imageDub(:));
EIntensSqMean = mean(imageDub(:).^2);

% Calculate the mean gradient of the image in the x and y direction
[gradx, grady] = gradient(imageDub);

gradxNorm=sqrt(gradx.^2+grady.^2).*gradx;
gradyNorm=sqrt(gradx.^2+grady.^2).*grady;

EGradientMeanx=mean(gradxNorm(:));
EGradientMeany=mean(gradyNorm(:));

% Calculate rho
gamma = sqrt(6*pi^2*EIntensSqMean - 48*EIntensMean^2);
rho = gamma/pi;

% Calculate sigma
sigma = acos((4*EIntensMean)/gamma);

% Calculate tan(tau)
tau = atan(EGradientMeany/EGradientMeanx);

% Calculate i
i = [cos(tau)*sin(sigma), sin(tau)*sin(sigma), cos(sigma)];

% Start the large for loop
N = 1;
s=size(imageDub);
p=zeros(rows,cols);
q=zeros(rows,cols);
pnext=p;
qnext=q;
rows=s(1);
cols=s(2);

lambda=1000;

omegax=zeros(rows,cols);
omegay=zeros(rows,cols);
%THIS PROBABLY ISN'T RIGHT!!!!!!!
for n = 1:cols
   omegax(n,:)=2*pi*[0:cols-1]*(n-1)/(cols-1);
end
for n = 1:rows
   omegay(:,n)=2*pi*[0:rows-1]'*(n-1)/(rows-1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%use natural boundaries (p and q are zero on the border)
for n = 1:N
   %reflectance map
   R = rho*(-p*i(1)-q*i(2)+i(3))./sqrt(1+p.*p+q.*q);
   R = (R>=0).*R;  %set negative reflectance values to zero
   
   %iterate p and q
   for r = 2:rows-1
      for c = 2:cols-1
         drdp = (R(r+1,c)-R(r-1,c))/2;  %h==1
         pnext(r,c) = (p(r-1,c)+p(r+1,c)+p(r,c-1)+p(r,c+1)+lambda*(imageDub(r,c)-R(r,c))*drdp)/4;
 			drdq = (R(r,c+1)-R(r,c-1))/2;  %h==1
         qnext(r,c) = (q(r-1,c)+q(r+1,c)+q(r,c-1)+q(r,c+1)+lambda*(imageDub(r,c)-R(r,c))*drdq)/4;
      end
   end
   
   %enforce integrability
   p_freq=fft2(pnext);
   q_freq=fft2(qnext);
   
   c=(-j*omegax.*p_freq-j*omegay.*q_freq)./(omegax.*omegax+omegay.*omegay);
   c(1,:)=0;  %fix the divide by zero problem (DC coefficients)
   c(:,1)=0;
   p=ifft2(j*omegax*c);
   q=ifft2(j*omegay*c);
   
end

%get height map
z=ifft2(c);