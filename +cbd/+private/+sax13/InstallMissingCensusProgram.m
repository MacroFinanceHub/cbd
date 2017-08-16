% INSTALLMISSINGCENSUSPROGRAM installs pieces of software from the US
% Census Bureau that are necessary to perform the seasonal filtering.
%
% Usage:
%   InstallMissingCensusProgram()
%   InstallMissingCensusProgram(arg, [arg2], [...])
%   success = InstallMissingCensusProgram([...])
%   InstallMissingCensusProgram('all')
%
% If called with no argument, the program tries to install all usable
% files. Alternatively, an argument or a list of arguments can be provided.
% Choices are:
%   'x13prog'       X-13 software
%   'x13proghtml'   X-13 software, accessible version
%   'x12diag'       X-12 diagnostic utility
%   'x12_64'        X-12 software, 64 bit
%   'x12_32'        X-12 software, 32 bit
%   'x13doc'        documentation of X-13 program
%   'x13dochtml'    documentation of X-13 program, accessible version
%   'x12doc'        documentation of X-12 program
% The function returns a vector of booleans, indicating which installations
% were successful.
% 
% Using this function with no arguments
%   InstallMissingCensusProgram;
% should produce the following result:
%   Downloading 'x13as_V1.1_B39.zip' from US Census Bureau website ... success.
%   Downloading 'x13ashtml_V1.1_B39.zip' from US Census Bureau website ... success.
%   Downloading 'docsX13.zip' from US Census Bureau website ... success.
%   Downloading 'gettingstartedx13_winx13.pdf' from US Census Bureau website ... success.
%   Downloading 'docsX13Acc.zip' from US Census Bureau website ... success.
%   Downloading 'itoolsv03.zip' from US Census Bureau website ... success.
%   Downloading 'omega64v03.zip' from US Census Bureau website ... success.
%   Downloading 'omegav03.zip' from US Census Bureau website ... success.
%   Downloading 'docsv03.zip' from US Census Bureau website ... success.
%
% After that, all programs of the US Census Bureau website that are
% supported by the X-13 Toolbox are installed on your computer.
%
% In addition, five other programs that are related to X13ARIMA-SEATS can also
% be downloaded:
%
%   'x11'           An early version of the Census program.
%   'genhol'        A program that allows the user to create variable files for
%                   holidays.
%   'x13graph'      The JAVA version of the X-13 graph program.
%   'x13data'       A utility to transform data in an Excel sheet into files
%                   usable by x13as.exe, as well as for collecting x13as.exe
%                   output and storing it in an Excel file.
%   'cnv'           A utility to convert X-12 specification files to the X-13
%                   format.
%   'sam'           A utility to change several spec files at once. It's
%                   unlikely that you will use this if you use X-13 with Matlab.
%
% These programs are not directly supported by the Matlab-Toolbox. x11 is not
% supported because its syntax is completely different from x13 and it is
% potentially prone to Y2K problems. The x13graph java program can be used if
% you add the 'graphicsmode' switch when calling x13, but you need to start
% the graph program from the command line. Likewise, genhol, or the version with
% a GUI called wingenhol, can be used independently from Matlab. The toolbox
% does not interact with these programs directly.
%
% Calling InstallMissingPrograms('all') installs everything, including these
% five additional sets of programs and files.
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
%   Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.30', Mathworks File
%   Exchange, 2016.

% History:
% 2017-03-24    Version 1.32    Added x13sam.
% 2017-03-10    Version 1.31    Adaptation to X13ARIMA-SEATE V1.1 B39.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-11-28    Version 1.20.3  Added original X-11 documentation file.
% 2016-11-24    Version 1.20.1  Documentation of X-11 is no longer
%                               available from EViews. An alternative
%                               source is no being used. Also, the additional
%                               downloads (from 'x11' to 'cnv') have been
%                               extended.
% 2016-08-22    Version 1.18.2  Added 'all' option.
% 2016-08-20    Version 1.18    Support for downloading x13graphjava.
% 2016-07-22    Version 1.17.4  Improved warning message.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-29    Version 1.16.1  Added X-11 download from EViews website.
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
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19, inclusion of accessible
%                               version
% 2015-04-02    Version 1.1     Adaptation to X-13 Version V 1.1 B19
% 2015-01-21    Version 1.0

