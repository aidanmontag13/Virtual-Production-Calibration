function err = costFunction(x, InputRGBs, OutputRGBs)
    %reshape x into 3x3 matrix
    M = reshape(x, [3,3]);
    Pred = (InputRGBs * M');
    Pred = max(0, min(1, Pred));
    diff = Pred - OutputRGBs;
    %err = sum(diff(:).^2);
    err = mean(mean(abs(Pred - OutputRGBs)));
    
end