function [F_sorted,CV] = compute_and_sort_cv(F)
% SORT_SPIKES_BY_CV Sort spike cell array based on CV of inter-spike intervals (ISI)
%
% INPUT:
%   F - Cell array, each cell contains spike positions (numeric vector)
%
% OUTPUT:
%   F_sorted - Cell array sorted in ascending order of CV (ISI-based)
%
% NOTE:
%   CV is computed as: std(diff(x)) / mean(diff(x))

    % Initialize CV array
    CV = nan(size(F));

    % Compute CV for each cell
    for i = 1:numel(F)
        x = F{i};
        x = x(:);                 % Ensure column vector
        x = x(~isnan(x));         % Remove NaN
        
        if numel(x) < 2
            CV(i) = inf;          % Put invalid ones at the end
        else
            isi = diff(x);
            
            if mean(isi) == 0
                CV(i) = inf;
            else
                CV(i) = std(isi) / mean(isi);
            end
        end
    end

    % Sort based on CV (ascending)
    [CV, idx] = sort(CV(:), 'ascend');

 

    % Reorder F
    F_sorted = reshape(F(idx), size(F));
end