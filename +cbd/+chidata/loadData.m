function [data, fname] = loadData(section, seriesID)
%LOADATA opens the data file for a given section in the chidataDir
%
% If no seriesID is passed to LOADDATA, then the function will return
% a table with the data of all of the series in the section.
% Otherwise, only the specified series's data are returned.
%
% INPUTS:
%   section     ~ char, the name of the section
%   seriesID    ~ char, the name of the series to load in the section
%
% OUPTUS:
%   data        ~ table, the data from the section/seriesID
%   fname       ~ char, the name of the file where data is stored
%
% WARNING: This function should NOT be called directly by the user
%
% David Kelley, 2015
% Santiago I. Sordo-Palacios, 2019

% Get the chidata directory
chidataDir = cbd.chidata.dir();

% Get the filename
fname = fullfile(chidataDir, [section '_data.csv']);

% Check if it exists
found = isequal(exist(fname, 'file'), 2);
assert(found, ...
    'chidata:loadData:notFound', ...
    'Data file "%s" could not be found', fname);

% Open the data file
dataIn = readtable(fname, ...
    'Delimiter', ',', ...
    'HeaderLines', 0, ...
    'ReadVariableNames', true, ...
    'ReadRowNames', true, ...
    'EndOfLine', '\n', ...
    'DatetimeType', 'text');

% Pass to cbd.private.cbdTable to ensure a cbd-style table
values = dataIn{:, :};
dates = cbd.private.mdatenum(dataIn.Properties.RowNames);
varNames = upper(dataIn.Properties.VariableNames);
data = cbd.private.cbdTable(values, dates, varNames, true);

% Return only one series if requested
if nargin == 2
    % Look for the series in the variable names
    seriesID = upper(seriesID);
    [hasSeries, loc] = ismember(seriesID, data.Properties.VariableNames);
    assert(hasSeries, ...
        'chidata:loadData:missingSeries', ...
        'Series "%s" not found in section "%s"', ...
        seriesID, section);
    
    % Index into the series of interest
    data = data(:, loc);
end % if-nargin

end % function-loadData