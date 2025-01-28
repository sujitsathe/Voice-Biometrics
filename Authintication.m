% Step 3: Record Voice Sample for Authentication
disp('Speak to unlock the folder...');
recordblocking(recObj, 5); % Record new voice sample
authAudio = getaudiodata(recObj);
if exist(filePathAuth, 'file')
    delete(filePathAuth); % Delete the file if it already exists
end
audiowrite(filePathAuth, authAudio, 44100);

% Step 4: Extract Features (MFCC) for Authentication
authVoice = audioread(filePathAuth);
mfccAuth = computeMFCC(authVoice, 44100, 13); % Extract 13 MFCC features

% Step 5: Compare Features and Authenticate
distance = norm(mean(mfccReg, 1) - mean(mfccAuth, 1)); % Compare mean MFCC vectors

% Threshold for Authentication
threshold = 10; % Adjust based on testing
disp(['Distance: ', num2str(distance)]);
if distance < threshold
    disp('Authentication successful! Folder unlocked.');
    
    % Unhide the folder (make sure the folder exists)
    [status, cmdout] = system('attrib -h -s "C:\New folder"');
    disp(['Status: ', num2str(status)]);
    disp(['Command Output: ', cmdout]);
    
    % Open the folder in Explorer
    system('explorer "C:\SecureFolder"');

else
    disp('Authentication failed! Folder remains locked.');
end
