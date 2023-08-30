% Read in the image
image = imread('tooth2.bmp','bmp');
imageDub = double(rgb2gray(image));

[rows, cols] = size(imageDub);

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
N = 100;

p = zeros([rows,cols]);
q = p;
R = p;

s = [0,.25,0; .25,0,.25; 0,.25,0];

sp = [0,0,0; -.5,0,.5; 0,0,0];

sq = [-0,.5,0; 0,0,0; 0,.5,0];

lambda = 1000;

omegax=zeros(rows,cols);
omegay=zeros(rows,cols);
%THIS PROBABLY ISN'T RIGHT!!!!!!!
for itr = 1:cols
   omegax(itr,:)=2*pi*[0:cols-1]*(itr-1)/(cols-1);
end
for itr = 1:rows
   omegay(:,itr)=2*pi*[0:rows-1]'*(itr-1)/(rows-1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for itr = 1:N
    R = (rho*i(1)*p - rho*i(2)*q - rho*i(3))./sqrt(1 + p.^2 + q.^2);
    R = (R>=0).*R;  %set negative reflectance values to zero
    
    newp = conv2(p,s,'same')+1/(4*lambda)*(imageDub - R).*conv2(R,sp,'same');
    newq = conv2(q,s,'same')+1/(4*lambda)*(imageDub - R).*conv2(R,sq,'same');
    
    %enforce integrability
    p_freq=fft2(newp);
    q_freq=fft2(newq);
   
    c=(-j*omegax.*p_freq-j*omegay.*q_freq)./(omegax.*omegax+omegay.*omegay);
    c(1,:)=0;  %fix the divide by zero problem (DC coefficients)
    c(:,1)=0;
    p=ifft2(j*omegax*c);
    q=ifft2(j*omegay*c);
    
end

%get height map
z=ifft2(c);