function success = InstallMissingCensusProgram(varargin)

    % location of the various files on the US Census website

    x13prog = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x13as/pc/x13as_V1.1_B39.zip', ...
        'dir',      'x13as', ...
        'files',    'x13as.exe', ...
        'loc',      'exe');

    x13proghtml = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x13as/pc/x13ashtml_V1.1_B39.zip', ...
        'dir',      'x13ashtml', ...
        'files',    'x13ashtml.exe', ...
        'loc',      'exe');

    x13doc = struct( ...
        'source',   'US Census Bureau', ...
        'url',      {'https://www.census.gov/ts/x13as/pc/docsX13.zip', ...
                     'https://www.census.gov/ts/papers/gettingstartedx13_winx13.pdf'}, ...
        'dir',      {'docs', []}, ...
        'files',    {'docX13AS.pdf qrefX13ASpc.pdf', 'gettingstartedx13_winx13.pdf'}, ...
        'loc',      {'doc', 'doc'});

    x13dochtml = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x13as/pc/docsX13Acc.zip', ...
        'dir',      'docs', ...
        'files',    'docX13ASHTML.pdf qrefX13ASHTMLpc.pdf', ...
        'loc',      'doc');

    x12diag = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x12a/v03/pc/itoolsv03.zip', ...
        'dir',      'tools', ...
        'files',    'x12diag03.exe libjpeg.6.dll libpng3.dll zlib1.dll', ...
        'loc',      'exe');

    x12_64 = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x12a/v03/pc/omega64v03.zip', ...
        'dir',      [], ...
        'files',    'x12a64.exe', ...
        'loc',      'exe');

    x12_32 = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x12a/v03/pc/omegav03.zip', ...
        'dir',      [], ...
        'files',    'x12a.exe', ...
        'loc',      'exe');

    x12doc = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x12a/v03/pc/docsv03.zip', ...
        'dir',      'docs', ...
        'files',    'x12adocV03.pdf qref03pc.pdf', ...
        'loc',      'doc');
    
    % The Census Bureau does not distribute X-11 anymore. EViews still does.
    % The option 'x11' to download the x-11 executables from EViews' website is
    % provided here just for completeness. The X-13 Matlab toolbox does not
    % support X-11 (because its syntax is very different).
