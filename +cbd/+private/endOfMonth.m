function date = endOfMonth(year, month)
%ENDOFMONTH returns the last day of the month as a serial date
%
% USAGE
%   date = endOfMonth(d1) returns last day of month for serial date d1
%   date = endOfMonth(y1, m1) retuns last day of month for the given
%   year-month year
%
% David Kelley, 2015 with inspiration from TMW.

if nargin == 1
    % If only one input argument then it is a single date 
    [year1, month1] = datevec(year);
    date = cbd.private.endOfMonth(year1, month1);
    return
end

if length(year) == 1 && length(month) ~= 1
    year = year(ones(size(month)));
end

if length(month) == 1 && length(year) ~= 1
    month = month(ones(size(year)));
end

assert(length(month) == length(year), ...
    'endOfMonth:unevenDateVec', ...
    'Input vectors of uneven length');

lastD = lastDay(year, month);
date = datenum(year, month, lastD);

end

function day = lastDay(y, m)
% returns the day of the last date in a month given year and month

lastDayOfMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]';

day = zeros(size(y));

day(:) = lastDayOfMonth(m);
day((m == 2) & ...
    ((rem(y, 4) == 0 & rem(y, 100) ~= 0) | ...
    rem(y, 400) == 0)) = 29;

end
