function registration_phase
    % Define storage directory
    secureFolder = fullfile(getenv('USERPROFILE'), 'Documents', 'VoiceSecurity');
    if ~exist(secureFolder, 'dir')
        mkdir(secureFolder);
    end
    featuresFilePath = fullfile(secureFolder, 'voice_features.mat');

    % Number of recordings to average
    numSamples = 3;
    allMFCCs = [];
    allPitch = [];
    allFormants = [];

    % Record multiple samples
    for i = 1:numSamples
        disp(['Speak for registration (Sample ', num2str(i), ' of ', num2str(numSamples), ')']);
        recObj = audiorecorder(44100, 16, 1);
        recordblocking(recObj, 5);
        audioData = getaudiodata(recObj);

        % Ensure valid audio
        if isempty(audioData) || all(audioData == 0) || rms(audioData) < 0.005
            disp('No valid audio detected. Please try again.');
            return;
        end

        % Normalize audio
        audioData = audioData / max(abs(audioData));

        % Extract MFCC
        mfccSample = computeMFCC(audioData, 44100, 13);
        allMFCCs = cat(3, allMFCCs, mfccSample);

        % Extract speaker-specific features (pitch and formants)
        pitchSample = mean(extractPitch(audioData, 44100));
        formantSample = mean(extractFormants(audioData, 44100));
        allPitch = [allPitch, pitchSample];
        allFormants = [allFormants, formantSample];
    end

    % Compute mean & variance of MFCCs, pitch, and formants
    biometricSignature = mean(allMFCCs, 3);
    biometricVariance = var(allMFCCs, 0, 3);
    avgPitch = mean(allPitch);
    avgFormants = mean(allFormants);

    % Save features
    save(featuresFilePath, 'biometricSignature', 'biometricVariance', 'avgPitch', 'avgFormants');
    disp(['Biometric signature saved successfully at: ', featuresFilePath]);
end
