function [papr, ccdf, paprLevels] =  calculate_PAPR( in )
  papr_in = in;
  if ( size(in,2) == 1)
      papr_in = reshape(in,1,size(in,1));
  end 

  papr = (abs(papr_in).^2) / mean(abs(papr_in).^2, 2);

  [ccdf, paprLevels] = ecdf(papr);
  ccdf = 1 - ccdf; 

end
