function [output, seriesProp] = expression_eval(strIn, opts, varargin)
%EXPRESSION Evaluate a cbd data expression with printf-style input
%
% Evaluate an expression of series, functions, operators, options, and 
% other parameters, returning a table with one data series. See the cbd
% documentation for more info on how to specify a series which should
% generally be done using the cbd.data function (which calls this function).
%
% INPUTS:
%   strIn - string to be evaluated.
%   opts  - options structure to be passed down to database functions
%   (contains dates, etc.)
%   varargin - additional cbd tables to be entered into 
% OUTPUTS:
%   output - a table containing the series
%   seriesProp - a structure containing information on the data series and
%   underlying components including mnemonics and function names. 

% David Kelley, 2015

cbdLoc = 'O:\PROJ_LIB\Presentations\Chartbook\Data\Dataset Creation\cbd';

%% Check that number of input arguments match '%d's in string
assert(size(strfind(strIn, '%d'), 2) == size(varargin, 2), 'expression:spec', ...
    'Must include as many tables as ''%d'' inputs in string.');

%% Treat input as either a Haver series, a scalar, or a function of those two
argumentRegex = regexpi(strIn, '#');
operatorRegex = regexpi(strIn, '[/*\-+]');
noParen = find(~getParenDepth(strIn));
noQuote = find(~getQuoteDepth(strIn));
argumentDiv = intersect(intersect(noParen, noQuote), argumentRegex);
operatorDiv = intersect(intersect(noParen, noQuote), operatorRegex);

tableInRegex = regexpi(strIn, '%d');
% tableInStarts = intersect(intersect(noParen, noQuote), tableInRegex);

fnRegex = regexpi(strIn, '(\(|\))');

if ~isempty(operatorDiv)
    % Literal operator evaluation
    operators = '+-*/';
    operations = {'addition', 'subtraction', 'multiplication', 'division'};
    for iOp = 1:length(operators)
        [args, opBreak] = breakOnChar(strIn, operators(iOp));
        
        tabIns = {varargin(tableInRegex < opBreak(1)), varargin(tableInRegex > opBreak(1))};
        
        if length(args) > 2
            args = {args{1} strjoin(args(2:end), operators(iOp))};
        end
        
        if length(args) == 2
            arguments = cell(size(args));
            seriesProps = cell(length(args),1);
            
            for iArg = 1:2
                [arguments{iArg}, seriesProps{iArg}] = ...
                    cbd.private.expression_eval(args{iArg}, opts, tabIns{iArg}{:});
            end
            op_fn = str2func(['cbd.' operations{iOp}]);
            output = op_fn(arguments{:}, 'ignoreNan', opts.ignoreNan);
            seriesProp = cbd.private.combineProp(operations{iOp}, seriesProps{:});
            return
        end
    end
    
