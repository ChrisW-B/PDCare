% Compute the freezing index
% SR: Sample rate in hertz
% Original version allowed various FFT sizes - now FFT and window size must
% be equal

% modified from original to accept fft instead of accelerometer data

function res = givenFFT_x_fi(fftArray,SR,stepSize)  
    NFFT = 256;
    locoBand=[0.5 3];
    freezeBand=[3 8];
        
    f_res = SR / NFFT;
    f_nr_LBs  = round(locoBand(1)   / f_res);
    f_nr_LBs( f_nr_LBs==0 ) = [];
    f_nr_LBe  = round(locoBand(2)   / f_res);
    f_nr_FBs  = round(freezeBand(1) / f_res);
    f_nr_FBe  = round(freezeBand(2) / f_res);

    d = NFFT/2;

    % Iterate through fft arrays
    for i=1:size(fftArray)(1)
        Y = fftArray(i,:); %pulls out current array
        Pyy = Y.* conj(Y) / NFFT; %get the complex conjugate of the data

         % --- calculate sumLocoFreeze and freezeIndex ---
        areaLocoBand   = x_numericalIntegration( Pyy(f_nr_LBs:f_nr_LBe), SR );
        areaFreezeBand = x_numericalIntegration( Pyy(f_nr_FBs:f_nr_FBe),  SR );

        sumLocoFreeze(i) = areaFreezeBand + areaLocoBand;
        
        if areaLocoBand ~= 0 % avoid divide by 0 errors
            freezeIndex(i) = areaFreezeBand/areaLocoBand;
        else 
            freezeIndex(i) = 0;
        end

        i = i + 1;
    end
res.sum = sumLocoFreeze;
res.quot = freezeIndex;
end
