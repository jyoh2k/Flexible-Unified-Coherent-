function ShowCCDF(axes, in, str )

  ccdf_in = in;
  if ( size(in,2) == 1)
      ccdf_in = reshape(in,1,size(in,1));
  end 

  [ccdf, paprLevels] = ecdf(ccdf_in);
  ccdf = 1 - ccdf; 

    plot(axes, paprLevels,ccdf *100, 'y', 'LineWidth', 2);
    xlabel(axes,[str '(dB)'], 'Color','white');
    ylabel(axes,'CCDF(%)', 'Color','white');
    grid(axes, 'on');
    default_color(axes);

end 
