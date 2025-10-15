function [padded, meta] = pad_stack_mean(stack, targetH, targetW)
% Center-pad to [targetH x targetW] using per-channel mean values.
% Returns meta with the padding we applied so we can unpad later.
    if nargin < 3, targetW = 1248; end
    if nargin < 2, targetH = 1248; end

    [H, W, C] = size(stack);
    assert(H <= targetH && W <= targetW, 'Input is larger than target size.');

    padTop    = floor((targetH - H)/2);
    padBottom = targetH - H - padTop;
    padLeft   = floor((targetW - W)/2);
    padRight  = targetW - W - padLeft;

    % Per-channel mean over HxW
    means = squeeze(mean(mean(stack, 1, 'omitnan'), 2, 'omitnan')); % Cx1

    % Pre-fill with channel means
    padded = zeros(targetH, targetW, C, 'like', stack);
    for c = 1:C
        padded(:,:,c) = means(c);
    end

    % Place the original image in the center
    padded(1+padTop:padTop+H, 1+padLeft:padLeft+W, :) = stack;

    meta = struct('padTop',padTop,'padBottom',padBottom,'padLeft',padLeft,'padRight',padRight, ...
                  'origH',H,'origW',W,'targetH',targetH,'targetW',targetW);
end

