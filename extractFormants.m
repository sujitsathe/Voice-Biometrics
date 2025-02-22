function formants = extractFormants(audio, fs)
    % Compute LPC coefficients
    numCoeffs = 12;
    lpcCoeffs = lpc(audio, numCoeffs);
    rootsVals = roots(lpcCoeffs);
    formants = sort(fs / (2 * pi) * angle(rootsVals(imag(rootsVals) > 0)));
end
