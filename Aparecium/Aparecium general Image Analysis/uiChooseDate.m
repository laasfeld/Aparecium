function varargout = uiChooseDate(varargin)
%UICALENDAR Graphical Calendar
%   UICALENDAR is a customizable graphical calendar that interfaces with
%   uicontrols. UICALENDAR populates uicontrols with user selected dates.
%
%   uicalendar('PARAM1', VALUE1, 'PARAM2', VALUE2', ...)
%
%   Inputs:
%   Parameter          - Value        : Description
%   ---------------------------------------------------------------------------
%   'BusDays'          - 0            : (Default) Standard calendar without
%                                       non-busniess day indicators.
%
%                        1            : Marks NYSE non-business days in red.
%
%   'BusDaySelect'     - 0            : Only allow selection of business days.
%                                       Non-business days are determined from
%                                       the following parameters:
%
%                                       'BusDays'
%                                       'Holiday'
%                                       'Weekend'
%
%                        1            : (Default) Allows selections of
%                                       business and non-business days.
%
%   'DateBoxColor'     - [date R G B] : Sets the color of the date squares to
%                                       the specified [R G B] color.
%
%   'DateStrColor'     - [date R G B] : Sets the color of the numeric date
%                                       number in the date square to the
%                                       specified [R G B] color.
%
%   'DestinationUI'    - H            : Scalar or vector of the destination
%                                       object's handles. The default UI
%                                       property that is populated with the
%                                       date(s) is 'string'.
%
%                        {H, {Prop}}  : Cell array of handles and the
%                                       destination object's UI properties. H
%                                       must be a scalar or vector and 'Prop'
%                                       must be a single property string or a
%                                       cell array of property strings.
%
%   'Holiday'          - Dates        : Sets the specified holiday dates into
%                                       the calendar. The corresponding date
%                                       string of the holiday will appear Red.
%                                       The Date(s) must be a scalar or vector
%                                       of datenums.
%
%   'InitDate'         - Datenum      : Numeric date value specifying the
%                                       initial start date when the calendar is
%                                       initialized. The default date is TODAY.
%
%                        Datestr      : Date string value specifying the initial
%                                       start date when the calendar is
%                                       initialized. Datestr must include a
%                                       Year, Month, and Day (i.e. 01-Jan-2006).
%
%   'InputDateFormat'  - Format       : Sets the format of initial start date,
%                                       InitDate. See 'hep datestr' for date
%                                       format values.
%
%   'OutputDateFormat' - Format       : Sets the format of output date string.
%                                       See 'help datestr' for date format
%                                       values.
%
%   'OutputDateStyle'  - 0            : (Default) Returns a single date string
%                                       or a cell array (row) of date strings.
%                                       i.e. {'01-Jan-2001, 02-Jan-2001, ...'}
%
%                        1            : Returns a single date string or a cell
%                                       (column) array of date strings.
%                                       i.e. {'01-Jan-2001; 02-Jan-2001; ...'}
%
%                        2            : Returns a string representation of a
%                                       row vector of datenums.
%                                       i.e. '[732758, 732759, 732760, 732761]'
%
%                        3            : Returns a string representation of a
%                                       column vector of datenums.
%                                       i.e. '[732758; 732759; 732760; 732761]'
%
%   'SelectionType'    - 0            : Allows multiple date selections.
%
%                        1            : (Default) Allows only a single date selection.
%
%   'Weekend'          - DayOfWeek    : Sets the specified days of the week as
%                                       weekend days. Weekend days are marked
%                                       in red.
%
%                                       DayOfWeek can be a vector containing
%                                       the following numeric values:
%
%                                       1 - Sunday
%                                       2 - Monday
%                                       3 - Tuesday
%                                       4 - Wednesday
%                                       5 - Thursday
%                                       6 - Friday
%                                       7 - Saturday
%
%                                       or a vector of length 7 containing 0's
%                                       and 1's. The value 1 indicates a
%                                       weekend day. The first element of this
%                                       vector corresponds to Sunday.
%
%                                       For example, when Saturday and Sunday
%                                       are weekend days then
%                                       WEEKEND = [1 0 0 0 0 0 1].
%
%   'WindowStyle'      - Normal       : (Default) Standard figure properties.
%
%                        Modal        : Modal figures remain stacked above all
%                                       normal figures and the MATLAB command
%                                       window.
%
%   Example:
%      Create a uicontrol:
%      textH1 = uicontrol('style', 'edit', 'position', [10 10 100 20]);
%
%      Call UICALENDAR:
%      uicalendar('DestinationUI', {textH1, 'string'})
%
%      Select a date and press 'OK'.

% Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1.6.9 $   $Date: 2008/03/28 15:22:07 $

% Default
paramNames = {'BusDays'; 'BusDaySelect'; 'DateBoxColor'; 'DateStrColor'; ...
   'DestinationUI'; 'Holiday'; 'InitDate'; 'InputDateFormat'; ...
   'OutputDateFormat'; 'OutputDateStyle'; 'SelectionType'; 'Weekend'; ...
   'WindowStyle'};

[paramValStruct, msg] = validateparams(nargin, varargin, paramNames);
if ~isempty(msg)
   error('finance:caldendargui:invalidParamPair', msg)
end

h.defUIColor = get(0, 'defaultuicontrolbackgroundcolor');

% See if any guis are open.
findfig = findall(0, 'Type', 'figure', 'tag', 'UICalendar');

if ~isempty(findfig)
   % Bring forward this gui
   fig = figure(findfig);

   % Get this guis handles
   h = getappdata(fig, 'handles');

   % Initialize parameters
   setinitializations(h, paramValStruct);

else
   % Default position
   pos = [300 290 230 290];

   % Create figure and set optionssssssss
   h.hfig = figure('tag', 'UICalendar', ...
      'name', 'UICalendar', ...
      'visible', 'off', ...
      'menubar', 'none', ...
      'numbertitle', 'off', ...
      'position', pos, ...
      'color', h.defUIColor, ...
      'resize', 'off', ...
      'dockcontrols', 'off', ...
      'windowstyle', paramValStruct.windowStyle, ...
      'DoubleBuffer', 'on');

   % Center gui
   movegui(h.hfig, 'center')

   % Populate main gui
   h = group_panelsandcontainers(h);
   h = group_my(h);
   h = group_days(h);
   h = group_buttons(h);
   h = group_south(h);

   % Initialize parameters
   setinitializations(h, paramValStruct);

   % Set callbacks/listeners
   setcallbacks(h);

   % Set this gui's handles into the appdata for this gui
   setappdata(h.hfig, 'handles', h)

   % Turn everything on
   set(h.hfig, 'visible', 'on');

   % Normalize fig/uicontrols. Remove first 3 elements b/c they refer to
   % color.
   newH = convert2vector(h);
   set(newH(4:end), 'units', 'norm');

   % Dont lose control of figure
   set(h.hfig, 'handlevisibility', 'off');
end

% Pass out handles only when requested
%   h.hfig    = figure handle
%   h         = figure handle and all uicontrol handles
if nargout
   varargout = {h.hfig, h};
end


% -------------------------------------------------------------------------
% Initialize uicontrols (BEGIN)
% -------------------------------------------------------------------------
function setinitializations(h, paramValStruct)
% Initialize uicontrols within panels

% Save paramValStruct into appdata
setappdata(h.hfig, 'paramValStruct', paramValStruct)

% Initialize current selected and previous selected squares
setappdata(h.hfig, 'currentSelectedSquare', [])
setappdata(h.hfig, 'previousSelectedSquare', [])

% --------------------------
% Set the starting date. Either user specified or TODAY
initializestartdate(h, paramValStruct)

% --------------------------
% Set the popups to the current month and year
initializepopups(h)

% --------------------------
% Set the dates into the calendar
paramValStruct = getappdata(h.hfig, 'paramValStruct');
setcalendardate(h, paramValStruct)



% -------------------------------------------------------------------------
% Initialize uicontrols (END)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Panels/Containers (BEGIN)
% -------------------------------------------------------------------------
function h = group_panelsandcontainers(h)
% Create panels for each section of the gui

h.panelmyselector = uipanel('parent', h.hfig, 'units', 'pixels', ...
   'position', [10 260 210 30], ...
   'backgroundcolor', h.defUIColor, ...
   'visible', 'on', ...
   'bordertype', 'none', ...
   'tag', 'paneldateselector');

h.paneldayofweek = uipanel('parent', h.hfig, 'units', 'pixels', ...
   'position', [10 220 210 30], ...
   'backgroundcolor', h.defUIColor, ...
   'visible', 'on', ...
   'bordertype', 'line', ...
   'tag', 'paneldayofweek');

h.panelbuttons = uipanel('parent', h.hfig, 'units', 'pixels', ...
   'position', [10 40 210 180], ...
   'backgroundcolor', h.defUIColor, ...
   'visible', 'on', ...
   'bordertype', 'line', ...
   'tag', 'panelbuttons');

h.panelsouth = uipanel('parent', h.hfig, 'units', 'pixels', ...
   'position', [10 10 210 20], ...
   'backgroundcolor', h.defUIColor, ...
   'visible', 'on', ...
   'bordertype', 'none', ...
   'tag', 'panelsouth');
% -------------------------------------------------------------------------
% Panels/Containers (END)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Callbacks (BEGIN)
% -------------------------------------------------------------------------
function setcallbacks(h)
% Set callbacks for uicontrols

% General Callbacks
set(h.monthpopup,       'callback', {@monthpopup_cb, h});
set(h.yearpopup,        'callback', {@yearpopup_cb, h});
set(h.nextmonthbtn,     'callback', {@nextmonthbtn_cb, h});
set(h.prevmonthbtn,     'callback', {@prevmonthbtn_cb, h});
set(h.acceptbtn,        'callback', {@acceptbtn_cb, h});
set(h.clearbtn,         'callback', {@clearbtn_cb, h});
set(h.cancelbtn,        'callback', {@cancelbtn_cb, h});

% Button down function callbacks
for idx = 1:42
   set(h.daysquarestextobj{idx},   'Buttondownfcn', {@daysquarestextobj_cb, h});
end

% -------------------------------------------------------------------------
% Callbacks (END)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Month/Year group (BEGIN)
% -------------------------------------------------------------------------
function h = group_my(h)
% Create pushbuttons and dropdown menus for selecting months and years.

% Generate years
yearNumVector = (1896:year(today)+1000);
yearStrVector = strrep(num2str(yearNumVector), '  ', '|');

setappdata(h.hfig, 'yearSpan', yearNumVector)

[rCdata, lCdata] = getarrowcdata;

h.prevmonthbtn = uicontrol('parent', h.panelmyselector, ...
   'style', 'pushbutton', ...
   'horizontalalignment', 'center', ...
   'cdata', lCdata, ...
   'position', [2 0 20 20], ...
   'visible', 'on', ...
   'tooltipstring', 'Previous month', ...
   'tag', 'prevmonthbtn');

h.monthpopup = uicontrol('parent', h.panelmyselector, ...
   'style', 'popup', ...
   'string', ['January|February|March|April|May|June|July|August|September|', ...
   'October|November|December'], ...
   'position', [30 0 75 20], ...
   'visible', 'on', ...
   'backgroundcolor', 'w', ...
   'tooltipstring', 'Select month', ...
   'tag', 'monthpopup');

h.yearpopup = uicontrol('parent', h.panelmyselector, ...
   'style', 'popup', ...
   'string', yearStrVector, ...
   'position', [110 0 74 20], ...
   'visible', 'on', ...
   'backgroundcolor', 'w', ...
   'tooltipstring', 'Select year', ...
   'tag', 'yearpopup');

h.nextmonthbtn = uicontrol('parent', h.panelmyselector, ...
   'style', 'pushbutton', ...
   'horizontalalignment', 'center', ...
   'cdata', rCdata, ...
   'position', [190 0 20 20], ...
   'visible', 'on', ...
   'tooltipstring', 'Next month', ...
   'tag', 'nextmonthbtn');
% -------------------------------------------------------------------------
% Month/Year group (END)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Day headers group (BEGIN)
% -------------------------------------------------------------------------
function h = group_days(h)
% Create the uicontainers for each day header.

% Create an array of 'buttons' for each day's heading
h.buttonheaders = cell(1, 42);
h.buttonheaderstextobj = cell(1, 42);

% Headers
%headers = {'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'};
headers = {'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'};

panelWidth = -30;
for idy = 1:7
   panelWidth = panelWidth + 30;
   h.buttonheaders{idy} = uipanel('parent', h.paneldayofweek, 'units', 'pixels', ...
      'position', [panelWidth 0 30 30], ...
      'bordertype', 'line', ...
      'backgroundcolor', h.defUIColor, ...
      'visible', 'on', ...
      'tag', 'buttonheaders');

   h.buttonheaderstextobj{idy} = uicontrol('parent', h.buttonheaders{idy}, ...
      'style', 'text', ...
      'string', headers{idy}, ...
      'HorizontalAlignment', 'center', ...
      'position', [1 1 27 27], ...
      'visible', 'on', ...
      'enable', 'on', ...
      'tag', 'buttonheaderstextobj');

   %'string', sprintf(['\n', headers{idy}]), ...
end
% -------------------------------------------------------------------------
% Day headers group (END)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Buttons group (BEGIN)
% -------------------------------------------------------------------------
function h = group_buttons(h)
% Create the uicontainers for each day of the month.

% Create an array of 'buttons' for each day
h.daysquares = cell(1, 42);
h.daysquarestextobj = cell(1, 42);
count = 0;

for idx = 1:6
   if idx == 1
      panelHeight = 150;

   else
      panelHeight = 180-(30*idx);
   end

   for idy = 1:7
      count = count + 1;
      panelWidth = (idy-1)*30;

      h.daysquares{count} = uipanel('parent', h.panelbuttons, 'units', 'pixels', ...
         'position', [panelWidth panelHeight 30 30], ...
         'bordertype', 'line', ...
         'backgroundcolor', h.defUIColor, ...
         'visible', 'on', ...
         'tag', 'daysquares');

      h.daysquarestextobj{count} = uicontrol('parent', h.daysquares{count}, ...
         'style', 'text', ...
         'HorizontalAlignment', 'right', ...
         'enable', 'inactive', ...
         'position', [4 4 22 22], ...
         'backgroundcolor', h.defUIColor, ...
         'visible', 'on', ...
         'tag', 'daysquarestextobj');
   end
end
% -------------------------------------------------------------------------
% Buttons group (END)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% South (BEGIN)
% -------------------------------------------------------------------------
function h = group_south(h)
% Create an accept button

h.clearbtn = uicontrol('parent', h.panelsouth, ...
   'style', 'pushbutton', ...
   'horizontalalignment', 'center', ...
   'string', 'Clear all', ...
   'position', [1 0 50 20], ...
   'visible', 'on', ...
   'tooltipstring', 'Clear all selected dates', ...
   'tag', 'clearbtn');

h.acceptbtn = uicontrol('parent', h.panelsouth, ...
   'style', 'pushbutton', ...
   'horizontalalignment', 'center', ...
   'string', 'OK', ...
   'position', [103 0 50 20], ...
   'visible', 'on', ...
   'tooltipstring', 'Export selected dates to DestinationUI', ...
   'tag', 'acceptbtn');

h.cancelbtn = uicontrol('parent', h.panelsouth, ...
   'style', 'pushbutton', ...
   'horizontalalignment', 'center', ...
   'string', 'Cancel', ...
   'position', [160 0 50 20], ...
   'visible', 'on', ...
   'tooltipstring', 'Cancel and close UICalendar', ...
   'tag', 'cancelbtn');
% -------------------------------------------------------------------------
% South (BEGIN)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Uicontextmenu (BEGIN)
% -------------------------------------------------------------------------
% function u = group_uicontextmenu(h)
% Create the uicontextmenu's.

% % Create context menu
% cmenu = uicontextmenu;
%
% u.uicontextstartdate = uimenu(cmenu, 'Label', 'Start Date:', ...
%     'tag', 'uicontextstartdate');
% u.uicontextenddate = uimenu(cmenu, 'Label', 'End Date:', ...
%     'tag', 'uicontextenddate');
%
% % Set into appdata
% setappdata(h.hfig, 'uicontextmenuH', u)
% -------------------------------------------------------------------------
% Uicontextmenu (END)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Subfunctions/Callbacks (BEGIN)
% -------------------------------------------------------------------------
function monthpopup_cb(hcbo, eventStruct, h) %#ok
% Repopulate the calendar with data

% Set the calendar
paramValStruct = getappdata(h.hfig, 'paramValStruct');
setcalendardate(h, paramValStruct)


% ------------------------------------------------
function yearpopup_cb(hcbo, eventStruct, h) %#ok
% Repopulate the calendar with data

% Set the calendar
paramValStruct = getappdata(h.hfig, 'paramValStruct');
setcalendardate(h, paramValStruct)


% ------------------------------------------------
function nextmonthbtn_cb(hcbo, eventStruct, h) %#ok
% Repopulate the calendar with data

% Get the month and year
[m, y, yVal, yearSpan] = getpage(h); %#ok

% Get the next month and year
if m+1 > 12
   m = 1;

   yVal = yVal+1;

else
   m = m+1;
end

if yVal > numel(yearSpan)
   ed = errordlg('The year is out of range of acceptable values.', ...
      'UICalendar Error', 'modal'); %#ok
   return

else
   set(h.monthpopup, 'value', m)
   set(h.yearpopup, 'value', yVal)
end

% Set the calendar
paramValStruct = getappdata(h.hfig, 'paramValStruct');
setcalendardate(h, paramValStruct)


% ------------------------------------------------
function prevmonthbtn_cb(hcbo, eventStruct, h) %#ok
% Repopulate the calendar with data

% Get the month and year
[m, y, yVal] = getpage(h); %#ok

% Get the previous month and year
if m-1 <= 0
   m = 12;

   yVal = yVal-1;

else
   m = m-1;
end

if yVal < 1
   ed = errordlg('The year is out of range of acceptable values.', ...
      'UICalendar Error', 'modal'); %#ok
   return

else
   set(h.monthpopup, 'value', m)
   set(h.yearpopup, 'value', yVal)
end

% Set the calendar
paramValStruct = getappdata(h.hfig, 'paramValStruct');
setcalendardate(h, paramValStruct)


% ------------------------------------------------
function cancelbtn_cb(hcbo, eventStruct, h) %#ok
% Exit out of uicalendar

% Close figure
delete(h.hfig)


% ------------------------------------------------
function daysquarestextobj_cb(hcbo, eventStruct, h) %#ok
% Day squares callback. Highlight or Unhighlight the text object with a
% left click only.

clkType = get(h.hfig, 'SelectionType');

% normal - single click  : single highlight
% open   - double click  : single highlight (possible future enhancement)
% extend - shift + click : multi-highlight (span dates)
% alt    - right click   : reserved for context menus
switch clkType
   case {'normal', 'open'}
      % Highlight/unhighlight the current user selection
      setsingleselectionhilite(h, hcbo)

   case {'extend'}
      % Shift + click
      % This will select a range of dates between the previous selected date
      % and the most recently selected date. Do not allow this option for
      % single selection type.

      % Highlight/unhighlight the current user selection
      setsingleselectionhilite(h, hcbo)

      % Do not continue if an error dlg appears. We need this here
      % because setsingleselectionhilite generates the errordlg.
      finddlg = findall(0, 'Type', 'figure', 'name', 'UICalendar Error');
      if ishandle(finddlg)
         return
      end

      % Get current selected square
      d = str2double(get(hcbo, 'string'));
      [m, y] = getpage(h);

      % Get the min of the current and previous selected dates
      currDatenum = datenum([y, m d]);

      previousSelectedSquare = getappdata(h.hfig, 'previousSelectedSquare');
      paramValStruct = getappdata(h.hfig, 'paramValStruct');
      if ~isempty(previousSelectedSquare)
         prevDatenum = datenum(previousSelectedSquare(2:4));

         minMax = [currDatenum, prevDatenum];
         [minDate, minDateIdx] = min(minMax);
         if minDateIdx == 1
            maxDateIdx = 2;

         else
            maxDateIdx = 1;
         end

         % ONLY multi-select the dates if both the current and previous
         % selected dates are actually selected (i.e. colored in blue)
         % Update the appdata to contain only minDate - current selected
         % date as highlighted.
         currSelectBKGColor = get(get(hcbo, 'parent'), 'backgroundcolor');
         prevSelectBKGColor = previousSelectedSquare(5:7);

         if all(currSelectBKGColor == [0 .5 1]) && ...
               all(prevSelectBKGColor == [0 .5 1]) && ...
               paramValStruct.selType == 0
            dateSpan = minDate:minMax(maxDateIdx);

            % Drop the first and last date because they will be
            % duplicates. They were entered into appdata in the call to
            % setsingleselectionhilite above.
            dateSpan = dateSpan(2:end-1);

         else
            dateSpan = [];
         end

      else
         currSelectBKGColor = get(get(hcbo, 'parent'), 'backgroundcolor');
         dateSpan = [];
      end

      % Rehighlight the date if it is deslected.
      if ~all(currSelectBKGColor == [0 .5 1])
         setsingleselectionhilite(h, hcbo)
      end

      % Check for business day selection only
      if paramValStruct.busSelect == 0
         [outputDate, marketClosureDates] = filterdays(h, hcbo); %#ok

         % Remove any non-business days from datespan
         collisionIdx = [];
         for idx = 1:numel(dateSpan)
            collision = dateSpan(idx) == marketClosureDates;
            if any(collision)
               collisionIdx = [collisionIdx; idx]; %#ok
            end
         end
         dateSpan(collisionIdx) = [];
      end


      % Get the date components of the date span.
      [y, m, d] = datevec(dateSpan);

      % Store the newly selected dateSpan into the selected dates
      % contanier.
      selectedSquares = getappdata(h.hfig, 'selectedSquares');
      for idx = 1:numel(y)
         if isempty(selectedSquares.date)
            selectedSquares.date = [m(idx), y(idx)];
            selectedSquares.day{1} = d(idx);

            [fullPage, currMonth, numPrevDays] = getdates(y(idx), m(idx)); %#ok
            selectedSquares.idx{1} = numPrevDays+d(idx);

         else
            mIdx = m(idx) == selectedSquares.date(:, 1);
            yIdx = y(idx) == selectedSquares.date(:, 2);

            idxSum = mIdx + yIdx;
            pageIdx = find(idxSum == 2, 1);

            if ~isempty(pageIdx)
               % Use existing y, m storage container
               selectedSquares.day{pageIdx} = [selectedSquares.day{pageIdx}, d(idx)];

               [fullPage, currMonth, numPrevDays] = getdates(y(idx), m(idx)); %#ok
               selectedSquares.idx{pageIdx} = [selectedSquares.idx{pageIdx}, numPrevDays+d(idx)];

            else
               % Start a new y, m storeage container
               selectedSquares.date = [selectedSquares.date; m(idx), y(idx)];

               newPageCount = size(selectedSquares.date, 1);

               selectedSquares.day{newPageCount} = d(idx);

               [fullPage, currMonth, numPrevDays] = getdates(y(idx), m(idx)); %#ok
               selectedSquares.idx{newPageCount} = numPrevDays+d(idx);
            end
         end
      end

      % Save the new data into userdata
      setappdata(h.hfig, 'selectedSquares', selectedSquares)

      % Set all the highlights
      setuserhilites(h)

   otherwise
      % Do nothing
end


% ------------------------------------------------
function clearbtn_cb(hcbo, eventStruct, h) %#ok
% Clear all selected dates

% Reset selected dates container
selectedSquares.date = [];
selectedSquares.idx{1} = [];
selectedSquares.day{1} = [];

setappdata(h.hfig, 'selectedSquares', selectedSquares)

% Unhighlight
paramValStruct = getappdata(h.hfig, 'paramValStruct');
setcalendardate(h, paramValStruct)

% Reset current and previous selected squares
setappdata(h.hfig, 'currentSelectedSquare', [])
setappdata(h.hfig, 'previousSelectedSquare', [])


% ------------------------------------------------
function acceptbtn_cb(hcbo, eventStruct, h) %#ok
% Accept button callback

% Get the year month and day and construct a date output
paramValStruct = getappdata(h.hfig, 'paramValStruct');

% Get all the selected dates
dates = selecteddates(h);

% Generate the output dates
sorteDatenum = sort(dates);
if isempty(paramValStruct.outDateFmt)
   % Use default MATLAB format
   try
      if paramValStruct.outDateStyl
         % Double vector
         outDates = sorteDatenum;

      else
         % Char array
         outDates = datestr(sorteDatenum);
      end

   catch E
      ed = errordlg(E.message, 'UICalendar Error', 'modal'); %#ok
      return
   end

else
   % Use user supplied date format
   try
      if any(paramValStruct.outDateStyl == [2 3])
         % Double vector
         outDates = sorteDatenum;

      else
         % Char array
         outDates = datestr(sorteDatenum, paramValStruct.outDateFmt);
      end
      handles.output{3} = outDates;

   catch E
      ed = errordlg(E.message, 'UICalendar Error', 'modal'); %#ok
      return
   end
end


% Generate the output date style
numDates = size(outDates, 1);
switch paramValStruct.outDateStyl
   case {0}
      %
      % '{'date1', 'date2', 'date3', ...}'
      %

      % Returns a string representation of a row cell array of strings.
      % Create a cell array of string dates when necassary.
      if numDates > 1
         % Cell array
         hold = [];
         for idx = 1:numDates
            hold = [hold, '''', outDates(idx, :), '''', ', ']; %#ok
         end

         % Remove the last ','
         outDates = ['{', hold(1:end-2), '}'];

      else
         % Single string date
         % Do nothing to outDates
      end

   case {1}
      %
      % '{'date1'; 'date2'; 'date3'; ...}'
      %

      % Returns a string representation of a column cell array of strings.
      % Create a cell array of string dates when necassary.
      if numDates > 1
         % Cell array
         hold = [];
         for idx = 1:numDates
            hold = [hold, '''', outDates(idx, :), '''', '; ']; %#ok
         end

         % Remove the last ';'
         outDates = ['{', hold(1:end-2), '}'];

      else
         % Single string date
         % Do nothing to outDates
      end

   case {2}
      %
      % '[732758, 732759, 732760, 732761]'
      %

      % Returns a string representation of a row vector of datenums.
      if numDates > 1
         str = sprintf('%d, ', outDates');
         str(end-1:end) = [];
         str = ['[' str ']'];

         outDates = str;

      else
         % Single string date
         % Do nothing to outDates
         outDates = num2str(outDates);
      end

   case {3}
      %
      % '[732758; 732759; 732760; 732761]'
      %

      % Returns a string representation of a column vector of datenums.
      if numDates > 1
         str = sprintf('%d; ', outDates');
         str(end-1:end) = [];
         str = ['[' str ']'];

         outDates = str;

      else
         % Single string date
         % Do nothing to outDates
         outDates = num2str(outDates);
      end
end

% Set the dates into the Property of H
if isempty(paramValStruct.destUI)
   % Do nothing
   % outDates  %<------- uncomment for debug purposes

else
   % Display to UI
   numUis = numel(paramValStruct.destUI{1});
   for idx = 1:numUis
      if numUis == 1
         try
            set(paramValStruct.destUI{1}, char(paramValStruct.destUI{2}), outDates)

         catch E
            ed = errordlg(E.message, 'UICalendar Error', 'modal'); %#ok
            return
         end

      else
         try
            set(paramValStruct.destUI{1}(idx), paramValStruct.destUI{2}{idx}, outDates)

         catch E
            ed = errordlg(E.message, 'UICalendar Error', 'modal'); %#ok
            return
         end
      end
   end
end

% Close gui
delete(h.hfig)

% ------------------------------------------------
function [fullPage, currMonth, numPrevDays, numFutureDays] = getdates(y, m)
% 1) Generate the date componens from a starting date to an ending date.
% 2) Back fill or forward fill any dates from the previous month or next
%    month
%
% Inputs:
%             y - scalar year
%
%             m - scalar month
%
% Outputs:
% fullPage      - vector of [yy, mm, dd] dates for an entire page of the
%                 calendar
%
% currMonth     - vector of [yy, mm, dd] dates for the current month
%
% numPrevDays   - scalar number of the previous days
%
% numFutureDays - scalar number of the future days


% Get the last day of the month
lastDay = eomday(y, m);

% Generate a full month of days
dd = (1:lastDay)';

% Scalar expand the month and year
mm = repmat(m, size(dd));
yy = repmat(y, size(dd));

% Get the weekday of the first date of the month
% 1     Sun
% 2     Mon
% 3     Tue
% 4     Wed
% 5     Thu
% 6     Fri
% 7     Sat
[weekdayNum, weekdayStr] = weekday(datenum([yy(1), mm(1), dd(1)])); %#ok

numCurrMonthDays = numel(dd);
numExtraDays = 42 - numCurrMonthDays;
if weekdayNum == 1
   % The first date will appear in date array (1, 1) <upper left>
   % and some next month days will need to be determined
   numFutureDays = numExtraDays;
   nDD = (1:numExtraDays)';

   % Determine next month and year
   if m+1 > 12
      nm = 1;
      ny = y+1;

   else
      nm = m+1;
      ny = y;
   end

   nMM = repmat(nm, size(nDD));
   nYY = repmat(ny, size(nDD));

   % Previous dates do not exist
   numPrevDays = 0;
   pDD = [];
   pMM = [];
   pYY = [];

else
   % The frist date will appear in date array (1, weekdayNum)
   % and some previous month and next month days will need to be
   % determined

   % Previous month's days
   numPrevDays = weekdayNum - 1;

   % Determine previous month and year
   if numPrevDays ~= 0
      if m-1 <= 0
         pm = 12;
         py = y-1;

      else
         pm = m-1;
         py = y;
      end

      pmd = eomday(py, pm);
      pDD = (pmd-numPrevDays+1:pmd)';

      pMM = repmat(pm, size(pDD));
      pYY = repmat(py, size(pDD));

   else
      pDD = [];
      pMM = [];
      pYY = [];
   end

   % Next month's days
   numFutureDays = numExtraDays-(weekdayNum-1);
   nDD = (1:numFutureDays)';

   % Determine next month and year
   if ~isempty(pDD)
      if m+1 > 12
         nm = 1;
         ny = y+1;
      else
         nm = m+1;
         ny = y;
      end

      nMM = repmat(nm, size(nDD));
      nYY = repmat(ny, size(nDD));

   else
      nDD = [];
      nMM = [];
      nYY = [];
   end
end

% Create an entire page (of the calendar) of dates and current month days
fullPage = [[pYY, pMM, pDD]; [yy, mm, dd]; [nYY, nMM, nDD]];

currMonth = [yy, mm, dd];

% ------------------------------------------------
function initializestartdate(h, paramValStruct)
% Set the initialization date into the gui

% Set the current month/year
if isempty(paramValStruct.initDate)
   % Set today's date into the appdata
   [Y, MO, D] = datevec(today);
   paramValStruct.initDate = [Y, MO, D];

else
   % Set the user specified date into the appdata

   % Check paramValStruct.initDate
   if isnumeric(paramValStruct.initDate)

      if numel(paramValStruct.initDate) == 3
         % Do nothing

      elseif numel(paramValStruct.initDate) == 1
         try
            if isempty(paramValStruct.inDateFmt)
               % Let MATLAB choose the best format
               paramValStruct.initDate = datevec(paramValStruct.initDate);

            else
               % Use a date format
               paramValStruct.initDate = datevec(paramValStruct.initDate, ...
                  paramValStruct.inDateFmt);
            end

         catch E
            msg = E.message;

            % Update appdata with new date
            [Y, MO, D] = datevec(today);
            paramValStruct.initDate = [Y, MO, D];
            setappdata(h.hfig, 'paramValStruct', paramValStruct)

            % Initialize page info
            selectedSquares.date = [];
            selectedSquares.idx{1} = [];
            selectedSquares.day{1} = [];
            setappdata(h.hfig, 'selectedSquares', selectedSquares);

            ed = errordlg(['Initial start date is invalid. ', msg], ...
               'UICalendar Error', 'modal'); %#ok

            return
         end

      else
         msg = 'The date input dimensions is incorrect.'; %#ok

         % Update appdata with new date
         [Y, MO, D] = datevec(today);
         paramValStruct.initDate = [Y, MO, D];
         setappdata(h.hfig, 'paramValStruct', paramValStruct)

         % Initialize page info
         selectedSquares.date = [];
         selectedSquares.idx{1} = [];
         selectedSquares.day{1} = [];
         setappdata(h.hfig, 'selectedSquares', selectedSquares);

         ed = errordlg(['Initial start date is invalid. ', msg], ...
            'UICalendar Error', 'modal'); %#ok

         return
      end

   elseif ischar(paramValStruct.initDate)
      try
         if isempty(paramValStruct.inDateFmt)
            % Let MATLAB choose the best format
            paramValStruct.initDate = datevec(paramValStruct.initDate);

         else
            % Use a date format
            paramValStruct.initDate = datevec(paramValStruct.initDate, ...
               paramValStruct.inDateFmt);
         end

      catch E
         msg = E.message;

         % Update appdata with new date
         [Y, MO, D] = datevec(today);
         paramValStruct.initDate = [Y, MO, D];
         setappdata(h.hfig, 'paramValStruct', paramValStruct)

         % Initialize page info
         selectedSquares.date = [];
         selectedSquares.idx{1} = [];
         selectedSquares.day{1} = [];
         setappdata(h.hfig, 'selectedSquares', selectedSquares);

         ed = errordlg(['Initial start date is invalid. ', msg], ...
            'UICalendar Error', 'modal'); %#ok

         return
      end

   else
      msg = 'The date input dimensions is incorrect.'; %#ok

      % Update appdata with new date
      [Y, MO, D] = datevec(today);
      paramValStruct.initDate = [Y, MO, D];
      setappdata(h.hfig, 'paramValStruct', paramValStruct)

      % Initialize page info
      selectedSquares.date = [];
      selectedSquares.idx{1} = [];
      selectedSquares.day{1} = [];
      setappdata(h.hfig, 'selectedSquares', selectedSquares);

      ed = errordlg(['Initial start date is invalid. ', msg], ...
         'UICalendar Error', 'modal'); %#ok

      return
   end
end

% Update appdata with new date
setappdata(h.hfig, 'paramValStruct', paramValStruct)

% Initialize page info
selectedSquares.date = [];
selectedSquares.idx{1} = [];
selectedSquares.day{1} = [];
setappdata(h.hfig, 'selectedSquares', selectedSquares);


% ------------------------------------------------
function initializepopups(h)
% Set the popups to the current month and year

% Get today's date
paramValStruct = getappdata(h.hfig, 'paramValStruct');

yearSpan = getappdata(h.hfig, 'yearSpan');
yLoc = find(yearSpan == paramValStruct.initDate(1));

if isempty(yLoc)
   ed = errordlg('The year is out of range of acceptable values.', ...
      'UICalendar Error', 'modal'); %#ok
   return
end

% Set the popups to the current month and year
set(h.monthpopup, 'value', paramValStruct.initDate(2));
set(h.yearpopup, 'value', yLoc);


% ------------------------------------------------
function setcalendardate(h, paramValStruct)
% Set the specified month's dates into the calendar

% Get the month and year from the popups. These may have changed if the
% user selected diff values.
[m, y] = getpage(h);

% Generate the current calender days
[fullPage, currMonth, numPrevDays, numFutureDays] = getdates(y, m);  %#ok


% Set the data into appdata for other purposes
setappdata(h.hfig, 'fullPage', fullPage)
setappdata(h.hfig, 'currMonth', currMonth)
setappdata(h.hfig, 'numPrevDays', numPrevDays)
setappdata(h.hfig, 'numFutureDays', numFutureDays)

% Set the dates into the calendar. Make sure that all options are set to
% defaults. Any changes to the objects in the uipanels should be done in
% other callbacks.
for idx = 1:42
   set(h.daysquarestextobj{idx}, 'string', fullPage(idx, 3), 'enable', 'inactive', ...
      'background', h.defUIColor, 'foregroundcolor', 'k', 'fontweight', 'normal')

   set(h.daysquares{idx}, 'backgroundcolor', h.defUIColor)
end

% Set the previous and future dates enable to off.
for idx2 = 1:numPrevDays
   set(h.daysquarestextobj{idx2}, 'enable', 'off')
end

for idx3 = 42-numFutureDays+1:42
   set(h.daysquarestextobj{idx3}, 'enable', 'off')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD CALENADAR MOFDIFICATION ROUTINES BELOW %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set today's date as yellow if it exits in this month
settodayshilite(h)

% Check if any dates in the specified month should be highlighted
setuserhilites(h)

% Set NYSE busdays
setbusdays(h, paramValStruct.bValue)

% Set the user specified box string colors
setdateboxcolor(h, paramValStruct)

% Set the user specified date string colors
setdatestringcolor(h, paramValStruct)

% Set the user specified holidays
setholidays(h, paramValStruct);

% Set the user specified weekend days
setweekend(h, paramValStruct)


% ------------------------------------------------
function settodayshilite(h)
% Set the today's date into the date array.

% Get today's date
paramValStruct = getappdata(h.hfig, 'paramValStruct');

% If the current month/year are correct, display the current date as yellow.
numPrevDays = getappdata(h.hfig, 'numPrevDays');
if isempty(numPrevDays)
   numPrevDays = 0;
end

currMonth = get(h.monthpopup, 'value');

[m, currYear] = getpage(h); %#ok

if currMonth == paramValStruct.initDate(2) && currYear == paramValStruct.initDate(1)
   set(h.daysquarestextobj{paramValStruct.initDate(3) + numPrevDays}, ...
      'backgroundcolor', 'y', 'tooltip', 'Today''s date')
end


% ------------------------------------------------
function setsingleselectionhilite(h, hcbo)
% Highlight/unhighlight the current user selection
%
% Input:
%    h - handles
% hcbo - selected date's handle

% Single and double click
selectedSquares = getappdata(h.hfig, 'selectedSquares');

% Get selection type
paramValStruct = getappdata(h.hfig, 'paramValStruct');

% Add/remove entries in selectedSquares. This will store the user specified
% highlights.
[m, y] = getpage(h);

if ~isempty(selectedSquares.date)
   mIdx = m == selectedSquares.date(:, 1);
   yIdx = y == selectedSquares.date(:, 2);

   idxSum = mIdx + yIdx;
   pageIdx = find(idxSum == 2, 1);

   if isempty(pageIdx)
      % Set new page index
      pageIdx = numel(selectedSquares.idx) + 1; %#ok

      % New year/month page, create new entry.
      selectedSquares.date = [selectedSquares.date; [m, y]];
      selectedSquares.idx{pageIdx} = [];
      selectedSquares.day{pageIdx} = [];
   end

else
   % Set new page index
   pageIdx = 1;

   % Intitialize empty
   selectedSquares.date = [m, y];
   selectedSquares.idx{1} = [];
   selectedSquares.day{1} = [];
end
setappdata(h.hfig, 'selectedSquares', selectedSquares)

% Get the selected text objects index in the date array.
[hcboIdx, hcboParentH] = hcboidx(h, hcbo);
hcboDay = str2double(get(hcbo, 'string'));

% Check for business day selection only
if paramValStruct.busSelect == 0
   [outputDate, marketClosureDates, errMsg] = filterdays(h, hcbo); %#ok
   if ~isempty(errMsg)
      ed = errordlg(errMsg, ...
         'UICalendar Error', 'modal'); %#ok
      return
   end
end

% Allow for multiple date selection
defaultGuiColor = get(0, 'defaultuicontrolbackgroundcolor');
if paramValStruct.selType
   % Single date selection

   % Unhighlight other dates
   selectedSquares = getappdata(h.hfig, 'selectedSquares');

   % Set the color to blue if it isnt.
   currColor = get(hcboParentH, 'backgroundcolor');
   enableState = get(hcbo, 'enable');
   if all(currColor == defaultGuiColor) && strcmpi(enableState, 'inactive')
      % Highlight
      set(hcboParentH, 'backgroundcolor', [0 0.5 1])

      % Unhighlight any highlighted dates
      [m, y] = getpage(h);
      if ~isempty(selectedSquares.idx{1})
         set(h.daysquares{selectedSquares.idx{1}}, 'backgroundcolor', h.defUIColor)
      end

      % Overwrite stored info with newly highlighted info
      selectedSquares.date = [m, y];
      selectedSquares.idx = []; % Clear extra empties
      selectedSquares.idx{1} = hcboIdx;
      selectedSquares.day = []; % Clear extra empties
      selectedSquares.day{1} = hcboDay;

   elseif all(currColor == [0 0.5 1])
      % Unhightlight
      set(hcboParentH, 'backgroundcolor', h.defUIColor)

      % Remove selected square
      selectedSquares.date = [];
      selectedSquares.idx{1} = [];
      selectedSquares.day{1} = [];
   end

   % Set the selected squares into appdata
   setappdata(h.hfig, 'selectedSquares', selectedSquares)

else
   % Multiple date selection

   % Set the color to blue if it isnt.
   currColor = get(hcboParentH, 'backgroundcolor');
   enableState = get(hcbo, 'enable');
   if all(currColor == defaultGuiColor) && strcmpi(enableState, 'inactive')
      % Highlight
      set(hcboParentH, 'backgroundcolor', [0 0.5 1])

      % Add selected square
      holdIdx = selectedSquares.idx{pageIdx};
      selectedSquares.idx{pageIdx} = [holdIdx hcboIdx];

      holdDay = selectedSquares.day{pageIdx};
      selectedSquares.day{pageIdx} = [holdDay hcboDay];

   elseif all(currColor == [0 0.5 1])
      % Unhightlight
      set(hcboParentH, 'backgroundcolor', h.defUIColor)

      % Remove selected square
      rmvIdx = hcboIdx == selectedSquares.idx{pageIdx};
      selectedSquares.idx{pageIdx}(rmvIdx) = [];
      selectedSquares.day{pageIdx}(rmvIdx) = [];
   end

   % Set the selected squares into appdata
   setappdata(h.hfig, 'selectedSquares', selectedSquares)
end

% Save the current/previous selected square handles in appdata
setcurrprevselects(h, hcbo)


% ------------------------------------------------
function [hcboIdx, hcboParentH] = hcboidx(h, selectedObjH)
% Get the selected text objects' index in the date array.
%
% Inputs:
%            h - handles
% selectedObjH - text object's handle
%
% Outputs:
%      hcboIdx - selected text objects index in the date array
%  hcboParentH - parent (uipanel) of the selected txt obj

%initDate = getappdata(h.hfig, 'initDate');
numPrevDays = getappdata(h.hfig, 'numPrevDays');

hcboIdx = str2double(get(selectedObjH, 'string')) + numPrevDays;

hcboParentH = get(selectedObjH, 'parent');


% ------------------------------------------------
function [m, y, yVal, yearSpan] = getpage(h)
% Get the month and year from the popup
%
% Inputs:
%        h - handles
%
% Outputs:
%        m - month/value of month popup
%        y - year
%     yVal - value of year popup
% yearSpan - all years in popup

m = get(h.monthpopup, 'value');

yVal = get(h.yearpopup, 'value');
yearSpan = getappdata(h.hfig, 'yearSpan');
y = yearSpan(yVal);


% ------------------------------------------------
function setuserhilites(h)
% Highlight user selected (clicked) days for user specified pages. This
% gets the stored highlighted days and rehighlights them when certain pages
% are selected.

% Get the userdata
selectedSquares = getappdata(h.hfig, 'selectedSquares');

% Determine page
[m, y] = getpage(h);

if ~isempty(selectedSquares.date)
   mIdx = m == selectedSquares.date(:, 1);
   yIdx = y == selectedSquares.date(:, 2);

   idxSum = mIdx + yIdx;
   pageIdx = find(idxSum == 2, 1);

else
   pageIdx = [];
end

% Highlight user sepcified dates
if ~isempty(pageIdx)
   dateIdx = selectedSquares.idx{pageIdx};

   for idx = 1:numel(dateIdx)
      set(h.daysquares{dateIdx(idx)}, 'backgroundcolor', [0 0.5 1])
   end
end


% ------------------------------------------------
function [paramValStruct, msg] = validateparams(numargin, varargin, paramNames)
% Validate the parameters

% Default values
msg = '';

% paramValStruct.bValue = 0;                  % Default Busdays value <0>
% paramValStruct.busSelect = 1;               % Default Business day selection <1>
% paramValStruct.dbColor = [];                % Default user date box/color vector <empty>
% paramValStruct.dsColor = [];                % Default user date strng/color vector <empty>
% paramValStruct.destUI = [];                 % Default destination handles <empty>
% paramValStruct.hol = [];                    % Default user supplied holiday vector <empty>
% paramValStruct.initDate = [];               % Default initialization date <TODAY -> [Y M D] which is set later>
% paramValStruct.inDateFmt = [];              % Default input format <[] -> best guess by MATLAB>
% paramValStruct.outDateFmt = 1;              % Default output format <('dd-mmm-yyyy') -> 01-Mar-2000>
% paramValStruct.outDateStyl = 0;             % Default output style <date string (comma separated list)>
% paramValStruct.selType = 1;                 % Default selection type <single selection>
% paramValStruct.wkend = [];                  % Default weekend <empty>
% paramValStruct.windowStyle = 'normal';      % Default window style <normal>

% Special 1 input case
if numargin == 1
   msg = 'Too few inputs. Please use parameter/value pairs.';
   return
end

%
% Validate parameter names
%
defaultPVals = {0, 1, [], [], [], [], [], [], 1, 0, 1, [], 'normal'};
try
   [paramValStruct.bValue, paramValStruct.busSelect, paramValStruct.dbColor, ...
      paramValStruct.dsColor, paramValStruct.destUI, paramValStruct.hol, ...
      paramValStruct.initDate, paramValStruct.inDateFmt, paramValStruct.outDateFmt, ...
      paramValStruct.outDateStyl, paramValStruct.selType, paramValStruct.wkend, ...
      paramValStruct.windowStyle] = parsepvpairs(paramNames, defaultPVals, varargin{:});

catch E
   paramValStruct = [];
   msg = E.message;
   return
end

%
% Validate parameter values
%

% BusDays
if paramValStruct.bValue ~= 0 && paramValStruct.bValue ~= 1
   msg = 'Valid BUSDAYS values are 0 and 1.';
   return
end

% BusDaySelect
if paramValStruct.busSelect ~= 0 && paramValStruct.busSelect ~= 1
   msg = 'Valid BusDaySelect values are 0 and 1.';
   return
end

% DateBoxColor
if ~isempty(paramValStruct.dbColor)
   if ~isnumeric(paramValStruct.dbColor) && size(paramValStruct.dbColor, 2) ~= 4
      msg = 'DateBoxColor must be a 4 column matrix containing [serial dates, R, G, B].';
      return
   end
end

% DateStrColor
if ~isempty(paramValStruct.dsColor)
   if ~isnumeric(paramValStruct.dsColor) && size(paramValStruct.dsColor, 2) ~= 4
      msg = 'DateStrColor must be a 4 column matrix containing [serial dates, R, G, B].';
      return
   end
end

% DestinationUI
if isnumeric(paramValStruct.destUI)
   % Only handles
   if any(~ishandle(paramValStruct.destUI))
      msg = 'Not all DestinationUI handles are valid handles.';
      return
   end

   % Create a cell array of default properties (string)
   str = repmat(cellstr('string'), size(paramValStruct.destUI));

   % Combine the handles and properties
   paramValStruct.destUI = {paramValStruct.destUI , str};

elseif iscell(paramValStruct.destUI)
   % Handles and Properties

   if numel(paramValStruct.destUI) ~= 2
      msg = 'DestinationUI must contain a vector of only handles or a cell array of handles and properties.';
      return
   end

   % Parse handles
   uiH = paramValStruct.destUI{1};
   uiHSize = size(uiH);

   if ~isnumeric(uiH) || any(~ishandle(uiH))
      msg = 'Not all DestinationUI handles are valid handles.';
      return
   end

   if uiHSize(1) ~= 1 && uiHSize(2) ~= 1
      msg = 'The DestinationUI handle must be a scalar or vector.';
      return
   end

   numelUIH = numel(uiH);


   % Parse properties
   uiProp = paramValStruct.destUI{2};
   uiPropSize = size(uiProp);

   if ischar(uiProp)
      if uiPropSize(1) > 1
         msg = 'The DestinationUI property must be a single string or cell array of strings.';
         return
      end

      uiProp = cellstr(strtrim(paramValStruct.destUI{2}));

      numelProp = 1;

   elseif iscell(uiProp)
      if uiPropSize(1) ~= 1 && uiPropSize(2) ~= 1
         % Vector cell array only
         msg = 'Invalid DestinationUI property cell array dimension.';
         return
      end

      for idx = 1:numel(uiProp) %#ok
         if ischar(uiProp{idx})
            uiProp{idx} = strtrim(uiProp{idx});

         else
            msg = 'DestinationUI properties must cell array of strings.';
            return
         end
      end

      numelProp = numel(uiProp);

   else
      msg = 'DestinationParam must a string or cell array of strings.';
      return
   end

   % Scalar expand H and Properties to match
   if (numelUIH ~= 1 && numelProp ~= 1) && (numelUIH ~= numelProp)
      msg = 'Dimensions of the DestinationUI''s H and Prop are inconsistent.';
      return

   elseif numelUIH == numelProp
      % Do nothing, paramValStruct.destUI is ok

   else
      if numelUIH == 1
         % Scalar expand the handle
         uiH = repmat(uiH, size(uiProp));

      else
         % Scalar expand the property
         if ischar(uiProp)
            uiProp = cellstr(uiProp);
         end

         uiProp = repmat(uiProp, size(uiH));
      end

      % Combine the handles and properties
      paramValStruct.destUI = {uiH , uiProp};
   end

else
   msg = 'DestinationUI must contain only valid handles or must be a cell array of handles and properties.';
   return
end

% Holiday
if ~isempty(paramValStruct.hol) && ~isnumeric(paramValStruct.hol)
   msg = 'Holiday must be a scalar or vector of datenums.';
   return
end

% Initialization date
% Not validating InitDate here. Done by try catch on datevec.

% InputDateFormat
% Not validating InputDateFormat here. Done by try catch on datevec.

% OutputDateFormat
% Not validating OutputDateFormat here. Done by try catch on datevec.

% OutputDateStyle
if all(paramValStruct.outDateStyl ~= [0 1 2 3])
   msg = 'Valid OutputDateStyle values are 0-3.';
   return
end

% SelectionType
if paramValStruct.selType ~= 0 && paramValStruct.selType ~= 1
   msg = 'Valid SelectionType values are 0 and 1.';
   return
end

% Weekend
if ~isempty(paramValStruct.wkend)
   wkSize = size(paramValStruct.wkend);

   if (wkSize(1) > 1) && (wkSize(2) > 1)
      msg = 'Weekend must be a vector.';
      return
   end

   if ~isnumeric(paramValStruct.wkend) && ~islogical(paramValStruct.wkend)
      msg = 'Weekend must be a vector of numerics.';
      return

   else
      % Determine if the weekend vector is a vector of 0/1's or
      % 1-7's.
      if any(paramValStruct.wkend ~= 1 & paramValStruct.wkend ~= 0)
         % vector of nums 1-7
         for idx = 1:numel(paramValStruct.wkend) %#ok
            if ~any(paramValStruct.wkend(idx) == [1 2 3 4 5 6 7])
               msg = 'Valid Weekend values are 1-7.';
               return
            end
         end

      else
         % 7 element vector of 0's and 1's
         if all(paramValStruct.wkend == 1)
            msg = 'Weekend must be a 7 element vector of 0''s and 1''s.';
            return
         end

         if numel(paramValStruct.wkend) ~= 7
            msg = 'Weekend must be a 7 element vector of 0''s and 1''s.';
            return
         end

         % Create a vecotor of 1-7's
         standardWeekDayValues = [1 2 3 4 5 6 7];
         paramValStruct.wkend = standardWeekDayValues(logical(paramValStruct.wkend));
      end
   end

end

% WindowStyle
if ischar(paramValStruct.windowStyle)
   if ~strcmpi(paramValStruct.windowStyle, 'normal') && ~strcmpi(paramValStruct.windowStyle, 'modal')
      msg = 'Valid WindowStyles are ''normal'' and ''modal''. ';
      return
   end

else
   msg = 'Valid WindowStyles are ''normal'' and ''modal''. ';
   return
end


% ------------------------------------------------
function setbusdays(h, bValue)
% Set NYSE business days
%
% Inputs:
%      h - handles
% bValue - business day value 0/1

if bValue
   % Set NYSE business days/weekends into the calendar

   % Get current page (month)
   currMonth = datenum(getappdata(h.hfig, 'currMonth'));

   % Generate holidays for the 'page' the user selects
   currHol = isbusday(currMonth);

   % Generate the actual idx of the dates in the date array
   numPrevDays = getappdata(h.hfig, 'numPrevDays');
   arrayIdx = (1:numel(currHol)) + numPrevDays;

   % Generate the idx of holidays
   holIdx = arrayIdx(~currHol);

   % Set the holiday text string to be red and bold
   for idx = 1:numel(holIdx)
      set(h.daysquarestextobj{holIdx(idx)}, 'foregroundcolor', 'r', 'fontweight', 'bold')
   end
end


% ------------------------------------------------
function setdatecolorgeneric(h, datecolor, uiContObj)
% A generic function that sets any date to any color.
%
% Inputs:
%         h - handles
% dateColor - vector of dates and colors [datenum r g b]
% uiContObj - 0: Text box
%             1: String day

if ~isempty(datecolor)
   % Get current page (month)
   currMonth = datenum(getappdata(h.hfig, 'currMonth'));

   % Get the user specified dates
   userDate = datecolor(:, 1);

   % Get numPrevDays/numFutureDays
   numPrevDays = getappdata(h.hfig, 'numPrevDays');
   numFutureDays = getappdata(h.hfig, 'numFutureDays');

   % Match month days to user specified days
   for idx = 1:numel(currMonth)
      userDateMatch = currMonth(idx) == userDate;
      if any(userDateMatch)
         % Generate a logical idx of where the match occurs. Tack on the
         % numPrevDays/numFutureDays.
         matchIdx = userDate(userDateMatch) == currMonth;
         matchIdx = [false(numPrevDays, 1); matchIdx; false(numFutureDays, 1)]; %#ok

         if uiContObj
            set(h.daysquarestextobj{matchIdx}, ...
               'foregroundcolor', datecolor(userDateMatch, 2:4), ...
               'fontweight', 'bold')

         else
            set(h.daysquarestextobj{matchIdx}, ...
               'backgroundcolor', datecolor(userDateMatch, 2:4))
         end
      end
   end
end


% ------------------------------------------------
function setdateboxcolor(h, paramValStruct)
% Set the user specified box string colors

setdatecolorgeneric(h, paramValStruct.dbColor, 0)


% ------------------------------------------------
function setdatestringcolor(h, paramValStruct)
% Set the user specified date string colors

setdatecolorgeneric(h, paramValStruct.dsColor, 1)


% ------------------------------------------------
function setholidays(h, paramValStruct)
% Set the user specified holidays. These days will be red. The color cannot
% be altered. This parameter allows for users to set holidays other than
% the NYSE holidays from the 'busdays' parameter.

% Get unique dates. This will be datenums.
dates = unique(paramValStruct.hol(:));

% Color set as RED, [1 0 0], to represent holidays, same as 'busdays'.
colorVec = repmat([1 0 0], size(dates));

% Set the dates/colors
setdatecolorgeneric(h, [dates colorVec], 1)


% ------------------------------------------------
function setweekend(h, paramValStruct)
% Set the weekend days Red.

% Get the monthly dates
monthlyDates = datenum(getappdata(h.hfig, 'currMonth'));

% Get the weekday values
weekdayVals = weekday(monthlyDates);

% Find the specified weekend days. Make sure the dates are unique.
dates = [];
for idx2 = 1:numel(paramValStruct.wkend)
   hold = (weekdayVals == paramValStruct.wkend(idx2));
   dates = unique([dates; monthlyDates(hold)]);
end

% Color set as RED, [1 0 0], to represent holidays, same as 'busdays'.
colorVec = repmat([1 0 0], size(dates));

% Set the dates/colors
setdatecolorgeneric(h, [dates colorVec], 1)


% ------------------------------------------------
function setcurrprevselects(h, hcbo)
% Set the curret and previous selected squares handles and year/month/day and
% color. This is required due to the reuse of uipanels and uiobjects.
%
% [Handle Year Month Day R G B]
%
% Inputs:
% hcbo - current selected square handle

% Get current and prev handles
currentSelectedSquare = getappdata(h.hfig, 'currentSelectedSquare');

% Set the current selected square into the current appdata field
[m, y] = getpage(h);
d = str2double(get(hcbo, 'string'));
c = get(get(hcbo, 'parent'), 'backgroundcolor');
setappdata(h.hfig, 'currentSelectedSquare', [hcbo y m d c])

% Set the previous selected square (the stored current appdata value) into
% the previous appdata field.
setappdata(h.hfig, 'previousSelectedSquare', currentSelectedSquare)


% -------------------------------------------------
function [datenumOut, datevecOut] = selecteddates(h)
% Parse the selectedSquares and get all the dates
%
% Inputs:
%          h - handles
%
% Outputs:
% datenumOut - datenums
% datevecOut - date components

% Get the selected squares/dates
selectedSquares = getappdata(h.hfig, 'selectedSquares');

% Get the number of different pages
pg = size(selectedSquares.date, 1);

datevecOut = [];
for idx = 1:pg
   % Generate datevec components
   d = selectedSquares.day{idx}(:);
   ymMat = repmat(selectedSquares.date(idx, :), size(d));
   holdDate = [ymMat(:, 2) ymMat(:, 1) d];

   datevecOut = [datevecOut; holdDate]; %#ok
end

datenumOut = datenum(datevecOut);


% -------------------------------------------------
function [right, left] = getarrowcdata
% Generate arrow cdata

rightA = [ ...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1; ...
   1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1; ...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];

leftA = fliplr(rightA);

% Set the background alpha to clear.
rightA(rightA == 1) = NaN;
leftA(leftA == 1) = NaN;

% Set the colors black = [0 0 0]
right = repmat(rightA, [1 1 3]);
left = repmat(leftA, [1 1 3]);


% -------------------------------------------------
function [outputDate, marketClosureDates, errMsg] = filterdays(h, hcbo)
% Determine the market closure dates. Include NYSE non-business days,
% user specified weekend dates, and user speccified holidays.
%
% Supplying an hcbo will produce output: outputDate
%
% Inputs:
% hcbo               - handle of the current selected date
%
% Outputs:
% outputDate         - returned if date is a valid business day
% marketClosureDates - Vector of all market closures between the start and
%                      end date.
% errMsg             - notify of non - busday selection


errMsg = '';

% Get appdata
paramValStruct = getappdata(h.hfig, 'paramValStruct');

% Get all the dates containted between the start and end dates. Start at
% the first day of the month of the start date and end on the last date of
% the month of the end date. If there are no dates selected, use the
% current month.
datenumOut = selecteddates(h);

if isempty(datenumOut)
   % There do not exist any selected dates in the calendar
   dateSpan = datenum(getappdata(h.hfig, 'currMonth'));
   day1 = dateSpan(1);
   dayEnd = dateSpan(end);

else
   % Get all the dates found between the months of min/max selected dates.
   [sy, sm] = datevec(min(datenumOut));
   [ey, em] = datevec(max(datenumOut));

   day1 = datenum([sy, sm, 1]);
   dayEnd = eomdate(ey, em);

   dateSpan = (day1:dayEnd)';
end

marketClosureDates = [];
% Find non-business days
if paramValStruct.bValue == 1 && ~isempty(dateSpan)
   bdIdx = isbusday(dateSpan);

   marketClosureDates = [marketClosureDates; dateSpan(~bdIdx)];
end

% Add user holidays
if ~isempty(paramValStruct.hol) && ~isempty(dateSpan)
   % Find all dates between start and end date.
   s = paramValStruct.hol(:) >= min(day1);
   e = paramValStruct.hol(:) <= max(dayEnd);

   useableHolidaysIdx = sum([s, e], 2);
   userholidays = paramValStruct.hol(useableHolidaysIdx == 2);

   marketClosureDates = [marketClosureDates; userholidays(:)];
end

% Find/add user weekends
if ~isempty(paramValStruct.wkend)
   % 1 - Sunday
   % 2 - Monday
   % 3 - Tuesday
   % 4 - Wednesday
   % 5 - Thursday
   % 6 - Friday
   % 7 - Saturday
   weekdayNum = weekday(dateSpan);

   weekendIdxMat = [];
   for idx = 1:numel(paramValStruct.wkend)
      weekendIdxHold = weekdayNum == paramValStruct.wkend(idx);
      weekendIdxMat = [weekendIdxMat, weekendIdxHold]; %#ok
   end

   marketClosureDatesIdx = sum(weekendIdxMat, 2) ~= 0;
   weekendDays = dateSpan(marketClosureDatesIdx);

   marketClosureDates = [marketClosureDates; weekendDays];
end

% Sort the moarket closures.
marketClosureDates = sort(marketClosureDates);

% Determine if the input date is a valid business day
% Get the datenum of the selected date
[m, y] = getpage(h);

d = str2double(get(hcbo, 'string'));

selectedDatenum = datenum([y, m, d]);

% Check to see if its a non-busday
if any(selectedDatenum == marketClosureDates)
   outputDate = [];
   errMsg = 'Please select a valid business day.';

else
   outputDate = selectedDatenum;
end


% -----------------------------------------------------
function h = convert2vector(h)
%CONVERT2VECTOR Convert data structure to vector
%   CONVERT2VECTOR(H) Convert data structure H to vector.  H can be any
%   MATLAB datatype, i.e. a structure, matrix, cell array, cell array of
%   structures, etc.

%   Author(s): J. Schickler

% In r13 see if this can be a static method of siggui

if isstruct(h),

   % Convert Structure to Vector
   h = struct2vector(h);
elseif iscell(h),

   % Convert Cell array to Vector
   h = cell2vector(h);
else

   % Make sure that the vector is a row vector
   if ~isnumeric(h)
      % Customized code to skip over java string vectors (pw)
      h = [];
   end
   h = transpose(h(:));
end


% --------------------------------------------------------------
function h = struct2vector(h)

% Loop over the structure in case of a vector of structures
hnew = {};
for i = 1:length(h)
   hnew = {hnew{:} struct2cell(h(i))};
end

h = cell2vector(hnew);


% ---------------------------------------------------------------
function h = cell2vector(h)

for i = 1:length(h)
   h{i} = convert2vector(h{i});
end

h = [h{:}];


% [EOF]
