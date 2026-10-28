function [out]=  sinc ( x  )

 out =  sin(pi*x)./(x*pi); 
 out(find(x == 0 )) =1;
end