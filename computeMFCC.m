function mfccFeatures = computeMFCC(audio, fs, numCoeffs)
    % Parameters
    frameSize = 0.025; % 25 ms frame
    frameStep = 0.01;  % 10 ms step
    numFilters = 26;   % Number of Mel filters
    
    % Pre-emphasis
    preEmphasis = 0.97;
    audio = filter([1 -preEmphasis], 1, audio);
    
    % Framing
    frameLength = round(frameSize * fs);
    frameStep = round(frameStep * fs);
    signalLength = length(audio);
    numFrames = max(1, floor((signalLength - frameLength) / frameStep) + 1);
    
    % Ensure proper padding of the audio signal
    padLength = max(0, (numFrames - 1) * frameStep + frameLength - signalLength);
    audio = [audio; zeros(padLength, 1)];
    
    % Create frames
    frames = zeros(numFrames, frameLength);
    for i = 1:numFrames
        startIdx = (i - 1) * frameStep + 1;
        frames(i, :) = audio(startIdx:startIdx + frameLength - 1);
    end
    
    % Hamming Window
    hammingWin = hamming(frameLength);
    hammingWin = hammingWin(:)'; % Ensure it's a row vector
    frames = frames .* repmat(hammingWin, numFrames, 1); % Apply windowing
    
    % FFT and Power Spectrum
    NFFT = 512;
    magFrames = abs(fft(frames, NFFT, 2)); % Perform FFT along the 2nd dimension
    powFrames = (1 / NFFT) * (magFrames .^ 2);
    
    % Mel Filter Bank
    melFilters = melFilterBank(numFilters, NFFT, fs);
    melPower = powFrames(:, 1:NFFT/2+1) * melFilters';
    
    % Logarithmic Spectrum
    logMelPower = log(melPower + eps);
    
    % Discrete Cosine Transform (DCT)
    mfccFeatures = dct(logMelPower')';  % Apply DCT along each frame (columns)
    mfccFeatures = mfccFeatures(:, 1:numCoeffs); % Keep only the first numCoeffs
end

function melFilters = melFilterBank(numFilters, NFFT, fs)
    % Convert frequencies to Mel scale
    melLow = 0;
    melHigh = 2595 * log10(1 + (fs / 2) / 700);
    melPoints = linspace(melLow, melHigh, numFilters + 2);
    hzPoints = 700 * (10.^(melPoints / 2595) - 1);
    binPoints = round((NFFT + 1) * hzPoints / fs); % Ensure indices are integers
    
    % Ensure binPoints are within valid range
    binPoints(binPoints < 1) = 1; % Clamp to minimum index of 1
    binPoints(binPoints > NFFT/2+1) = NFFT/2+1; % Clamp to maximum index
    
    % Create filters
    melFilters = zeros(numFilters, NFFT / 2 + 1);
    for i = 2:numFilters + 1
        % Ascending slope
        for j = binPoints(i-1):binPoints(i)
            melFilters(i-1, j) = (j - binPoints(i-1)) / (binPoints(i) - binPoints(i-1));
        end
        % Descending slope
        for j = binPoints(i):binPoints(i+1)
            melFilters(i-1, j) = (binPoints(i+1) - j) / (binPoints(i+1) - binPoints(i));
        end
    end
end
