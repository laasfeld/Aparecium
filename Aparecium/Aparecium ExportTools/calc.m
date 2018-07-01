function varargout = calc(varargin)
% This function creates a function editor
% GUI for editing functions. Allows user to choose whatever function to be
% calculated depending on available channels. Maximum number of channels is
% currently five. 
% Instructions: enter the function you need and press "Confirm Function" button on the
% calculator to confirm the function entered, then close the window to return the function.


% CALC M-file for calc.fig
%      CALC, by itself, creates a new CALC or raises the existing
%      singleton*.
%
%      H = CALC returns the handle to a new CALC or the handle to
%      the existing singleton*.
%
%      CALC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALC.M with the given input arguments.
%
%      CALC('Property','Value',...) creates a new CALC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calc_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calc

% Last Modified by GUIDE v2.5 01-Jan-2010 13:02:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calc_OpeningFcn, ...
                   'gui_OutputFcn',  @calc_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before calc is made visible.
function calc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calc (see VARARGIN)


% Choose default command line output for calc
handles.output = hObject;
handles.inputChannels = varargin(1);
handles.outputVariable = 'userDefVariable';

numberOfButtons = 39;% Currently a constant
buttonArray = cell(numberOfButtons, 1);
for buttonIndex = 1 : numberOfButtons
    evalString = ['buttonArray{buttonIndex} = handles.channel', num2str(buttonIndex), 'button;'];
    eval(evalString);
end

for buttonIndex = 1 : size(varargin{1},2)
   set(buttonArray{buttonIndex}, 'visible', 'on');
   set(buttonArray{buttonIndex},'String',handles.inputChannels{1}{buttonIndex});
   set(buttonArray{buttonIndex},'TooltipString',handles.inputChannels{1}{buttonIndex})
end

if isequal(numel(varargin), 1)
    handles.outputString = '0';
elseif isequal(numel(varargin), 4)
    if strcmp(varargin{2}, 'edit')
        handles.outputString = varargin{3};
        handles.outputVariable = varargin{4};
        set(handles.text1, 'String', varargin{3});      
    end
end
set(handles.outputVariableBox, 'String', handles.outputVariable);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calc wait for user response (see UIRESUME)
uiwait(handles.figure1);
global jj shift
set(handles.text1,'String','0.');
jj=0;
shift=0;
% --- Outputs from this function are returned to the command line.
function varargout = calc_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.outputString;
varargout{2} = {handles.outputVariable};
delete(handles.figure1);


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
function pushbutton33_Callback(hObject, eventdata, handles)

global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','3.141592653589793') ;
else
textString =strcat(textString,'3.141592653589793');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)


% --- Executes on button press in button_1.
function button_1_Callback(hObject, eventdata, handles)
% hObject    handle to button_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','1') ;
else
textString =strcat(textString,'1');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_2.
function button_2_Callback(hObject, eventdata, handles)
% hObject    handle to button_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','2') ;
else
textString =strcat(textString,'2');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_3.
function button_3_Callback(hObject, eventdata, handles)
% hObject    handle to button_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','3') ;
else
textString =strcat(textString,'3');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_7.
function button_7_Callback(hObject, eventdata, handles)
% hObject    handle to button_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','7') ;
else
textString =strcat(textString,'7');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)


% --- Executes on button press in button_5.
function button_5_Callback(hObject, eventdata, handles)
% hObject    handle to button_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&(jj==0)
   set(handles.text1,'String','5') ;
else
textString =strcat(textString,'5');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_6.
function button_6_Callback(hObject, eventdata, handles)
% hObject    handle to button_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','6') ;
else
textString =strcat(textString,'6');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_plus.
function button_plus_Callback(hObject, eventdata, handles)
% hObject    handle to button_plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1,'String');
textString =strcat(textString,'+');
set(handles.text1,'String',textString)
returnFocus(hObject)

% --- Executes on button press in button_8.
function button_8_Callback(hObject, eventdata, handles)
% hObject    handle to button_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&(jj==0)
   set(handles.text1,'String','8') ;
else
textString =strcat(textString,'8');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_9.
function button_9_Callback(hObject, eventdata, handles)
% hObject    handle to button_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&(jj==0)
   set(handles.text1,'String','9') ;
