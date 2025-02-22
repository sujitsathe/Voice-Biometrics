function dist = dynamicTimeWarping(seq1, seq2)
    % Computes the Dynamic Time Warping distance between two feature sequences.
    len1 = size(seq1, 2);
    len2 = size(seq2, 2);
    DTW = inf(len1+1, len2+1);
    DTW(1, 1) = 0;

    for i = 1:len1
        for j = 1:len2
            cost = norm(seq1(:, i) - seq2(:, j)); % Euclidean distance
            DTW(i+1, j+1) = cost + min([DTW(i, j+1), DTW(i+1, j), DTW(i, j)]);
        end
    end

    dist = DTW(len1+1, len2+1);
end
