function stack = stack_from_images(pathStr, firstImageName, combination)
% Build a HxWx3 stack (or HxWxK if combination has K planes) from files next to firstImageName.
% Ordering follows your "combination" indices after sorting the focus values.
%
% pathStr         : folder containing the images
% firstImageName  : reference filename like "...Z0_...tif"
% combination     : e.g. [0 1 2] or [1 2 3]
%
% Returns:
%   stack : H x W x K (single), grayscale planes stacked along 3rd dim

    if nargin < 3
        combination = [0 1 2];
    end

    % We’ll match any Z number with 1–2 digits where the reference has Z#.
    % Find the 'Z' in the reference name:
    zIdx = strfind(firstImageName, 'Z');
    assert(~isempty(zIdx), 'First image name must contain a Z index.');
    zIdx = zIdx(1);

    % Build a regexp: prefix + 'Z(\d{1,2})' + suffix
    prefix = regexptranslate('escape', firstImageName(1:zIdx));
    % consume the numeric part after Z in the reference name (1–2 digits)
    suffixStart = zIdx + 1;
    while suffixStart <= numel(firstImageName) && isstrprop(firstImageName(suffixStart), 'digit')
        suffixStart = suffixStart + 1;
    end
    suffix = regexptranslate('escape', firstImageName(suffixStart:end));
    pat = [ '^' prefix '(\d{1,2})' suffix '$' ];

    % List all files in the directory
    d = dir(fullfile(pathStr, '*'));
    d = d(~[d.isdir]);                        % files only
    names = {d.name};

    % Filter by pattern and capture focus index
    rightNames = {};
    focusVals  = [];                           % +1 as in your python code
    for i = 1:numel(names)
        tok = regexp(names{i}, pat, 'tokens', 'once');
        if ~isempty(tok)
            znum = str2double(tok{1});
            if ~isnan(znum)
                rightNames{end+1} = names{i}; %#ok<AGROW>
                focusVals(end+1)  = znum + 1; %#ok<AGROW>
            end
        end
    end

    % Read images and keep the first channel (grayscale)
    imgs = cell(1, numel(rightNames));
    for i = 1:numel(rightNames)
        p = fullfile(pathStr, rightNames{i});
        I = imread(p);                         % HxW or HxWxC
        if ndims(I) == 3
            I = I(:,:,1);                      % take first channel like cv2[...,0]
        end
        imgs{i} = I;
    end
    assert(~isempty(imgs), 'No images matched the pattern near %s.', firstImageName);

    % Sort focus values; then pick planes using "combination" on sorted order
    [~, orderFocus] = sort(focusVals, 'ascend');           % argsort(focus)
    sortedIdx = orderFocus(combination + 1);               % +1 (MATLAB indexing)
    sortedIdx = sortedIdx(sortedIdx >= 1 & sortedIdx <= numel(imgs)); % guard
    if numel(sortedIdx) < numel(combination)
        warning('Missing some planes; using available subset.');
    end

    % Stack along 3rd dim
    stack = single(imgs{sortedIdx(1)});
    for k = 2:numel(sortedIdx)
        stack = cat(3, stack, single(imgs{sortedIdx(k)}));
    end
end