elseif ~isempty(argumentDiv)
    % hash(#)-argument to be applied to preceeding string (up to a function)
    mainStr = strIn(1:argumentDiv(1)-1);
    argumentStr = strIn(argumentDiv(1)+1:end);
    if length(argumentDiv) > 1
        arguments = arrayfun(@(sInd,eInd) strIn(sInd:eInd), ...
        argumentDiv+1, [argumentDiv(2:end)-1 length(strIn)],...
        'UniformOutput', false);
    else
        arguments = {argumentStr};
    end
    
    for iArg = 1:length(arguments)
        if ~isempty(strfind(arguments{iArg}, ':'))
            iOpt = strsplit(arguments{iArg}, ':');
            opts.(iOpt{1}) = quoteStrip(iOpt{2});
        else
            opts.(arguments{iArg}) = true;
        end
    end
    [output, seriesProp] = cbd.private.expression_eval(mainStr, opts, varargin{:});
    
elseif ~isempty(fnRegex) 
    % Function evaluation
    % Check for opening and closing parentheses
    %   Grouping parentheses are taken as a null function
    openParens = strfind(strIn, '(');
    assert(~isempty(openParens), 'expression:expression_eval:parens', ...
        ['Mismatched parentheses in ' strIn '.']);
    
    if strcmp(strIn(end),')')
        strIn = strIn(1:end-1);
    else
        error('Last char not '')''');
    end
    
    % Strip out function and arguments
    fnNameIn = strIn(1:openParens(1)-1);
    argStr = strIn(openParens(1)+1:end);
    [args, argBreak] = breakOnChar(argStr, ',');
    argBreak = argBreak + openParens(1)+1;
    tabIns = {varargin(tableInRegex < argBreak(1)), varargin(tableInRegex > argBreak(1))};

    arguments = cell(length(args),1);
    seriesProps = cell(length(args),1);
    for iArg = 1:length(args)
        if  iArg <= length(tabIns)
            iArguments = tabIns{iArg};
        else
            iArguments = {};
        end
        [arguments{iArg}, seriesProps{iArg}] = ...
            cbd.private.expression_eval(args{iArg}, opts, iArguments{:});
    end
    
    if ~isempty(fnNameIn)
        fnName = strrep(lower(fnNameIn), '%', 'Pct');
        assert(2 == exist([cbdLoc filesep '+cbd' filesep fnName '.m'], 'file'), ...
            'expression:expression_eval:function', ...
            ['Undefined transformation ' upper(fnName) '.']);
        
        try
            haver_fn = str2func(['cbd.' fnName]);
            output = haver_fn(arguments{:});
        catch e
            try
                haver_fn = str2func(['cbd.' fnNameIn]);
                output = haver_fn(arguments{:});
            catch
                throw(e)
            end
            
        end
    else
        assert(length(arguments) <= 1);
        output = arguments{1};
        fnName = '';
    end
    
    seriesProp = cbd.private.combineProp(fnName, seriesProps{:});
    
elseif ~isempty(tableInRegex)
    output = varargin{1};
    seriesProp = struct;
    seriesProp.ID = [];
    seriesProp.dbInfo = [];
    seriesProp.value = output;
    
elseif ~isempty(str2double(strIn)) && ~isnan(str2double(strIn))
    % Numeric input argument
    output = str2double(strIn);
    seriesProp = struct;
    seriesProp.ID = [];
    seriesProp.dbInfo = [];
    seriesProp.value = output;
    
elseif ~isempty(strfind(strIn, '"'))
    % String input argument
    cleanStr = strtrim(strIn);
    assert(strcmp(cleanStr(1), '"') & strcmp(cleanStr(end), '"'), ...
        'expression:expression_eval:stringInput', ...
        ['Mismatched quote characters: ' cleanStr]);
    output = cleanStr(2:end-1);
    seriesProp = struct;
       
else
    % Untransformed series
    split = strsplit(strIn,'@');
    assert(length(split) <= 2, 'expression:expression_eval:invalidInput', ...
        ['Multiple @ signs in series call: ' strIn]);
    
    seriesName = split{1};
    if length(split) == 2
        opts.dbID = split{2};
    end
    
    if strcmpi(opts.dbID, 'FRED')
        [output, seriesProp] = cbd.private.fredseries(seriesName, opts);
    elseif strcmpi(opts.dbID, 'CHIDATA')
        [output, seriesProp] = cbd.private.chidataseries(seriesName, opts);
    else
        [output, seriesProp] = cbd.private.haverseries(seriesName, opts);
    end
end
end

%% Helper functions

function [args, breakInds] = breakOnChar(argStr, breakChar)
% Split arguments - any commas not in quotes or parentheses
parenDepth = getParenDepth(argStr);
commasCharInds = argStr == breakChar;
breaks = parenDepth == 0 & commasCharInds == 1;
breakInds = [find(breaks)-1 length(breaks)];
breakIndsDiff = [breakInds(1) (breakInds(2:end) - breakInds(1:end-1))];

args = mat2cell(argStr, 1, breakIndsDiff);

for iArg = 1:length(args)
    if args{iArg}(1) == breakChar;
        args{iArg} = args{iArg}(2:end);
    end
end
end

function parenC = getParenDepth(strIn)
openParens = strIn == '(';
closParens = strIn == ')';
parenC = cumsum(openParens) - cumsum(closParens);
end

function quoteD = getQuoteDepth(strIn)
quoteChars = find(strIn == '"');
assert(mod(length(quoteChars), 2) == 0, 'expression:expression_eval:mismatchedString', ...
    'Mismatched string delimiters.');
openQuote = quoteChars(1:2:end-1);
closeQuote = quoteChars(2:2:end);
quoteD = zeros(size(strIn));
for iStr = 1:length(openQuote)
    quoteD(openQuote(iStr):closeQuote(iStr)) = 1; 
end
end

function cleanStr = quoteStrip(strIn)
cleanStr = strtrim(strIn);
if strcmpi(cleanStr(1), '"') && strcmpi(cleanStr(end), '"')
    cleanStr = cleanStr(2:end-1);
end
end