% File: cosineSimilarity.m
function similarity = cosineSimilarity(A, B)
    similarity = dot(A, B) / (norm(A) * norm(B)); % Cosine similarity formula
end
