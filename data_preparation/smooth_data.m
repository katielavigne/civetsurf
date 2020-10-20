function Y = smooth_data(Y, avsurf, mask, k)
% SMOOTH_DATA Smooth CIVET surface-based data with user-defined kernel and perform memory mapping if required.

if ~isnumeric(k)
    warning('Smoothing kernel not defined! Smoothing skipped!')
else
    kmm = num2str(k*2);
    if ~isfield(Y, ['smooth' kmm 'mm'])
        if isfield(Y, 'smooth0mm')
            Y.(['smooth' kmm 'mm']) = SurfStatSmooth(Y.smooth0mm, avsurf, k);
                if length(class(Y.(['smooth' kmm 'mm']))) == 10
                    Y.(['smooth' kmm 'mm']) = Y.(['smooth' kmm 'mm']).Data(1).Data(1:size(mask,2),:)'; % memory mapping
                end
        else
            warning('Non-smoothed data (0mm files) not found! Smoothing skipped!')
        end
    end
end