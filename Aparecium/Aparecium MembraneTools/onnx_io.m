function io = onnx_io(modelPath)
    % List ONNX input/output names and shapes via Python onnxruntime
    ort = py.importlib.import_module('onnxruntime');
    so  = py.onnxruntime.SessionOptions();
    sess = ort.InferenceSession(modelPath, so, pyargs('providers', py.list({'CPUExecutionProvider'})));

    ins = cell(sess.get_inputs());
    outs = cell(sess.get_outputs());

    io.inputs  = arrayfun(@(k) nodearg_to_struct(ins{k}), 1:numel(ins), 'uni', true);
    io.outputs = arrayfun(@(k) nodearg_to_struct(outs{k}), 1:numel(outs), 'uni', true);
end

function s = nodearg_to_struct(na)
    % na: py.onnxruntime.capi.onnxruntime_pybind11_state.NodeArg
    % name
    s.name = char(na.name);

    % shape may be None, ints, or symbolic strings
    dims = {};
    shp = na.shape;                   % Python sequence or None
    if ~strcmp(class(shp),'py.NoneType')
        items = cell(shp);            % convert Python seq -> MATLAB cell
        dims = cell(1, numel(items));
        for i = 1:numel(items)
            d = items{i};
            if strcmp(class(d), 'py.NoneType')
                dims{i} = NaN;        % unknown dimension
            else
                try
                    dims{i} = double(d);      % numeric dim
                catch
                    dims{i} = char(py.str(d));% symbolic (e.g., 'batch')
                end
            end
        end
    end
    s.shape = dims;  % cell array: numbers, NaN, or strings
end