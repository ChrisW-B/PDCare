% Compute the freezing index
% SR: Sample rate in hertz
% Original version allowed various FFT sizes - now FFT and window size must
% be equal

function res = givenFFT_x_fi(fftArray,SR,stepSize)  
    NFFT = 256;
    locoBand=[0.5 3];
    freezeBand=[3 8];
    windowLength=256;
        
    f_res = SR / NFFT;
    f_nr_LBs  = round(locoBand(1)   / f_res);
    f_nr_LBs( f_nr_LBs==0 ) = [];
    f_nr_LBe  = round(locoBand(2)   / f_res);
    f_nr_FBs  = round(freezeBand(1) / f_res);
    f_nr_FBe  = round(freezeBand(2) / f_res);

    d = NFFT/2;

    % f_nr_LBs
    % f_nr_LBe
    % f_nr_FBs
    % f_nr_FBe

    % Online implementation
    % jPos is the current position, 0-based, we take a window 
    % jPos = windowLength+1;      % This should not be +1 but we follow Baechlin's implementation.
    i=1;
    % Iterate the FFT windows
    time(1) = 1;
    for i=1:size(fftArray)(1)
        time(i) = i;
        Y = fftArray(i,:);
        Pyy = Y.* conj(Y) / NFFT;
        
         % --- calculate sumLocoFreeze and freezeIndex ---
        
        areaLocoBand   = x_numericalIntegration( Pyy(f_nr_LBs:f_nr_LBe), SR );
        areaFreezeBand = x_numericalIntegration( Pyy(f_nr_FBs:f_nr_FBe),  SR );

        sumLocoFreeze(i) = areaFreezeBand + areaLocoBand;
        
        if areaLocoBand ~= 0
            freezeIndex(i) = areaFreezeBand/areaLocoBand;
        else 
            freezeIndex(i) = 0;
        end
         % --------------------
        
        
        % next window
        % jPos = jPos + stepSize;
        i = i + 1;
        %break;
    end
res.sum = sumLocoFreeze;
res.quot = freezeIndex;
res.time = time;
end
