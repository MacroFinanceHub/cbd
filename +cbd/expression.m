function [data, dataProp] = expression(series, varargin)
%EXPRESSION Get data series from Haver, FRED, or CHIDATA databases
%
% dataTable = cbd.expression(seriesID) returns the same as cbd.data
%
% dataTable = cbd.expression(seriesID, seriesB, ...) pulls the series in
% seriesID as cbd.data does except that whenever a '%d' sign is
% encountered, seriesB is inserted instead of a database retrieval. Any
% name-value pair options should be specified after additional series
% inputs. 
%
% Example: 
%   gdph = cbd.data('GDPH');
%   diffGDPH = cbd.expression('DIFA%(%d)', gdph);
%
% [dataTable, dataInfo] = cbd.expression(...) also returns a cell array
% containing information on the series pulled.
%
% cbd.data also takes a number of optional arguments (name-value pairs):
%   dbID      - Database name used for unlabeled series (default USECON).
%               Can be any of the Haver database names, FRED, or CHIDATA.
%   startDate - Date string or datenum of first date to get data 
%               e.g., '01/01/2015' (default fetches whole series)
%   endDate   - Date string or datenum of last date to get data
%   aggFreq   - Specify a freqency for the data to be output at. If not
%               specified, data is returned using the highest frequency of
%               any data pulled. Lower frequency data appears as NaN except
%               for the last higher-frequency period.
%   ignoreNan - Ignore NaN values in elementry math operations. Treats NaN
%               values as 0 in addition and subtraction and 1 in 
%               multiplication and division.
%   asOf      - For FRED data, specify to pull the data as if at some date
%               in the past (using ALFRED). 
%   asOfStart - For FRED data, get all of the vintages between the
%               asOfStart date and the asOfEnd date (requires asOfEnd). 
%   asOfEnd   - For FRED data, get all of the vintages between the
%               asOfStart date and the asOfEnd date (requires asOfStart). 
%
% For more information, see the cbd documentation file.

% David Kelley, 2014-2015


%% Error checking
validateattributes(series, {'cell', 'char'}, {'row'});
if ischar(series)
    series = {series};
end

% Extract the 3rd argument through the first string as input tables
firstString = find(cellfun(@ischar, varargin), 1, 'first');
if isempty(firstString)
    inTables = varargin;
    varargin = {};
else
    inTables = varargin(1:firstString-1);
    varargin = varargin(firstString:end);
end

% Input parser
inP = inputParser;
inP.addParameter('dbID', 'USECON', @ischar);
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', [], dateValid);
inP.addParameter('endDate', [], dateValid);
inP.addParameter('aggFreq', [], @ischar);
inP.addParameter('ignoreNan', false, @islogical);
inP.addParameter('asOf', [], dateValid);
inP.addParameter('asOfStart', [], dateValid);
inP.addParameter('asOfEnd', [], dateValid);

inP.parse(varargin{:});
opts = inP.Results;

%% Pull individual series
rawData = cell(length(series), 1);
dataProp = cell(length(series), 1);
for iSer = 1:length(series)
    clean_ser = series{iSer};
    clean_ser(clean_ser==' ') = [];
    [rawResponse, dataProp{iSer}] = cbd.private.expression_eval(clean_ser, opts, inTables{:});
    if ~isempty(rawResponse)
        rawData{iSer} = rawResponse;
    end
end

%% Combine series
if length(rawData) > 1
    data = cbd.merge(rawData{:});
else 
    data = rawData{1};
end

end

