function authentication_phase
    % Define the secure directory
    secureFolder = fullfile(getenv('USERPROFILE'), 'Documents', 'VoiceSecurity');
    featuresFilePath = fullfile(secureFolder, 'voice_features.mat');

    % Check if the biometric signature exists
    if ~exist(featuresFilePath, 'file')
        error('Biometric signature not found! Please complete registration first.');
    end

    % Load stored biometric data
    load(featuresFilePath, 'biometricSignature', 'biometricVariance', 'avgPitch', 'avgFormants');

    % Record new audio for authentication
    disp('Speak to unlock the folder...');
    recObj = audiorecorder(44100, 16, 1);
    recordblocking(recObj, 5);
    audioData = getaudiodata(recObj);

    % Ensure valid audio
    if isempty(audioData) || all(audioData == 0) || rms(audioData) < 0.005
        disp('No valid audio detected. Access denied.');
        return;
    end

    % Normalize audio before extracting MFCC
    audioData = audioData / max(abs(audioData));

    % Extract MFCC for authentication
    authSignature = computeMFCC(audioData, 44100, 13);

    % Extract speaker-specific features
    authPitch = mean(extractPitch(audioData, 44100));
    authFormants = mean(extractFormants(audioData, 44100));

    % Compute **DTW distance** for MFCC comparison
    dtwDistance = dynamicTimeWarping(biometricSignature, authSignature);

    % Compute **Pitch Similarity** (Euclidean Distance)
    pitchDiff = abs(avgPitch - authPitch);

    % Compute **Formant Similarity** (Euclidean Distance)
    formantDiff = abs(avgFormants - authFormants);

    % Compute **Strict Dynamic Threshold**
    dynamicThreshold = mean(dtwDistance) + std(biometricVariance(:)) * 0.75; % Tighter matching

    % Set pitch & formant strictness thresholds
    pitchThreshold = 30;  % Adjust based on speaker variability
    formantThreshold = 150;  % Adjust based on test cases

    disp(['Computed DTW Distance: ', num2str(dtwDistance)]);
    disp(['Dynamic Threshold: ', num2str(dynamicThreshold)]);
    disp(['Pitch Difference: ', num2str(pitchDiff), ' (Threshold: ', num2str(pitchThreshold), ')']);
    disp(['Formant Difference: ', num2str(formantDiff), ' (Threshold: ', num2str(formantThreshold), ')']);

    % Final Decision: All conditions must be met
    if (dtwDistance < dynamicThreshold) && (pitchDiff < pitchThreshold) && (formantDiff < formantThreshold)
        disp('Authentication successful! Folder unlocked.');
        system('explorer "C:\Path\To\Secure\Folder"'); % Update path
    else
        disp('Authentication failed! Folder remains locked.');
    end
end