else
textString =strcat(textString,'9');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_multiply.
function button_multiply_Callback(hObject, eventdata, handles)
% hObject    handle to button_multiply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1,'String');
textString =strcat(textString,'.*');
set(handles.text1,'String',textString)
returnFocus(hObject)

% --- Executes on button press in button_minus.
function button_minus_Callback(hObject, eventdata, handles)
% hObject    handle to button_minus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1,'String');
textString =strcat(textString,'-');
set(handles.text1,'String',textString)
returnFocus(hObject)

% --- Executes on button press in button_0.
function button_0_Callback(hObject, eventdata, handles)
% hObject    handle to button_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% textString = get(handles.text1,'String');
% %strcmp(textString,'0.')
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','0.') ;
else
textString =strcat(textString,'0');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_4.
function button_4_Callback(hObject, eventdata, handles)
% hObject    handle to button_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&(jj==0)
   set(handles.text1,'String','4') ;
else
textString =strcat(textString,'4');
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)

% --- Executes on button press in button_divide.
function button_divide_Callback(hObject, eventdata, handles)
% hObject    handle to button_divide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1,'String');
textString =strcat(textString,'./');
set(handles.text1,'String',textString)
returnFocus(hObject)

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1,'String');
% if(strcmp(textString,'0.')==1)
%    set(handles.text1,'String','0.') ;
% else
% [a b c] = strread(textString, '%f %c %f');
% clear ans;
% 
% switch b
%     case '*'
%         ans=a*c;
%     case '/'
%         if (c==0)
%             ans='Error Divided by zero';
%         else
%         ans=a/c;
%         end
%     case '-'
%         ans=a-c;
%     case '+'
%         ans=a+c;
%    
% end
%ans =eval(textString);
handles.outputString = textString;
%set(handles.text1,'String',ans)
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
else
    delete(handles.figure1);
end
returnFocus(hObject)
%end

% --- Executes on button press in Clear.
function Clear_Callback(hObject, eventdata, handles)
% hObject    handle to Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text1,'String','') ;
returnFocus(hObject)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1, 'String');
if strcmp(textString(1), '-')
    textString(1) = [];
else 
    textString = ['-', textString];
end

set(handles.text1, 'String', textString)
guidata(hObject, handles);
returnFocus(hObject)

% --- Executes on button press in button_dot.
function button_dot_Callback(hObject, eventdata, handles)
% hObject    handle to button_dot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj 
textString = get(handles.text1,'String');
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','0.') ;
   jj=1;
else
textString =strcat(textString,'.');
set(handles.text1,'String',textString)
end
returnFocus(hObject)


% --- Executes on button press in button_leftBracket.
function button_leftBracket_Callback(hObject, eventdata, handles)
% hObject    handle to button_leftBracket (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','(') ;
else
textString =strcat(textString,'(');
set(handles.text1,'String',textString)
end
returnFocus(hObject)
% --- Executes on button press in button_rightBracket.
function button_rightBracket_Callback(hObject, eventdata, handles)
% hObject    handle to button_rightBracket (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)
   set(handles.text1,'String',')') ;
else
textString =strcat(textString,')');
set(handles.text1,'String',textString)
end
returnFocus(hObject)


% --- Executes on button press in Back.
function Back_Callback(hObject, eventdata, handles)
% hObject    handle to Back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jj
textString = get(handles.text1,'String');

if(strcmp(textString,'0.')==1)&&(jj==0)
   set(handles.text1,'String','0.') ;
else
    ss=char(textString);
    l=length(textString);
    textString=ss(1:l-1);
set(handles.text1,'String',textString)

end
jj=0;
returnFocus(hObject)


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','sin') ;
else
textString =strcat(textString,'sin');
set(handles.text1,'String',textString)
end
    case 1
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','asin') ;
else
textString =strcat(textString,'asin');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)

% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','cos') ;
else
textString =strcat(textString,'cos');
set(handles.text1,'String',textString)
end
    case 1
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','acos') ;
else
textString =strcat(textString,'acos');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)

% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','tan') ;
else
textString =strcat(textString,'tan');
set(handles.text1,'String',textString)
end
    case 1
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','atan') ;
else
textString =strcat(textString,'atan');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)

% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','log') ;
else
textString =strcat(textString,'log');
set(handles.text1,'String',textString)
end
    case 1
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','log10') ;
else
textString =strcat(textString,'log10');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global  shift 

shift=1;
returnFocus(hObject)

% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','exp') ;
else
textString =strcat(textString,'exp');
set(handles.text1,'String',textString)
end

end
returnFocus(hObject)

% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','sinh') ;
else
textString =strcat(textString,'sinh');
set(handles.text1,'String',textString)
end
    case 1
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','asinh') ;
else
textString =strcat(textString,'atanh');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)

% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','cosh') ;
else
textString =strcat(textString,'cosh');
set(handles.text1,'String',textString)
end
    case 1
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','acosh') ;
else
textString =strcat(textString,'acosh');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)

% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','10^') ;
else
textString =strcat(textString,'10^');
set(handles.text1,'String',textString)
end
end 
returnFocus(hObject)

% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','factorial') ;
else
textString =strcat(textString,'factorial');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)

% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)

global shift
textString = get(handles.text1,'String');
 switch shift
     case 0
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','tanh') ;
else
textString =strcat(textString,'tanh');
set(handles.text1,'String',textString)
end
    case 1
if(strcmp(textString,'0.')==1)
   set(handles.text1,'String','atanh') ;
else
textString =strcat(textString,'atanh');
set(handles.text1,'String',textString)
end
end
returnFocus(hObject)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.outputString = '';
handles.outputVariable = '';
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'),'waiting')
    uiresume(hObject)
else
    delete(hObject);
end


% --- Executes on button press in channel1button.
function channel1button_Callback(hObject, eventdata, handles)
% hObject    handle to channel1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel2button.
function channel2button_Callback(hObject, eventdata, handles)
% hObject    handle to channel2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel3button.
function channel3button_Callback(hObject, eventdata, handles)
% hObject    handle to channel3button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel4button.
function channel4button_Callback(hObject, eventdata, handles)
% hObject    handle to channel4button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel5button.
function channel5button_Callback(hObject, eventdata, handles)
% hObject    handle to channel5button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel6button.
function channel6button_Callback(hObject, eventdata, handles)
% hObject    handle to channel6button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel7button.
function channel7button_Callback(hObject, eventdata, handles)
% hObject    handle to channel7button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel8button.
function channel8button_Callback(hObject, eventdata, handles)
% hObject    handle to channel8button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel9button.
function channel9button_Callback(hObject, eventdata, handles)
% hObject    handle to channel9button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel10button.
function channel10button_Callback(hObject, eventdata, handles)
% hObject    handle to channel10button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel11button.
function channel11button_Callback(hObject, eventdata, handles)
% hObject    handle to channel11button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

function handles = addChannelToFormula(handles, hObject)
tag = get(hObject, 'Tag');
channelIndex = str2double(regexp(tag,'(\d{1,6})', 'match', 'once'));
textString = get(handles.text1,'String');
textString =strcat(textString,handles.inputChannels{1}{channelIndex});
set(handles.text1,'String',textString)
returnFocus(hObject)

function outputVariableBox_Callback(hObject, eventdata, handles)
% hObject    handle to outputVariableBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputVariableBox as text
%        str2double(get(hObject,'String')) returns contents of outputVariableBox as a double
if strcmp(get(hObject, 'String'), '')
    warndlg('The variable name can´t be empty! Please enter a valid name.');
    set(hObject, 'String', handles.outputVariable);
else
    handles.outputVariable = get(hObject, 'String');
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function outputVariableBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputVariableBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uipanel2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key, 'backspace')
    Back_Callback(handles.Back, eventdata, handles);
elseif strcmp(eventdata.Key, 'delete')
    Clear_Callback(handles.Clear, eventdata, handles);
