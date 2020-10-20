function [Y, newglimfile, missing, datadir] = read_data(data)
% READ_DATA Read CIVET surface-based data from a user-defined directory and load files matching glimfile.

% Select data directory with CIVET output text files for all subjects
datadir = uigetdir(pwd, 'Select data directory');
files  = dir(fullfile(datadir, '*_*mm*.txt'));

% Find unique smoothing kernels
mms = regexp({files.name}', '\d*mm', 'match', 'once');
mms = unique(mms);

missing = {};
newglimfile = data.glimfile;

% Load files and smooth
for k = 1:size(mms,1)
    mm = mms{k};
    filesleft = {};
    filesright = {};
    for m = 1:size(data.glimfile.(data.id_variable),1)
        subjID = data.glimfile.(data.id_variable){m};
        switch data.measure
            case 'cortical thickness' % S01_native_rms_rsl_tlaplace_0mm_left.txt
                left = dir(fullfile(datadir, ['*' subjID '*_' mm '*left*.txt']));
                right = dir(fullfile(datadir, ['*' subjID '*_' mm '*right*.txt']));
            case 'surface area' % S01_mid_surface_rsl_left_native_area_0mm.txt
                left = dir(fullfile(datadir, ['*' subjID '*left*_' mm '*.txt']));
                right = dir(fullfile(datadir, ['*' subjID '*right*_' mm '*.txt']));
            case 'volume' % S01_surface_rsl_left_native_volume_0mm.txt
                left = dir(fullfile(datadir, ['*' subjID '*left*_' mm '*txt']));
                right = dir(fullfile(datadir, ['*' subjID '*right*_' mm '*.txt']));
            case 'curvature' % S01_native_mc_rsl_0mm_gray_left.txt, S01_native_mc_rsl_0mm_mid_left.txt, S01_native_mc_rsl_0mm_white_left.txt
                left = dir(fullfile(datadir, ['*' subjID '*_' mm '*gray*left*.txt']));
                right = dir(fullfile(datadir, ['*' subjID '*_' mm '*gray*right*.txt']));
            %case 'qT1' % TO DO
            %    left = dir(fullfile(datadir, ['*' subjID '*_' mm '*left*.txt']));
            %    right = dir(fullfile(datadir, ['*' subjID '*_' mm '*right*.txt']));
            %case 'contrast' % TO DO
            %    left = dir(fullfile(datadir, ['*' subjID '*_' mm '*left*.txt']));
            %    right = dir(fullfile(datadir, ['*' subjID '*_' mm '*right*.txt']));
        end

        if isempty(left) || isempty(right)
            disp([mm ' files for ' subjID ' not found! Excluding subject...'])
            if ~ismember(subjID, missing)
                missing = [missing; subjID];
            end
        else
            filesleft = [filesleft; fullfile(datadir, left.name)];
            filesright = [filesright; fullfile(datadir, right.name)];
        end
    end
    Y.(['smooth' mm]) = SurfStatReadData([filesleft filesright]);
end

% Remove missing subjects from glimfile
if ~isempty(missing)
    for i = 1:size(missing,1)
        row = find(strcmp(data.glimfile.(data.id_variable),missing{i}));
        newglimfile(row,:) = []; %#ok<FNDSB>
    end
end