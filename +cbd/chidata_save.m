function chidata_save(sectionName, data, properties)
%CHIDATA_SAVE Saves a data series to the CHIDATA folder 
%
% 
%
% chidata_save(sectionName, data) updates the section file with the data
% contained in data. 
%
% chidata_save(sectionName, data, properties) saves the data to a new
% section of CHIDATA and updates (or creates) a properties file with the
% properties given. 

% David Kelley, 2014

chidataDir = 'O:\PROJ_LIB\Presentations\Chartbook\Data\CHIDATA\';
indexFileName = [chidataDir 'index.csv'];
dataFileName = [chidataDir sectionName  '_data.csv'];
propertiesFileName = [chidataDir sectionName '_prop.csv'];

assert(istable(data));

%% Make sure index.csv has the series in it. 
indexTab = readtable(indexFileName);
writeFile = false;
seriesNames = data.Properties.VariableNames;

indexSeries = indexTab.Series;

inIndex = @(str) any(strcmpi(str, indexSeries));
seriesInDict = cellfun(inIndex, seriesNames);

if any(~seriesInDict) && ~all(~seriesInDict)
    warning('chidata_save:addSeries', ['Adding series to section ' sectionName]);
end

if any(~seriesInDict)
    indexTab = [indexTab; ...
        table(seriesNames(~seriesInDict)', repmat({sectionName}, [sum(~seriesInDict) 1]), ...
        'VariableNames', {'Series', 'Section'})];
    writeFile = true;
end

% Does it have the right section? If not, change it!
sectionNames = indexTab.Section;
getSection = @(seriesID) sectionNames{strcmpi(seriesID, indexTab.Series)};
for iSer = 1:length(seriesNames)
    if ~strcmpi(getSection(seriesNames{iSer}), sectionName)
        promptOverwrite(true, ['Change section of ' seriesNames{iSer} '?']);
        indexTab{strcmpi(seriesNames{iSer}, indexSeries), 2} = {sectionName};
        writeFile = true;
    end
end

if writeFile
    writetable(indexTab, indexFileName);
end


%% Check consistency with current data
% Will prompt for overwrite if new data is shorter, revises any
% previous data, or adds or removes series to the section.

try
    oldData = readtable(dataFileName, 'ReadRowNames', true);
catch exception
    assert(exist('properties', 'var')>0, ...
        'Attempted to save series without properties file without supplying neccessary properties.');
    warning('chidata_save:newFile', ['New file created for ' sectionName]);
end

if ~exist('exception', 'var') || isempty(exception)
    promptOverwrite(datenum(data.Properties.RowNames{end}) < datenum(oldData.Properties.RowNames{end}), ...
        'New data ends prior to old data.');
    promptOverwrite(datenum(data.Properties.RowNames{1}) ~= datenum(oldData.Properties.RowNames{1}), ...
        'New data does not begin on same date as old data.');
    promptOverwrite(size(oldData,1) > size(data,1), 'New data history is shorter than old.');
    promptOverwrite(size(oldData,2) > size(data,2), 'New data has fewer series.'); % -1 for row column
    promptOverwrite(size(oldData,2) < size(data,2), 'New data has additional series.');
    
    minLen = min(size(oldData, 1), size(data,1));
    minWid = min(size(oldData, 2), size(data,2));
    equalArray = arrayfun(@isequal, oldData{1:minLen, 1:minWid}, data{1:minLen, 1:minWid});
    nanArray = arrayfun(@isnan, oldData{1:minLen, 1:minWid}) | arrayfun(@isnan, data{1:minLen, 1:minWid});
    promptOverwrite(~all(equalArray | nanArray), 'New data revises old data.');
end

%% Write data
writetable(data, dataFileName, 'WriteRowNames', true);

%% Properties File
if nargin > 2 && ~isempty(properties)
    % Check for consistency with old properties file
    oldProp = cbd.private.loadChidataProp(sectionName);
    if ~isempty(oldProp)
        oldProp = rmfield(oldProp, {'Name','DateTimeMod'});
        promptOverwrite(~isequal(oldProp, properties), 'Properties changed from existing file.');
    end
    
    % Create table version of properties
    for iProp = 1:length(properties)
        properties(iProp).DateTimeMod = datestr(now);
    end
    propCell = squeeze(struct2cell(properties));
    assert(all(~any(cellfun(@strcmp, propCell, repmat({','}, size(propCell))))), ...
        'Property names cannot contain commas.');
    cellNames = fieldnames(properties);
    propTable = cell2table(propCell, 'RowNames', cellNames, 'VariableNames', data.Properties.VariableNames);
    
    % Write data
    writetable(propTable, propertiesFileName, 'WriteRowNames', true);
end

end


function promptOverwrite(condition, msg)
% Asks for user to confirm writing data in potential dangerous situations.

if condition
    disp(msg);
    confirm = input('Overwrite? (y/n)>> ', 's');
    
    if ischar(confirm) && strcmpi(confirm(1),'y')
        disp('Continuing...');
    else
        error('chidata_save:user', 'User halted execution.');
    end
end


end