else
    switch eventdata.Character
        case '0'
            button_0_Callback(handles.button_0, eventdata, handles);
        case '1'
            button_1_Callback(handles.button_1, eventdata, handles);
        case '2'
            button_2_Callback(handles.button_2, eventdata, handles);
        case '3'
            button_3_Callback(handles.button_3, eventdata, handles);
        case '4'
            button_4_Callback(handles.button_4, eventdata, handles);
        case '5'
            button_5_Callback(handles.button_5, eventdata, handles);
        case '6'
            button_6_Callback(handles.button_6, eventdata, handles);
        case '7'
            button_7_Callback(handles.button_7, eventdata, handles);
        case '8'
            button_8_Callback(handles.button_8, eventdata, handles);
        case '9'
            button_9_Callback(handles.button_9, eventdata, handles);
        case '-'
            button_minus_Callback(handles.button_minus, eventdata, handles);
        case '+'
            button_plus_Callback(handles.button_plus, eventdata, handles);
        case '*'
            button_multiply_Callback(handles.button_multiply, eventdata, handles);
        case '/'
            button_divide_Callback(handles.button_divide, eventdata, handles);
        case '('
            button_leftBracket_Callback(handles.button_leftBracket, eventdata, handles);
        case ')'
            button_rightBracket_Callback(handles.button_rightBracket, eventdata, handles);
        case '.'   
            button_dot_Callback(handles.button_dot, eventdata, handles);
    end
end

function returnFocus(hObject)
set(hObject, 'Enable', 'off');
drawnow;
set(hObject, 'Enable', 'on');

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel12button.
function channel12button_Callback(hObject, eventdata, handles)
% hObject    handle to channel12button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel13button.
function channel13button_Callback(hObject, eventdata, handles)
% hObject    handle to channel13button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel14button.
function channel14button_Callback(hObject, eventdata, handles)
% hObject    handle to channel14button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel15button.
function channel15button_Callback(hObject, eventdata, handles)
% hObject    handle to channel15button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel16button.
function channel16button_Callback(hObject, eventdata, handles)
% hObject    handle to channel16button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel17button.
function channel17button_Callback(hObject, eventdata, handles)
% hObject    handle to channel17button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel18button.
function channel18button_Callback(hObject, eventdata, handles)
% hObject    handle to channel18button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel19button.
function channel19button_Callback(hObject, eventdata, handles)
% hObject    handle to channel19button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel20button.
function channel20button_Callback(hObject, eventdata, handles)
% hObject    handle to channel20button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel21button.
function channel21button_Callback(hObject, eventdata, handles)
% hObject    handle to channel21button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel22button.
function channel22button_Callback(hObject, eventdata, handles)
% hObject    handle to channel22button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel23button.
function channel23button_Callback(hObject, eventdata, handles)
% hObject    handle to channel23button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel24button.
function channel24button_Callback(hObject, eventdata, handles)
% hObject    handle to channel24button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel25button.
function channel25button_Callback(hObject, eventdata, handles)
% hObject    handle to channel25button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel26button.
function channel26button_Callback(hObject, eventdata, handles)
% hObject    handle to channel26button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel27button.
function channel27button_Callback(hObject, eventdata, handles)
% hObject    handle to channel27button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel28button.
function channel28button_Callback(hObject, eventdata, handles)
% hObject    handle to channel28button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel29button.
function channel29button_Callback(hObject, eventdata, handles)
% hObject    handle to channel29button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel30button.
function channel30button_Callback(hObject, eventdata, handles)
% hObject    handle to channel30button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel31button.
function channel31button_Callback(hObject, eventdata, handles)
% hObject    handle to channel31button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel32button.
function channel32button_Callback(hObject, eventdata, handles)
% hObject    handle to channel32button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel33button.
function channel33button_Callback(hObject, eventdata, handles)
% hObject    handle to channel33button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel34button.
function channel34button_Callback(hObject, eventdata, handles)
% hObject    handle to channel34button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel35button.
function channel35button_Callback(hObject, eventdata, handles)
% hObject    handle to channel35button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel36button.
function channel36button_Callback(hObject, eventdata, handles)
% hObject    handle to channel36button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel37button.
function channel37button_Callback(hObject, eventdata, handles)
% hObject    handle to channel37button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel38button.
function channel38button_Callback(hObject, eventdata, handles)
% hObject    handle to channel38button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);

% --- Executes on button press in channel39button.
function channel39button_Callback(hObject, eventdata, handles)
% hObject    handle to channel39button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = addChannelToFormula(handles, hObject);
guidata(hObject, handles);
