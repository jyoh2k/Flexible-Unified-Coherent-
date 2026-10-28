function out = upsample(in, oversample)

    out = zeros(size(in,1), size(in,2)*oversample);
    out(1:oversample:end) = in;

end