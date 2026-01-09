function outStruct = onnx_predict_python(sess, inStruct, varargin)
%ONNX_PREDICT_PYTHON  Run ONNX model inference from MATLAB via Python onnxruntime
%
%   out = onnx_predict_python(modelPath, inputs)
%   out = onnx_predict_python(modelPath, inputs, "UseGPU", true)
%
%   modelPath : string, path to .onnx file
%   inputs    : struct or containers.Map of input_name -> MATLAB array
%
%   Optional name-value:
%       "UseGPU" : logical (default false)
%
%   Example:
%       img = im2single(imresize(imread("cat.jpg"), [1248 1248]));
%       x = permute(img, [4 1 2 3]);  % make 1xH xW x3 (NHWC)
%       result = onnx_predict_python("model.onnx", struct('x', x));

% create sess with     
%    so = py.onnxruntime.SessionOptions();
%    sess = ort.InferenceSession(modelPath, so, pyargs('providers', providers));


    % Parse options
    p = inputParser;
    addParameter(p, "UseGPU", false, @(x)islogical(x)||isnumeric(x));
    parse(p, varargin{:});
    useGPU = logical(p.Results.UseGPU);

    % Import Python modules
    ort = py.importlib.import_module('onnxruntime');
    np  = py.importlib.import_module('numpy');

    % Choose provider
    if useGPU
        providers = py.list({'CUDAExecutionProvider','CPUExecutionProvider'});
    else
        providers = py.list({'CPUExecutionProvider'});
    end

    % Build Python feed dict
    if isa(inStruct,'containers.Map')
        keys = inStruct.keys;
    else
        keys = fieldnames(inStruct);
    end

    feed = py.dict;
    for i = 1:numel(keys)
        key = keys{i};
        if isa(inStruct,'containers.Map')
            val = inStruct(key);
        else
            val = inStruct.(key);
        end

        % Convert MATLAB array → NumPy array
        npArr = np.ascontiguousarray(np.asarray(val, pyargs('dtype', np.float32)));
        feed{string(key)} = npArr;
    end

    % Run inference
    pyOut = sess.run(py.None, feed);

    % Collect output names
    outs = cell(sess.get_outputs());
    outNames = cellfun(@(x) char(x.name), outs, 'UniformOutput', false);

    % Convert NumPy arrays → MATLAB doubles (reshape accordingly)
    outStruct = struct();
    for i = 1:numel(outNames)
        npArr = pyOut{i};
        data = double(py.array.array('d', py.numpy.nditer(npArr)));
        shape = cellfun(@double, cell(npArr.shape));
        %outStruct.(outNames{i}) = reshape(data, shape);
        %r = squeeze(permute(reshape(data, shape([1,4,2,3])), [4,2,3,1]));
        squeezed_im = squeeze(permute(reshape(data, shape([1,4,2,3])), [2,3,4,1]));
        % add back a dimension for prediction channel if it was squeezed.
        if isequal(numel(size(squeezed_im)), 2)
            res = zeros([1, size(squeezed_im, 1), size(squeezed_im, 2)]);
            res(1, :, :) = squeezed_im;
        else
            res = squeezed_im;
        end
        outStruct.(outNames{i}) = res;
        %outStruct.(outNames{i}) = squeeze(permute(reshape(data, shape([1,4,2,3])), [4,2,3,1]));
    end
end