%     x11 = struct( ...
%         'source',   'EViews(R)', ...
%         'url',      {'http://www.eviews.com/download/older/x11.zip', ...
%                      'ftp://ftp.rau.am/EViews%20Enterprise%20Edition%207.0.0.1/Docs/x11/X11V2.PDF', ...
%                      'ftp://ftp.rau.am/EViews%20Enterprise%20Edition%207.0.0.1/Docs/x11/X11V2QRF.PDF'}, ...
%         'dir',      {[], [], []}, ...
%         'files',    {'X11Q2.exe X11SS.exe', 'X11V2.PDF', 'X11V2QRF.PDF'}, ...
%         'loc',      {'exe', 'doc', 'doc'});
    % As of November 2016, some of the X-11 documentation does not seem to be
    % available from the EViews FTP server anymore. An alternative source
    % in Canada has been located.
    x11 = struct( ...
        'source',   {'EViews(R)', 'US Census Bureau', 'US Census Bureau', ...
                     'US Census Bureau', 'Brock University', 'Brock University'}, ...
        'url',      {'http://www.eviews.com/download/older/x11.zip', ...
                     'https://www.census.gov/ts/papers/ShiskinYoungMusgrave1967.pdf', ...
                     'https://www.census.gov/ts/papers/1980X11ARIMAManual.pdf', ...
                     'https://www.census.gov/ts/papers/Emanual.pdf', ...
                     'https://remote.bus.brocku.ca/files/Published_Resources/EViews_8/x11/X11V2.PDF', ...
                     'https://remote.bus.brocku.ca/files/Published_Resources/EViews_8/x11/X11V2QRF.PDF'}, ...
        'dir',      {[], [], [], [], [], []}, ...
        'files',    {'X11Q2.exe X11SS.exe', 'ShiskinYoungMusgrave1967.pdf', ...
                     '1980X11ARIMAManual.pdf', 'Emanual.pdf', ...
                     'X11V2.PDF', 'X11V2QRF.PDF'}, ...
        'loc',      {'exe', 'doc', 'doc', 'doc', 'doc', 'doc'});

    genhol = struct( ...
        'source',   'US Census Bureau', ...
        'url',      {'https://www.census.gov/ts/genhol/genhol_V1.0_B8.zip', ...
                     'https://www.census.gov/ts/x13as/pc/toolsx13.zip', ...
                     'https://www.census.gov/ts/TSMS/wingenhol/wingenhol_V1.0_B2.zip', ...
                     'https://www.census.gov/ts/TSMS/wingenhol/wingenholdoc.pdf', ...
                     'https://www.census.gov/ts/TSMS/wingenhol/wingenholexamples.pdf'}, ...
        'dir',      {'genhol','tools','WinGenhol',[],[]}, ...
        'files',    {['genhol.exe abseaster8.inp easter8.inp easter500.txt ', ...
                      'IFHOLIND.DAT CNYIND.DAT indhol.inp stockeaster8.inp ', ...
                      'stockeaster8d28.inp'], ...
                     'genhol.html', ...
                     'WinGenhol.exe libpthread-2.dll ExpTreeLib.dll', ...
                     'wingenholdoc.pdf', 'wingenholexamples.pdf'}, ...
        'loc',      {'tools\genhol','tools\genhol','tools\genhol', ...
                     'tools\genhol','tools\genhol'});
    
    x13graph = struct( ...
        'source',   'US Census Bureau', ...
        'url',      {'https://www.census.gov/ts/TSMS/x13graph/x13graphjava_V2.1.zip', ...
                     'https://www.census.gov/ts/TSMS/x13graph/x13graphjava_V2.1.zip', ...
                     'https://www.census.gov/ts/TSMS/x13graph/x13g_java_doc.pdf'}, ...
        'dir',      {'x13graphjava','x13graphjava\lib', []}, ...
        'files',    {'X13GraphJava.jar', ...
                     ['jcommon-1.0.13.jar ', ...
                     'jfreechart-1.0.10.jar swing-layout-1.0.3.jar ', ...
                     'swing-layout-1.0.jar'], ...
                     'x13g_java_doc.pdf'}, ...
        'loc',      {'tools\graphjava','tools\graphjava\lib','tools\graphjava'});

    x13data = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/TSMS/WIX13/x13data_V2.0.zip', ...
        'dir',      'x13data', ...
        'files',    'X13Data.exe ExpTreeLib.dll X13DataDoc.pdf', ...
        'loc',      'tools\x13data');
    
    cnv = struct( ...
        'source',   'US Census Bureau', ...
        'url',      'https://www.census.gov/ts/x13as/pc/toolsx13.zip', ...
        'dir',      'tools', ...
        'files',    'cnvx13as.exe cnvx13as.html', ...
        'loc',      'tools\cnv');
    
    sam = struct( ...
        'source',   'US Census Bureau', ...
        'url',      {'https://www.census.gov/ts/TSMS/X13SAM/x13sam_V1.0.zip', ...
                     'https://www.census.gov/ts/TSMS/X13SAM/x13sam_V1.0.zip', ...
                     'https://www.census.gov/ts/TSMS/X13SAM/x13samdoc.pdf'}, ...
        'dir',      {'x13sam','x13sam\img',[]}, ...
        'files',    {'X13Sam.exe X13SamDoc.html', ...
                     ['AddSpec.png CommentIn.png CommentSpec.png ', ...
                     'EditArgs.png FileArgs.png RemoveSpec.png ', ...
                     'VariableArgs.png X13SAM.png'], ...
                     'x13samdoc.pdf'}, ...
        'loc',      {'tools\x13sam','tools\x13sam\img','doc'});

    toc = struct( ...
        'x13prog'    , x13prog,     ...
        'x13proghtml', x13proghtml, ...
        'x13doc'     , x13doc,      ...
        'x13dochtml' , x13dochtml,  ...
        'x12diag'    , x12diag,     ...
        'x12_64'     , x12_64,      ...
        'x12_32'     , x12_32,      ...
        'x12doc'     , x12doc,      ...
        'x11'        , x11,         ...
        'genhol'     , genhol,      ...
        'x13graph'   , x13graph,    ...
        'x13data'    , x13data,     ...
        'cnv'        , cnv,         ...
        'sam'        , sam);
    
    % parse arguments
    legal = fieldnames(toc);
    if nargin == 0              % install everything in that case
        varargin = legal(1:8);  % all up to x12doc
    elseif ismember('all',varargin)
        varargin = legal;       % all, incl x11 ... sam
    end
    
    % work through arguments
    success = [];
    while ~isempty(varargin)
        
        validstr = validatestring(varargin{1},legal);

        for f = 1:numel(toc.(validstr));
            source   = toc.(validstr)(f).source;
            url      = toc.(validstr)(f).url;
            folder   = toc.(validstr)(f).dir;
            files    = toc.(validstr)(f).files;
            loc      = toc.(validstr)(f).loc;
            thefiles = strsplit(files);
            success(end+1) = InstallMissingPiece( ...
                source,url,folder,thefiles,loc); %#ok<AGROW>
        end

        varargin(1) = [];
        
    end
    
    % This folder causes trouble. When running InstallMissingProgram('genhol')
    % more than once, a problem with unzipping occurs for some reason.
    p = [tempdir,'\WinGenhol\images'];
    if exist(p,'dir') == 7    % code 7 is a folder
        rmdir(p,'s');
    end
    
    if nargout == 0
        clear('success');
    end
        
