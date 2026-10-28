function out = filtfilt(b,a,in)
    filterforward = filter(b,a,in);
    filterbackward = filter(b, a, filterforward(end:-1:1));
    out = filterbackward(end:-1:1);
end