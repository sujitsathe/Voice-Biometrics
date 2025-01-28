% Specify a directory for saving files
outputDir = 'C:\Users\YourUsername\Documents\VoiceBiometrics'; % Update this to a writable location
if ~exist(outputDir, 'dir')
    mkdir(outputDir); % Create the directory if it doesn't exist
end

% File paths for saving registration and authentication voice samples
filePathReg = fullfile(outputDir, 'registered_voice.wav');
filePathAuth = fullfile(outputDir, 'auth_voice.wav');

% Step 1: Record Voice Sample for Registration
disp('Recording registration voice...');
recObj = audiorecorder(44100, 16, 1); % 44.1 kHz, 16-bit, mono
disp('Start speaking...');
recordblocking(recObj, 5); % Record for 5 seconds
disp('Recording stopped.');

% Save the audio file
regAudio = getaudiodata(recObj);
if exist(filePathReg, 'file')
    delete(filePathReg); % Delete the file if it already exists
end
audiowrite(filePathReg, regAudio, 44100);

disp(['Registration voice saved successfully at ', filePathReg]);

% Step 2: Extract Features (MFCC) for Registration
disp('Extracting features...');
registeredVoice = audioread(filePathReg);
mfccReg = computeMFCC(registeredVoice, 44100, 13); % Extract 13 MFCC features

% Save the features for future comparison
featuresFilePath = fullfile(outputDir, 'voice_features.mat');
save(featuresFilePath, 'mfccReg');
disp(['Features saved successfully at ', featuresFilePath]);
