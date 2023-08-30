function drawGridCallback(thePlot,velocity,range,skip,lightLineToggle,c)
% thePlot is a handle to the figure with the plot
% velocity is between 0.01 and 1
% range is an integer greater than 0 that tells the plot range on both the x and y axis
% skip is an integer > .05*range that tells how often to draw grid lines
% lightLineToggle is 1 or 0 (1 means on)
% c is the speed of light

figure(thePlot);        %switch to the figure with the plot

velocity=velocity*c;    %fix the velocity so it's a fraction of c
beta=velocity/c;
gamma=(1-beta^2)^(-1/2);
p=beta*gamma;           %the distance from x to x' at x=gamma
a=0:range/10:range;     %horizontal dummy variably

x=p/gamma*a;            %x' axis
ct=gamma/p*a;           %ct' axis


plot(a,ct), hold on;    %plot ct1

%draw lines parallel to the x' and ct' axes
for i=skip:skip:range;
   %cti'(a)=gamma/p*a+b
   %x'(a)=p/gamma*a
   %cti' and x' should intersect at a=gamma, so solve for
   %  b using cti(gamma)==x(gamma)
   %then multiply by i to get the parallel line we want
	b=(p-gamma^2/p)*i;
   cti=ct+b;
   
   %set cti' to zero when it is below x'
	tmp=(cti>x).*cti;
   %find the first index of cti' that is above x'
   start=min(find(tmp));
   %set all elements of cti' that are below x' to x'
   %  (hide the elements of cti' that lie below x' on x')
   tmp(1:start-1)=x(1:start-1);
   %unfortunately this is not symbolic, and there will be a
   %  line at the wrong slope between the x' and cti' (it can
   %  be made too small to notice if you choose enough points
   %  in a).  Instead I calculate the exact intersection of x'
   %  and cti' and set a(start) to this value.  Then change
   %  cti'(start) to be the cti'(a).  Do this by solving
   %  cti'(a)=x'(a).  This is different than what was done
   %  before because we are finding the exact intersection now,
   %  instead of the index of a that is closest to the intersection.
	tmp(start)=b*p^2/(p^2-gamma^2);
   tmpa=a(start);
   a(start)=b/(p/gamma-gamma/p);
   %plot a vs cti' and then flip the coordinates to get
   %  lines parallel to x'
   plot(a,tmp,':');
   plot(tmp,a,':');
   %fix a(start) since I messed with it to get the lines straight
   a(start)=tmpa;
end;

%plot the light line
if(lightLineToggle)
   plot(a,a,'r');
end;

%plot x' and set the axes
plot(a,x),hold off;
axis([0 range 0 range]);