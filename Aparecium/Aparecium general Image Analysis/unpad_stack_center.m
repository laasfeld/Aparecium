function unp = unpad_stack_center(img, meta)
% Remove the exact padding recorded in meta (inverse of pad_stack_mean).
    r = (1+meta.padTop) : (meta.padTop+meta.origH);
    c = (1+meta.padLeft): (meta.padLeft+meta.origW);
    unp = img(r, c, :);
end
