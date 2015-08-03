function out = multiseriesFunction(dataA, dataB, fnHandle, varargin)
%MULTISERIESFUNCTION is a helper function for computing the binary
%operators on cbd data objects or scalars. 
%
% out = MULTISERIESFUNCTION(dataA, dataB, fnHandle) computes the function
% in fnHandle on the two data series dataA and dataB (either tables or
% scalars). 
%
% The 4 cases of the types of the first two inputs are handled separately.
% If a table is entered for either, a table is returned. If both inputs are
% scalars, a sclar is returned. 

% David Kelley, 2015

%% Validate attributes
if istable(dataA)
    validateattributes(dataA, {'table'}, {'column'});
else
    validateattributes(dataA, {'numeric'}, {'scalar'});
end
if istable(dataB)
    validateattributes(dataB, {'table'}, {'column'});
else
    validateattributes(dataB, {'numeric'}, {'scalar'});
end
validateattributes(fnHandle, {'function_handle'}, {'scalar'});

inP = inputParser;
inP.addParameter('ignoreNan', false, @islogical);
inP.parse(varargin{:});
opts = inP.Results;

%% Compute operation
if istable(dataA) && istable(dataB)
    data = cbd.merge(dataA, dataB);
    if opts.ignoreNan
        data = cbd.nan2zero(data);
    end
    fnResult = fnHandle(data{:, 1}, data{:, 2});
    out = array2table(fnResult, 'RowNames', data.Properties.RowNames, ...
        'VariableNames', {'dataseries'});

elseif istable(dataA) && ~istable(dataB)
    fnResult = fnHandle(dataA{:, 1}, dataB);
    out = array2table(fnResult, 'RowNames', dataA.Properties.RowNames, ...
        'VariableNames', {'dataseries'});

elseif ~istable(dataA) && istable(dataB)
    fnResult = fnHandle(dataA, dataB{:, 1});
    out = array2table(fnResult, 'RowNames', dataB.Properties.RowNames, ...
        'VariableNames', {'dataseries'});

else % Both scalars
    out = fnHandle(dataA, dataB);
end