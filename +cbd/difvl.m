function lDifved = difvl(data, nPer)
%DIFVL Returns the acerage log-difference of a series
%
% lDiffed = DIFFL(data) returns the first difference of the data
%
% lDiffed = DIFFL(data, nPer) returns the nPer average difference of the data

% David Kelley, 2015


%% Check inputs
if istable(data)
    %validateattributes(data, {'table'}, {'column'});
    rNames = data.Properties.RowNames;
    vName = data.Properties.VariableNames;
    returnTab = true;
    data = data{:,:};
else
    %validateattributes(data, {'numeric'}, {'column'});
    returnTab = false;
end
nVar = size(data, 2);

if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
lDifved = 100 * (log(data) - cbd.lag(log(data), nPer)) ./ nPer;

if returnTab
    varNames = cellfun(@horzcat, repmat({['diffl' num2str(nPer)]}, 1, nVar), vName, 'UniformOutput', false);
    lDifved = array2table(lDifved, 'RowNames', rNames, 'VariableNames', varNames);
end

end