function ok = InstallMissingPiece(source,url,folder,files,loc)

    td = tempdir;                           % temporary file location
    p  = fileparts(mfilename('fullpath'));	% get direcory of this file
    p  = [p,'\'];
    
    % download
    [~,fname,fext] = fileparts(url);
    % - tell user what we are doing
    fprintf(' Downloading ''%s'' from %s website ... ', ...
        [fname,fext], source);
    fname = fullfile(td,[fname,fext]);
    ok = true;
    try
        websave(fname,url);
    catch
        try
            if exist(fname,'file') == 2
                delete(fname);
            end
            [~, ok] = urlwrite(url,fname);
            if ~ok
                fprintf('\n');
                warning('X13TBX:InstallMissingCensusProgram:DownloadFailed', ...
                    'Download from url ''%s'' failed.', url);
            end
        catch err
            fprintf('\n');
            warning('X13TBX:InstallMissingCensusProgram:FileAccessFailure', ...
                ['%s\n%s\nCannot access the file "%s". It is possible that ', ...
                'the download from the web was faulty. Or maybe the file ', ...
                'exists but is write protected, or it is already opened ', ...
                'by another program.'], ...
                err.identifier, err.message, fname);
            ok = false;
        end
    end

    % unzip
    if ok
        [~,~,fext] = fileparts(fname);
        if strcmp(fext,'.zip')
            try
                unzip(fname,td);
            catch err
                fprintf('\n');
                warning('X13TBX:InstallMissingCensusProgram:UnzipFailed', ...
                    'Downloaded archive ''%s'' could not be unzipped.\n%s', ...
                    fname, err.message);
                ok = false;
            end
        end
        if ~isempty(folder)
            folder = [td,folder,'\'];
        else
            folder = td;
        end
    end
    
    % copy to correct location
    if ok
        for f = 1:numel(files)
            source      = fullfile(folder,files{f});
            destination = [p,loc,'\'];
            % create destination directory if it does not yet exist
            if exist(destination,'file') ~= 7
                % ... code 7 refers to directory
                mkdir(destination);
            end
            % copy file from source to destination
            [thisfileok,msg] = copyfile(source,destination,'f');
            if ~thisfileok
                fprintf('\n');
                warning('X13TBX:InstallMissingCensusProgram:CopyFailed', ...
                    ['File ''%s'' could not be copied to correct ', ...
                    'location.\n%s'], files{f}, msg);
                ok = false;
            end
        end
    end

    % inform user that installation was successful
    if ok
        fprintf('success.\n');
    end
