function pitch = extractPitch(audio, fs)
    % Compute pitch using autocorrelation
    window = hamming(length(audio));
    audio = audio .* window;
    corr = xcorr(audio);
    [~, peak] = max(corr(length(audio):end));
    pitch = fs / peak;
end
