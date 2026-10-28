
function xout = fft_fixed(x_in, params) 
    n = length(x_in);  t = log2(n);
    w = fi_radix2twiddles(n);
    x = complex(zeros(t+1, length(x_in))); 
    x(1,:) = bitrevorder(x_in); 
    
    
    if ( t == 6)
        xout = fft64_fixed(x_in, params);
    else
        if ( t == 5 )
            xout = fft32_fixed(x_in, params);
        else
            for q=1:t 
                L = 2^q; r = n/L; L2 = L/2; 
                x(q+1,:) = fft_stage( x(q,:) ,  w, L, r, L2);
            end 
            xout= x(t+1,:);  
        end
    end 

end 


function xout = fft64_fixed(x_in, params)

    n = length(x_in);  t = log2(n);
    x0 = bitrevorder(x_in);  
    w = fi_radix2twiddles(n);
    
    x1 = complex(zeros(1, length(x_in))); 
    x2 = complex(zeros(1, length(x_in))); 
    x3 = complex(zeros(1, length(x_in))); 
    x4 = complex(zeros(1, length(x_in))); 
    x5 = complex(zeros(1, length(x_in))); 
    x6 = complex(zeros(1, length(x_in))); 
    
    w  = fie_c(w, params.T.FFTW);
    x0  = fie_c(x0, params.T.In);
    q=1;L = 2^q; r = n/L; L2 = L/2; 
    x1 = fft_stage(x0,  w, L, r, L2, params.T.FFTM1, params.T.FFTX1);
    q=2;L = 2^q; r = n/L; L2 = L/2; 
    x2 = fft_stage(x1, w, L,  r, L2, params.T.FFTM2, params.T.FFTX2);
    q=3;L = 2^q; r = n/L; L2 = L/2; 
    x3 = fft_stage(x2, w, L,  r, L2, params.T.FFTM3, params.T.FFTX3);
    q=4;L = 2^q; r = n/L; L2 = L/2; 
    x4 = fft_stage(x3, w, L,  r, L2, params.T.FFTM4, params.T.FFTX4);
    q=5;L = 2^q; r = n/L; L2 = L/2; 
    x5 = fft_stage(x4, w, L,  r, L2, params.T.FFTM5, params.T.FFTX5);
    q=6;L = 2^q; r = n/L; L2 = L/2; 
    x6 = fft_stage(x5, w, L,  r, L2, params.T.FFTM6, params.T.FFTX6); 
   
   xout= x6;  
   xout = fie_c(xout, params.T.FFTXO);
   
  
    if ( params.fixed_bit == 2 ) 
    end 
    
end


function xout = fft32_fixed(x_in, params)

    n = length(x_in);  t = log2(n);
    x0 = bitrevorder(x_in);  
    w = fi_radix2twiddles(n);
    
    x1 = complex(zeros(1, length(x_in))); 
    x2 = complex(zeros(1, length(x_in))); 
    x3 = complex(zeros(1, length(x_in))); 
    x4 = complex(zeros(1, length(x_in))); 
    x5 = complex(zeros(1, length(x_in)));  
    
    w  = fie_c(w, params.T.FFTW);
    x0  = fie_c(x0, params.T.In);
    q=1;L = 2^q; r = n/L; L2 = L/2; 
    x1 = fft_stage(x0,  w, L, r, L2, params.T.FFTM1, params.T.FFTX1);
    q=2;L = 2^q; r = n/L; L2 = L/2; 
    x2 = fft_stage(x1, w, L,  r, L2, params.T.FFTM2, params.T.FFTX2);
    q=3;L = 2^q; r = n/L; L2 = L/2; 
    x3 = fft_stage(x2, w, L,  r, L2, params.T.FFTM3, params.T.FFTX3);
    q=4;L = 2^q; r = n/L; L2 = L/2; 
    x4 = fft_stage(x3, w, L,  r, L2, params.T.FFTM4, params.T.FFTX4);
    q=5;L = 2^q; r = n/L; L2 = L/2; 
    x5 = fft_stage(x4, w, L,  r, L2, params.T.FFTM5, params.T.FFTX5); 
   
   xout= x5;  
   xout = fie_c(xout, params.T.FFTXO);
   
  
    if ( params.fixed_bit == 2 ) 
    end 
    
end

function xout = fft_stage(xin, win, L,  r, L2, FFTMulbit, FFTOutbit)
    temp = complex(zeros(r, L2));
    x    = complex(zeros(size(xin)));
    for k=0:(r-1)
        for j=0:(L2-1)
            temp(k+1,j+1) = (win(L2-1+j+1) * xin(k*L+j+L2+1));
            temp(k+1,j+1)   = fie_c(  temp(k+1,j+1), FFTMulbit);
            x(k*L+j+L2+1) = xin(k*L+j+1)  - temp(k+1,j+1) ;
            x(k*L+j+1)    = xin(k*L+j+1)  + temp(k+1,j+1) ;
        end
    end
    xout   = x;
    xout   = fie_c( xout, FFTOutbit);
end



function w = fi_radix2twiddles(n)
    t = log2(n);
    if floor(t) ~= t
      error('N must be an exact power of two.');
    end
    wr = zeros(n-1,1);
    wi = zeros(n-1,1);
    k=1;
    L=2;
    % Equation 1.4.11, p. 34
    while L<=n
      theta = 2*pi/L;
      % Algorithm 1.4.1, p. 23
      for j=0:(L/2 - 1)
        wr(k) = cos(j*theta);
        wi(k) = -sin(j*theta) ;
        k = k + 1;
      end
      L = L*2;
    end

    w = complex( wr, wi );
end


% function xout = fft64_fixed(x_in, params)
%     n = length(x_in);  t = log2(n);
%     w = fi_radix2twiddles(n);
%     x1 = complex(zeros(t+1, length(x_in))); 
%     x2 = complex(zeros(t+1, length(x_in))); 
%     x3 = complex(zeros(t+1, length(x_in))); 
%     x4 = complex(zeros(t+1, length(x_in))); 
%     x5 = complex(zeros(t+1, length(x_in))); 
%     x6 = complex(zeros(t+1, length(x_in))); 
%     x7 = complex(zeros(t+1, length(x_in))); 
%     
%     x0 = bitrevorder(x_in); 
%     
%    
%     q=1;L = 2^q; r = n/L; L2 = L/2; 
%     x1 = fft_stage(x0,  w, L, r, L2);
%     q=2;L = 2^q; r = n/L; L2 = L/2; 
%     x2 = fft_stage(x1, w, L,  r, L2);
%     q=3;L = 2^q; r = n/L; L2 = L/2; 
%     x3 = fft_stage(x2, w, L,  r, L2);
%     q=4;L = 2^q; r = n/L; L2 = L/2; 
%     x4 = fft_stage(x3, w, L,  r, L2);
%     q=5;L = 2^q; r = n/L; L2 = L/2; 
%     x5 = fft_stage(x4, w, L,  r, L2);
%     q=6;L = 2^q; r = n/L; L2 = L/2; 
%     x6 = fft_stage(x5, w, L,  r, L2); 
%     
%     xout = x6;
% 
% end 

% function xout = fft_fixed(x_in, params)
%     n = length(x_in);  t = log2(n);
%     w = fi_radix2twiddles(n);
%     x = complex(zeros(t+1, length(x_in))); 
%     x(1,:) = bitrevorder(x_in); 
%     
%     for q=1:t 
%         L = 2^q; r = n/L; L2 = L/2; 
%         x(q+1,:) = fft_stage( x(q,:) ,  w, L, r, L2);
%     end 
%     xout= x(t+1,:);    
% 
% end 
