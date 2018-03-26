% X13 calls the x13as program of the US Census Bureau / Bank of Spain to
% perform seasonal and extreme value adjustments.
%
% Usage (single time series):
%   x = x13([dates,data])
%   x = x13([dates,data],spec)
%   x = x13(dates,data)
%   x = x13(dates,data,spec)
%   x = x13(ts,spec)
%   x = x13(..., 'quiet')
%   x = x13(..., 'x-12')
%   x = x13(..., 'x-13')
%   x = x13(..., 'html')
%   x = x13(..., '-s', '-c', '-w', ... etc)
%   x = x13(..., 'noflags')
%   x = x13(..., 'graphicsmode')
%   x = x13(..., 'graphicsloc',path)
%   x = x13(..., 'fileloc',path)
%   x = x13(..., 'progloc',path)
%   x = x13(..., 'prog',filename)
%
% 'dates' and 'data' are single column or single row vectors with obvious
% meanings. 'dates' must contain dates as datenum codes. Alternatively, use
% a timeseries object ('ts') containing a single time series. In version 3 and 4
% above, dates can also be a datetime class variable (this is available in ML
% 2014b and later).
%
% 'spec' is a x13spec object containing the specifications used by the
% x13as.exe program. If no 'spec' is given, the program uses the specification
% that is produced by makespec('DEFAULT'), see help makespec.
%
% The output 'x' is a x13series object containing the requested numerical
% results, as well as the data and dates used as input.
%
% Normally, all warnings of the x13as/x12a program are shown on the console
% as Matlab warnings (for instance when a variable was requested but is not
% available). The switch 'quiet' suppresses warnings. The corresponding
% messages will still be contained in the resulting object, but they will not
% show up on the screen at runtime.
%
% Three switches are available that determine the program that is used to
% perform the seasonal decomposition. The 'x-12' switch uses the x12a
% program instead of the x13as program. The 'x-13' switch enforces the use
% of the x13as program. This is the default. Note that the x13spec object
% allows all settings known to x13as, but this is a superset of what is
% known to x12a. Therefore, one can easily create settings that are not
% compatible with x12a. In particular, makespec will often create
% specifications that do not run with x12a. (As an example, the keys 'spectrum'
% and 'seats' are not known to x12a.) Extra care is therefore required when
% using x12a.
%
% The 'html' switch uses the 'accessible version' of the Census program. The
% accessible version formats the tables and log files in html. Using this
% version has the advantage that you can view the output neatly formatted in
% your browser. The disadvantage is that the tables are not extracted and placed
% into the x13series (or x13collection) object. So, x.listoftables and x.table
% are empty. Instead, you can inspect the tables in the browser with web(x.out)
% and web(x.log). Note that 'html' has no effect if the 'x-12' or 'prog' options
% are used.
%
% Any string arguments starting with a hyphen are flags passed on to x13as.exe
% through the command line. Section 2.7 of the X-13ARIMA-SEATS Reference Manual
% explains the meanings of the different flags. Some flags are dealt with by the
% x13 Matlab program, so they should not be used by the user (in particular,
% using -g, -d, -i, -m, or -o is likely to mess up the functioning of the
% program).
%
% The most relevant flags are
% -w  Wide (132 character) format is used in main output file
% -n  (No tables) Only tables specifically requested in the input specification
%     file will be printed out 
% -r  Produce reduced X-13ARIMA-SEATS output (as in GiveWin version of
%     X-13ARIMA-SEATS)
% -s  Store seasonal adjustment and regARIMA model diagnostics in a file
% -c  Sum each of the components of a composite adjustment, but only perform
%     modeling or seasonal adjustment on the total
% -q  Run X-13ARIMA-SEATS in quiet-mode (warning messages not sent to the
%     console)
% -v  Only check input specification file(s) for errors; no other processing
%
% The -q flag suppresses all messages. In most cases it is probably a better
% idea to use the 'quiet' switch. This suppresses only the display of the
% warnings on the console, but the messages are still accessible in the
% x13series object.
%
% To use flags, use one of the following syntaxes,
%    x = x13(..., '-s'), or
%    x = x13(..., '-s', '-w'), or
%    x = x13(..., '-s -w'),
% or x = x13(..., 'noflags')
% If no flag is set by the user, the default is to set the '-s -n' flags, so
% that the diagnostics file is generated (-s) and only the requested tables (-n)
% are written to the .out property. The 'noflags' option removes all the flags,
% including the default. 
%
% Four optional arguments can be provided in name-value style: The argument
% following the 'fileloc' keyword is the location where all the files should be
% stored that are used and generated by the x13as program. If this optional
% argument is not used, these files will be located in a subdirectory 'X13' of
% the system's temporary files directory (%tempdir%\X13).
%
% The argument following the 'graphicsloc' keyword is the location where
% all the files should be stored that can be used with the separately
% available X-13-Graph program (see https://www.census.gov/srd/www/x13graph/).
% If this optional argument is used, x13as will run 'in graphics mode' and these
% files will be generated. If this argument is not used or set to [], the
% graphics-related files will not be generated. If 'graphicsloc' is set to
% '' (i.e. an empty string), then the graphics files will be created in a
% subdirectory called 'graphics' of the fileloc directory. The same is achieved
% with the switch 'graphicsmode'.
%
% The arguments following 'progloc' and 'prog', respectively, allow you to
% specify the location of the executables that do the computations.
% 'progloc' indicates the folder where the executables can be found. By
% default, this is the 'exe' subdirectity of the X-13 toolbox. 'prog' is
% the name of the executable itself. By default, this is 'x13as', or 'x12a'
% (or 'x12a64' on a 64-bit computer) if the 'x-12' option is set. (Note that
% the 'x-12' and 'x-13' options have no effect if you specify the 'prog'
% option.)
%
% So what is the 'prog' option really used for? You could, in principle, specify
% alternative executables, other than the ones provided by the US Census Bureau.
% The output of such an alternative program would have to be compatible
% with the output generated by the Census Bureau program. So, in practice,
% the only two conceivable options here are that either you have an older
% version of the Census Bureau software that you want to use, or you have a beta
% version which is in development. For instance, a previous version of x13as was
% version 1.1 build 9. If you have a copy of it, and you called it
% 'x13asv11b9.exe' on your harddisk (in the exe subdirectory of the
% toolbox), then
%   x = x13(..., 'prog','x13asv11b9');
% uses the previous version of the Census program.
%
% Usage (composite time series):
%   x = x13([dates1,data1],spec1, [dates2,data2],spec2, [...], compositespec)
%   x = x13(dates1,data1  ,spec1, dates2,data2  ,spec2, [...], compositespec)
%   x = x13([dates,data],{spec1,spec2,...},compositespec)
%   x = x13(ts,{spec1,spec2,...},compositespec)
%   x = x13(ts,spec1,[dates,data],spec2,dates,data,spec3,compositespec)
%   x = x13(..., 'x-12')
%   x = x13(..., 'x-13')
%   x = x13(..., 'html')
%   x = x13(..., '-s', '-c', '-w', ... etc)
%   x = x13(..., 'noflags')
%   x = x13(..., 'graphicsmode')
%   x = x13(..., 'graphicsloc',path)
%   x = x13(..., 'fileloc',path)
%   x = x13(..., 'progloc',path)
%   x = x13(..., 'prog',filename)
%
% In the first version you can specify different specifications for the
% individual time series. This usage is required if you want to provide
% individual names for the different time series.
%
% Alternatively, in the second usage form, 'data' may be an array with m
% columns, where each column is interpreted as one timeseries.
%
% The third usage is a variation of that. By specifying an array of m
% x13spec objects, you can give each time series in data its own spec.
%
% In the fourth and fifth usage form, all variables in the timeseries
% object 'ts' are interpreted as time series of the composite run. They are
% either all associated to the same spec (fourth usage), or to their
% respective spec in the list of specs (fifth usage form).
%
% You can also combine the syntax. In the sixth usage, all series in
% 'ts' will be associated with 'spec1' (or if 'spec1' is an array of specs,
% then the series contained in 'ts' will be associated to one of these
% specs), and all series in 'data' will be associated with 'spec2'.
%
% For composite runs, the last argument (except possible optional
% arguments) is always the specification of the composite series
% ('compositespec' cannot contain the 'series' section, but must contain
% the 'composite' section).
%
% Example 1:
%   spec = makespec('DIAG','PICK','X11');
%   x = x13([dates,data],spec);
% Then, 'x' is a x13series object with several variables, such as x.dat
% (containing the original data), x.d10, x.d11, x.d12, x.d13 (containing
% the results of the X11 filtering as produced by the x13as program), as
% well as different tables (essentially plain text). See the help of
% x13series for further explanation.
%
% Example 2:
% Let C, I, G, NX now be components of components of GDP of a country,
% measured at quarterly frequency (Y=C+I+G+NX), and D be the common dates vector
% when the components were measured.
%   spec = makespec('AUTO','TRAMO','SEATS','series','comptype','add');
%   x = x13( ...
%     [D,C], x13spec(spec,'series','name','C'), ...
%     [D,I], x13spec(spec,'series','name','I'), ...
%     [D,G], x13spec(spec,'series','name','G'), ...
%     [D,NX],x13spec(spec,makespec('ADDITIVE'),'series','name','NX'), ...
%     makespec('AUTO','TRAMO','SEATS','composite','name','Y'));
% Then, 'x' is a x13composite object containing x13series C, I, G, NX, and
% Y. Again, see the help of x13composite and x13series for further
% explanation. 
%
% Requirements: The program requires the X-13 programs of the US Census
% Bureau to be in the directory of the toolbox. The toolbox attempts to
% download the required programs itself. Should that attempt fail, you can
% download this software yourself for free from the US Census Bureau website.
% Download http://www.census.gov/ts/x13as/pc/x13as_V1.1_B26.zip and unpack
% the x13as.exe file to the 'exe' subdirectory of this toolbox.
%
% To install all programs and tools from the US Census Bureau that are
% supported by the X-13 Toolbox, issue the command
% InstallMissingCensusProgram once. The program will then attempt to
% download and install all files in one go.
% 
% Acknowledgments: Detailed comments by Carlos Galindo helped me make the
% Toolbox backward compatible.
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.32
%
% If you use this software for your publications, please reference it as
%   Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.32', Mathworks File
%   Exchange, 2017.

% History:
% 2017-03-26    Version 1.32    Support for datetime class variable for the
%                               dates.
% 2017-01-09    Version 1.3     First release featuring camplet.
% 2016-11-24    Version 1.20.1  Fixed a bug discovered by Carlos (a FEX
%                               user). The error message that is generated
%                               when the program cannot automatically
%                               download x13as.exe was crippled.
% 2016-10-13    Version 1.19    If no spec is given, makespec('DEFAULT') is
%                               used.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-08-20    Version 1.15    Significant speed improvement. The imported
%                               time series will now be mapped to the first
%                               day of month if this is the case for the
%                               original data as well. Otherwise, they will
%                               be mapped to the last day of the month. Two
%                               new options --- 'spline' and 'polynomial'
%                               --- for fixedseas. Improvement of .arima,
%                               bugfix in .isLog.
% 2015-07-25    Version 1.14    Improved backward compatibility. Overloaded
%                               version of seasbreaks for x13composite. New
%                               x13series.isLog property. Several smaller
%                               bugfixes and improvements.
% 2015-07-24    Version 1.13.3  Resolved some backward compatibility
%                               issues (thank you, Carlos).
% 2015-07-07    Version 1.13    seasma removed, replaced by fixedseas.
%                               Complete integration of fixedseas into
%                               x13spec, with fore-/backcast extension
%                               before computing trend for simple seasonal
%                               adjustment. Various improvemnts to
%                               x13series.plot (including 'separate' 
%                               option). seasbreaks program to identify
%                               seasonal breaks. Better support for PICKMDL
%                               model list files. Added '-n' to list of
%                               default flags in x13. Select print requests
%                               added as default in makespec.
% 2015-06-01    Version 1.12.3  Added 'quiet' switch.
% 2015-05-30    Version 1.12.2  Dealing with 'pickmdl.txt' file. Moreover,
%                               'fileloc' X13 subdirectory in temporary
%                               folder is created already by x13, not by
%                               x13series or x13composite, respectively.
% 2015-05-22    Version 1.12.1  Specification of flags without the 'flags'
%                               keyword. One can now say, for instance,
%                               x13(data,makespec(...),'-w'). Before, it
%                               was necessary to say x13(...,'flags','-w').
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-05-19    Version 1.6.1   Added 'seasma' option.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19, some bug fixes, 'html'
%                               switch
% 2015-04-02    Version 1.5     Adaptation to X-13 Version V 1.1 B19
% 2015-01-26    Version 1.3     Small bugfix
% 2015-01-24    Version 1.2     Bugfix (copy .prog and .progloc before
%                               using .PrepareFiles method (lines 400ff))
% 2015-01-21    Version 1.1     Collaboration with
%                               InstallMissingCensusProgram
% 2015-01-18    Version 1.09    Support for x12a and x12diag
% 2015-01-04    Version 1.05    Adapting to changes in x13series and
%                               x13composite classes
% 2015-01-01    Version 1.01    Bug fix: 'precision' instead of 'decimal'
%                               in created .spc file. Also, automatic
%                               support for NaNs ('missingcode' and
%                               'missingval')
% 2014-12-31    Version 1.0     First Version

function x = x13(varargin)

    %#ok<*SPWRN>

    % --- PRELIMINARIES ---------------------------------------------------
        
    tic;
    starttime = datenum(clock);
    
    % --- PARSE ARGUMENTS -------------------------------------------------
    
    dates   = cell(0);
    series  = cell(0);
    spec    = cell(0);
    nSeries = 0;
    
    defaultflags  = {'-n -s'};
    progloc       = [];
    prog          = [];
    fileloc       = [];
    graphicsloc   = [];
    useX12        = false;
    useHTML       = false;
    quiet         = false;
    warnings      = cell(0);
    
    % trim leading and trailing spaces of all string arguments
    isString = cellfun(@(v) ischar(v),varargin);
    varargin(isString) = strtrim(varargin(isString));
    
    % check if some options start with '-' (such as '-s')
    fopts = cellfun(@(v) ~isempty(v) && strcmp(v(1),'-'),varargin);
    flagsset = any(fopts);  % at least one flag arg was found
    flags = varargin(fopts);
    varargin(fopts) = [];
    
    for v = 2:nargin
        try  %#ok<TRYNC>
            validstr = validatestring(varargin{v}, ...
                {'progloc','prog','fileloc','graphicsloc','graphicsmode', ...
                'noflags','x-13','x-12','html','quiet'});
            switch validstr
                case 'progloc'
                    progloc = strtrim(varargin{v+1});
                    varargin{v+1} = [];
                case 'prog'
                    prog = strtrim(varargin{v+1});
                    varargin{v+1} = [];
                    [p1,p2,p3] = fileparts(prog);
                    if isempty(p3)
                        prog = fullfile(p1,[p2,'.exe']);
                    end
                case 'fileloc'
                    fileloc = strtrim(varargin{v+1});
                    varargin{v+1} = [];
                case 'graphicsloc'
                    if ischar(varargin{v+1})
                        graphicsloc = strtrim(varargin{v+1});
                        varargin{v+1} = [];
                    end
                case 'graphicsmode'
                    graphicsloc = '';
                case 'noflags'
                    flags = {};
                    flagsset = true;
                case 'x-13'
                    useX12 = false;
                case 'x-12'
                    useX12 = true;
                case 'html'
                    useHTML = true;
                case 'quiet'
                    quiet = true;
            end
            varargin{v}   = [];     % replace the argument we dealt with
                                    % with an empty set (it will be removed
                                    % alltogether after the loop)
        end
    end
    remove = cellfun(@(v) isempty(v),varargin); % remove empty args
    varargin(remove) = [];
    
    % if no flag was set by user, set the default flag
    if ~flagsset
        flags = defaultflags;
    end
    
    % graphisloc cannot contain spaces
    if ~isempty(strfind(graphicsloc,' '))
        str = sprintf(['Your path to the graphics files ', ...
            '(''graphsicsloc'') is "%s", but it cannot contain spaces. ', ...
            '''graphicsmode'' will therefore be turned off.'], graphicsloc);
        warnings{end+1} = [' TOOLBOX WARNING: ',str];
        warning('X13TBX:x13:IllegalPath', str);
        graphicsloc = [];
    end
    
    % no 'accessible version' for x-12
    if useX12 && useHTML
        str = ['''x-12'' and ''html'' cannot be selected simultaneouly. ', ...
            '''html'' selection will be ignored.'];
        warnings{end+1} = [' TOOLBOX WARNING: ',str];
        warning('X13TBX:x13:IncompatibleSelection', str)
        useHTML = false;
    end
    
    % find entries like '-s -p', i.e. strings containing more than one flag
    tosplit = find(cellfun(@(v) length(v)>2,flags));
    moreflags = cell(0);
    for z = 1:numel(tosplit)
        moreflags = [moreflags, strsplit(flags{tosplit(z)})];
    end
    flags(tosplit) = [];
    flags = [flags, moreflags];
    
    % split flags into cells
    if isempty(flags)   % '' or {} or []
        flags = {};
    else
        if ~iscell(flags)
            flags = {flags};
        end
        for f = 1:numel(flags)
            if ~iscell(flags{f})
                thisflags = strsplit(flags{f});
            else
                thisflags = flags{f};
            end
            flags = [flags,thisflags];
        end
        flags = unique(flags);
        % remove unsupported flags
        legal = {'-c','-d','-g','-i','-m','-n','-o','-p','-q','-r','-s', ...
            '-v','-w'};
        keep = ismember(flags,legal);
        if any(~keep)   % some flags are not supported
            if sum(~keep) > 1
                str = sprintf('Flags ''%s'' are not supported.', ...
                    strjoin(flags(~keep)));
            else
                str = sprintf('Flag ''%s'' is not supported.', flags{~keep});
            end
            warnings{end+1} = [' TOOLBOX WARNING: ',str];
            warning('X13TBX:x13:UnsupportedFlag',str);
        end
        flags = unique(flags(keep));    % keep only the legal ones
    end
    flags = strjoin(flags);
    
    % make subdirectory in temporary folder, or in place requested
    % by the user
    if isempty(fileloc)
        fileloc = [tempdir,'X13\'];
    elseif ~strcmp(fileloc(end),'\')
        fileloc = [fileloc,'\'];
    end
    if exist(fileloc,'file') ~= 7   % ... code 7 refers to directory
        mkdir(fileloc);
    end

    % get data and specs
    while ~isempty(varargin)
        
        isArrayOfSpecs = false;
        
        if numel(varargin) > 1
            
%             if iscell(varargin{2})
%                 isArrayOfSpecs = true;
%                 if ~all(cellfun(@(x) isa(x,'x13spec'), varargin{2}))
%                     err = MException('X13TBX:x13:IllegalSpec', ...
%                         ['Program expects x13spec objects ', ...
%                         'or a cell array of such objects on the even ', ...
%                         'numbered positions of the argument list.']);
%                     thow(err);
%                 end
%                 ArrayOfSpecs = varargin{2};
%             else
%                 thisSpec = varargin{2};
%                 if isempty(thisSpec)
% %                    thisSpec = x13spec();
%                     thisSpec = cbd.private.sax13.makespec('DEFAULT');
%                 end
%                 if ~isa(thisSpec,'x13spec')
%                     err = MException('X13TBX:x13:IllegalSpec', ...
%                         ['Program expects x13spec objects ', ...
%                         'on the even numbered positions of the ', ...
%                         'argument list.']);
%                     throw(err);
%                 end
%             end

            if isa(varargin{1},'timeseries')

                ts         = varargin{1};
                thisDates  = ts.Time;
                thisSeries = ts.Data;
                ncol       = size(ts.Data,2);

            elseif isnumeric(varargin{1})

                [nrow,ncol] = size(varargin{1});
                doTranspose = (nrow <= 2 && ncol > 2);
                if doTranspose
                    varargin{1} = varargin{1}';
                    ncol = nrow;
                end
                if ncol == 1
                    if doTranspose
                        varargin{2} = varargin{2}';
                    end
                    thisDates   = varargin{1};
                    thisSeries  = varargin{2};
                    varargin(2) = [];
                else
%                    ncol = ncol-1;
                    thisDates = varargin{1}(:,1);
                    thisSeries = varargin{1}(:,2:end);
                end
                ncol = size(thisSeries,2);
                
            elseif isa(varargin{1},'datetime')
                thisDates   = datenum(varargin{1});
                thisSeries  = varargin{2};
                varargin(2) = [];
                [nrow,ncol] = size(thisDates);
                doTranspose = (nrow == 1 && ncol > 1);
                if doTranspose
                    thisDates  = thisDates';
                    thisSeries = thisSeries';
                end
                ncol = size(thisSeries,2);

            else

                err = MException('X13TBX:x13:IllegalArg', ...
                    ['Program expects numeric data on the odd ', ...
                    'numbered positions of the argument list.']);
                throw(err);

            end
            
            if iscell(varargin{2})
                isArrayOfSpecs = true;
                if ~all(cellfun(@(x) isa(x,'x13spec'), varargin{2}))
                    err = MException('X13TBX:x13:IllegalSpec', ...
                        ['Program expects x13spec objects ', ...
                        'or a cell array of such objects on the even ', ...
                        'numbered positions of the argument list.']);
                    thow(err);
                end
                ArrayOfSpecs = varargin{2};
            else
                thisSpec = varargin{2};
                if isempty(thisSpec)
%                    thisSpec = x13spec();
                    thisSpec = cbd.private.sax13.makespec('DEFAULT');
                end
                if ~isa(thisSpec,'x13spec')
                    err = MException('X13TBX:x13:IllegalSpec', ...
                        ['Program expects x13spec objects ', ...
                        'on the even numbered positions of the ', ...
                        'argument list.']);
                    throw(err);
                end
            end

            if isArrayOfSpecs && numel(ArrayOfSpecs) ~= ncol
                err = MException('X13TBX:x13:IllegalNbArgs', ...
                    ['You''ve provided %i x13spec objects, but %i ', ...
                    'time series of data. The two numbers must be ', ...
                    'the same.'], numel(ArrayOfSpecs), ncol);
                throw(err);
            end

            nSeries = nSeries + ncol;
            for s = 1:ncol
                dates{end+1}    = thisDates; %#ok<*AGROW>
                series{end+1}   = thisSeries(:,s);
                if isArrayOfSpecs
                    spec{end+1} = ArrayOfSpecs{s};
                else
                    spec{end+1} = thisSpec;
                end
            end
            
            varargin(1:2) = [];
            
        else    % only one varargin remains
            
            if nSeries == 0     % must be data, with no specs specified
                
%                thisSpec = x13spec();    % empty spec set
                thisSpec = cbd.private.sax13.makespec('DEFAULT');
                if isa(varargin{1},'timeseries')
                    [thisDates,thisSeries,ncol] = ts2arr(varargin{1});
                elseif isnumeric(varargin{1})
                    [nrow,ncol] = size(varargin{1});
                    doTranspose = (nrow == 2 && ncol > 2);
                    if doTranspose
                        varargin{1} = varargin{1}';
                        ncol = nrow;
                    end
                    thisDates  = varargin{1}(:,1);
                    thisSeries = varargin{1}(:,2:end);
                    ncol = size(thisSeries,2);
                elseif isa(varargin{1},'datetime')
                    thisDates   = datenum(varargin{1});
                    thisSeries  = varargin{2};
                    varargin(2) = [];
                    [nrow,ncol] = size(thisDates);
                    doTranspose = (nrow == 1 && ncol > 1);
                    if doTranspose
                        thisDates  = thisDates';
                        thisSeries = thisSeries';
                    end
                    ncol = size(thisSeries,2);
                else
                    err = MException('X13TBX:x13:IllegalArg', ...
                        ['Program expects numeric data on the odd ', ...
                        'numbered positions of the argument list.']);
                    throw(err);
                end
                
                nSeries = nSeries + ncol;
                for s = 1:ncol
                    dates{end+1}  = thisDates;
                    series{end+1} = thisSeries(:,s);
                    spec{end+1}   = thisSpec;
                end
                
            else                % must be composite specs
                
                if ~isa(varargin{1},'x13spec')
                    err = MException('X13TBX:x13:IllegalSpec', ...
                        'Last argument must be an x13spec object.');
                    throw(err);
                end
                compositeSpec = x13spec( ...
                    'composite','name','composite', ...
                    varargin{1});
                
            end
            
            varargin(1) = [];
            
        end
        
    end
    
    if nSeries == 0
        err = MException('X13TBX:x13:NoData', ...
            'x13 expects some data to process.');
        throw(err);
    end

    % --- LOCATE X13/X12 PROGRAM ------------------------------------------
    
    if isempty(progloc)
        progloc = fileparts(mfilename('fullpath')); % directory of this m-file
        progloc = [progloc,filesep,'exe',filesep];  % exe-subdirectory
    end
    
    if isempty(prog)
        is64 = strcmp(mexext,'mexw64');             % running 64-bit version?
        % location and name of x13/x12 program
        if useX12
            prog32 = fullfile(progloc,'x12a.exe');
            prog64 = fullfile(progloc,'x12a64.exe');
        else
            if ~useHTML
                prog64 = fullfile(progloc,'x13as.exe');
                prog32 = prog64;
            else
                prog64 = fullfile(progloc,'x13ashtml.exe');
                prog32 = prog64;
            end
        end
        % check if present
        existprog = [exist(prog32,'file'), exist(prog64,'file')];
        if is64 && existprog(2)
            prog = prog64;
        else    % use 32bit version also on 64bit machine if 64bit version
                % of program is not present
            prog = prog32;
        end
        % if program not present, try to download. If download fails, throw
        % an error.
        if exist(prog,'file')
            % extract filename
            [~,prog,ext] = fileparts(prog);
            prog = [prog,ext];
        else
            if useX12
                if is64
                    success = InstallMissingCensusProgram('x12_64');
                    prog = 'x12a64.exe';
                else
                    success = InstallMissingCensusProgram('x12_32');
                    prog = 'x12a.exe';
                end
                if ~success
                    err = MException('X13TBX:x13:ProgramMissing', ...
                        ['X-12 program is missing and automatic ', ...
                        'download failed. Try manual download from', ...
                        '''https://www.census.gov/ts/x12a/v03/pc/%s'' ', ...
                        'and unpack to ''exe'' subdirectory of the ', ...
                        'toolbox (''%s'').'], 'omegav03.zip', progloc);
                    throw(err);
                end
            else
                if ~useHTML
                    success = InstallMissingCensusProgram('x13prog');
                    prog    = 'x13as.exe';
                    theZIP  = 'x13as_V1.1_B26.zip';
                else
                    success = InstallMissingCensusProgram('x13proghtml');
                    prog    = 'x13ashtml.exe';
                    theZIP  = 'x13ashtml_V1.1_B26.zip';
                end
                if ~success
                    err = MException('X13TBX:x13:ProgramMissing', ...
                        ['X-13 program is missing and automatic ', ...
                        'download failed. Try manual download from ', ...
                        '''https://www.census.gov/ts/x13as/pc/%s'' ', ...
                        'and unpack to ''exe'' subdirectory of the ', ...
                        'toolbox (''%s'').'], theZIP, progloc);
                    throw(err);
                end
            end
        end
    end
    
    % --- PROCESS EVERYTHING ----------------------------------------------
    
    isComposite = (nSeries > 1);
    if isComposite
        x = cbd.private.sax13.x13composite();
        x.prog        = prog;
        x.progloc     = progloc;
        x.ishtml      = useHTML;
        x.fileloc     = fileloc;
        x.graphicsloc = graphicsloc;
        x.flags       = flags;
        x.quiet       = quiet;
        x.warnings    = warnings;
        x.specgiven   = [spec,{compositeSpec}];
        x = x.PrepareFiles(dates,series,spec,compositeSpec);
        x = x.Run;
        x = x.CollectFiles;
    else
        x = cbd.private.sax13.x13series();
        x.prog        = prog;
        x.progloc     = progloc;
        x.ishtml      = useHTML;
        x.fileloc     = fileloc;
        x.graphicsloc = graphicsloc;
        x.flags       = flags;
        x.quiet       = quiet;
        x.warnings    = warnings;
        x.specgiven   = spec{1};
        x = x.PrepareFiles(dates{1},series{1},spec{1});
        x = x.Run;
        x = x.CollectFiles;
    end
    
    x.timeofrun = {starttime,toc};