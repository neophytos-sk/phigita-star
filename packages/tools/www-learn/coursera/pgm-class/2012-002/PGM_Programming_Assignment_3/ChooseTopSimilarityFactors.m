function factors = ChooseTopSimilarityFactors (allFactors, F)
% This function chooses the similarity factors with the highest similarity
% out of all the possibilities.
%
% Input:
%   allFactors: An array of all the similarity factors.
%   F: The number of factors to select.
%
% Output:
%   factors: The F factors out of allFactors for which the similarity score
%     is highest.
%
% Hint: Recall that the similarity score for two images will be in every
%   factor table entry (for those two images' factor) where they are
%   assigned the same character value.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

% If there are fewer than F factors total, just return all of them.
if (length(allFactors) <= F)
    factors = allFactors;
    return;
end

% Your code here:

n=length(allFactors);
temp = zeros(n,2);
for i = 1:n
  [sim idx] = max(allFactors(i).val);
  temp(i,1) = -sim;
  temp(i,2) = i;
end

sorted = sortrows(temp,1);

factors = allFactors(sorted(1:F,2));

end

