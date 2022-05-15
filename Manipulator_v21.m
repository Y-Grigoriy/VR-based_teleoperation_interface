%% Блок создания интерфейса
% Функция создания интерфейса
function Manipulator_v20 % !!! Ошибка может возникнуть из-за расширения таблицы массы !!!

InputData; % Считывание исходных данных

global l1 l2 TabAngles Steph ChaCond CoorX CoorY mc ms0 ms1 ms2 ms3 ms4...
    TabAng TabMass TabLength DevCon TabMot TabSens TabMaxTorq ris0 choo ...
    De RArr UArr LArr DArr Pplo ClAp Start De2 RWM GrCont AngStep ExpName...
    Pointsy OpM GrRot MOLC almin almax bemin bemax temin temax psmin psmax

Start = cputime; % измерение времени работы функции

k_s=0.83333; % коэффициент масштабирования элементов окна по длине
k_s2=0.7; % коэффициент масштабирования положения элементов окна по длине
k_s3=0.008; % коэффициент смещения положения блока №3 по Х
k_s4=0.004; % коэффициент смещения положения блока №2 по X
k_s5=0.05; % коэффициент смещения положения блока №3 по Y

%% Блок элементов №1
% Создаем графическое окно с тегом figure
hF = figure('Name', 'Manipulator', 'NumberTitle','off','MenuBar', 'none', 'Units', 'characters',...
    'Position', [1 4 270 57], 'Color', [133/255,201/255,181/255],'Tag', 'figure');

% Создание осей с тегом ax для отображения текущего положения манипулятора
set(0,'DefaultAxesFontSize',12,'DefaultAxesFontName','Times New Roman');
ris0=axes('Position', [0.07*k_s*k_s2 0.28 0.5*k_s 0.7],'Tag', 'ax','NextPlot', 'replacechildren');
Xmax=l1+l2+0.2;
axis([-Xmax Xmax -Xmax l2+0.25]);
axis equal
xlabel('x, m');
ylabel('y, m');
grid on

% Рабочий диапазон углов сервомоторов и координат
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.07*k_s*k_s2 0.175 0.5*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Working range of angles & axes',...
    'FontSize',14,'FontName','Book Antiqua','FontWeight','Bold','Tag', 'textAngles');
VarName={'<HTML><font size=+1><center />Minimum Value</HTML>';
    '<HTML><font size=+1><center />Maximum Value</HTML>'};
WAngles=[almin bemin temin psmin -(l1+l2) -(l1+l2); almax bemax temax psmax (l1+l2) l2];
cnames = {'<HTML><font size=+1>&alpha</HTML>' '<HTML><font size=+1>&beta</HTML>'...
    '<HTML><font size=+1>&theta</HTML>' '<HTML><font size=+1>&psi</HTML>' ...
    '<HTML><font size=+1>X</HTML>' '<HTML><font size=+1>Y</HTML>'};
uitable('Data',VarName,'Units', 'normalized','Position',[0.104*k_s*k_s2 0.09 0.12*k_s 0.089],...
    'ColumnWidth',{145},'ColumnName',{'<HTML><font size=+1><center />Name</HTML>'},'RowName',[],...
    'FontName','Book Antiqua','FontSize',12,'Tag','TabAngName');
TabAngles=uitable('Data',WAngles,'Units', 'normalized',...
    'Position',[(0.11*k_s2+0.11)*k_s 0.09 0.3331*k_s 0.089],'ColumnWidth',{70},'ColumnName',cnames,...
    'RowName',[],'FontName','Book Antiqua','FontSize',12,'ColumnEditable',[true true true false true true],...
    'Tag','TabAngles');

% Поле для ввода комментариев к эксперименту
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.115*k_s*k_s2 0.034 0.132*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Experiment comments','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold');
% Область ввода текста
ExpName=uicontrol('Style', 'edit', 'Units', 'normalized','Position', [0.315*k_s*k_s2  0.039 0.114*k_s 0.04],...
    'String', '-','BackgroundColor','w','FontSize',13,'FontName','Book Antiqua','Tag','ExpCom');

% Меню выбора приоритетной координаты с тегом ChangeCondition
ChaCond=uicontrol('style','checkbox', 'Units', 'normalized','Value',1,...
    'position',[0.51*k_s*k_s2  0.039 0.2*k_s 0.04],'String','Structural limitations','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold','BackgroundColor', [133/255,201/255,181/255],...
    'Tag','ChangeCondition');

%% Блок элементов №2

% Кнопки управления положением манипулятора
% Вставка изображения с поясняющей схемой 
handles.banner = imread('Scheme (46).png'); 
ris=axes('Units', 'normalized','Position',[0.585*k_s+k_s4 0.679 0.20996 0.30046],'Tag', 'ax2');
image(handles.banner);
set(ris,'visible','off','Units', 'normalized');

% Поле выбора положений
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.58*k_s-k_s3  0.618 0.07*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Points','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold','Tag', 'Poy');
Pointsy=uicontrol('style','popupmenu', 'Units', 'normalized','position',[0.6402*k_s-k_s3  0.623 0.07*k_s 0.04],...
    'string',{'reading...';'0 point';'Stable';'Relax';'Stretch out';'Up';'Bottom'},'Value',1,'Callback', @PrePa,'FontSize',12,...
    'FontName','Book Antiqua','backgroundcolor',[1 1 1],'foregroundcolor' ,[.1 .1 .5]);

% Кнопка включения режима демонстрация
De=uicontrol('Style', 'togglebutton', 'Units', 'normalized','Position', [0.7166*k_s-k_s3  0.625 0.07*k_s 0.04],...
    'BackgroundColor', [255/255,238/255,155/255],'String','Demo','FontSize',13,...
    'FontName','Book Antiqua','FontWeight','Bold','Callback', @FRDemo,'Tag','Dem');

% Кнопка включения режима вычисления массы груза
De2=uicontrol('Style', 'togglebutton', 'Units', 'normalized','Position', [0.793*k_s-k_s3  0.625 0.07*k_s 0.04],...
    'BackgroundColor', [255/255,238/255,155/255],'String','Weigh','FontSize',13,...
    'FontName','Book Antiqua','FontWeight','Bold','Callback', @ChWeigh,'Tag','Demo2');

% Кнопка с тегом UpArrow
UpAr = char(hex2dec('AD'));
UArr=uicontrol('Style', 'pushbutton', 'Units', 'normalized','Position', [0.690977*k_s+k_s4 0.5515 0.04*k_s 0.06],...
    'BackgroundColor', [255/255,238/255,155/255],'String',UpAr,'FontSize',18,'FontName','Symbol',...
    'FontWeight','Bold','Callback', @UpArrow, 'Tag', 'UpArrow');
% Кнопка с тегом DownArrow
DownAr = char(hex2dec('22'));
DArr=uicontrol('Style', 'pushbutton', 'Units', 'normalized','Position', [0.690977*k_s+k_s4 0.4815 0.04*k_s 0.06],...
    'BackgroundColor', [255/255,238/255,155/255],'String',DownAr,'FontSize',12,'FontName','Symbol',...
    'FontWeight','Bold','Callback', @DownArrow, 'Tag', 'DownArrow');
% Кнопка с тегом LeftArrow
LeftAr = char(hex2dec('AC'));
LArr=uicontrol('Style', 'pushbutton', 'Units', 'normalized','Position', [0.642627*k_s+k_s4 0.4815 0.04*k_s 0.06],...
    'BackgroundColor', [255/255,238/255,155/255],'String',LeftAr,'FontSize',18,'FontName','Symbol',...
    'FontWeight','Bold','Callback', @LeftArrow, 'Tag', 'LeftArrow');
% Кнопка с тегом RightArrow
RightAr = char(hex2dec('AE'));
RArr=uicontrol('Style', 'pushbutton', 'Units', 'normalized','Position', [0.739327*k_s+k_s4 0.4815 0.04*k_s 0.06],...
    'BackgroundColor', [255/255,238/255,155/255],'String',RightAr,'FontSize',18,'FontName','Symbol',...
    'FontWeight','Bold','Callback', @RightArrow, 'Tag', 'RightArrow');

% Поля для выбора шага, на который изменяется координата при нажатии на кнопки управления положением
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.558977*k_s+k_s4  0.4135 0.057*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Step, m:','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold');
% Область ввода текста
Steph=uicontrol('Style', 'edit', 'Units', 'normalized','Position', [0.620977*k_s+k_s4  0.4235 0.09*k_s 0.04],...
    'String', '0.02','BackgroundColor','w','FontSize',12,'FontName','Book Antiqua','Tag','edtStep');

% Поле с выбором приоритетной координаты
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.715*k_s+k_s4 0.4135 0.067*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Main axis:','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold');
% Меню выбора приоритетной координаты с тегом ChooseAxis
choo=uicontrol('style','popupmenu', 'Units', 'normalized','position',[0.787*k_s+k_s4  0.4225 0.07*k_s 0.04],'string',{'None';'X';'Y'},'FontSize',12,...
    'FontName','Book Antiqua','backgroundcolor',[1 1 1],'foregroundcolor' ,[.1 .1 .5],'Tag', 'ChooseAxis');

% Поля для ручного ввода координат
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.560476*k_s+k_s4 0.375 0.301*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Coordinates:','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold');
% Область текста с тегом textX
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.575977*k_s+k_s4  0.33 0.04*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'X, m:','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold','Tag', 'textX');
% Область ввода текста с тегом edtX 0.0554 0.28 0
CoorX=uicontrol('Style', 'edit', 'Units', 'normalized','Position', [0.620977*k_s+k_s4  0.34 0.09*k_s 0.04],...
    'String', '0.07','BackgroundColor','w','FontSize',12,'FontName','Book Antiqua','Tag', 'edtX');
% Область текста с тегом textY
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.710976*k_s+k_s4 0.33 0.04*k_s 0.04],...
    'BackgroundColor',[133/255,201/255,181/255],'String', 'Y, m:','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold','Tag', 'textY');
% Область ввода текста с тегом edtY -0.0398 -0.56 -0.07
CoorY=uicontrol('Style', 'edit', 'Units', 'normalized','Position', [0.755976*k_s+k_s4 0.34 0.09*k_s 0.04],...
    'String','-0.11','BackgroundColor','w','FontSize',12,'FontName','Book Antiqua','Tag', 'edtY');

% Кнопка с тегом btnPlot для отображения текущего положения манипулятора
Pplo=uicontrol('Style', 'pushbutton', 'Units', 'normalized','Position', [0.560477*k_s+k_s4 0.279 0.301*k_s 0.05],...
    'BackgroundColor', [255/255,238/255,155/255],'String', 'Plot','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold','Callback', @BtnPlot, 'Tag', 'btnPlot');

% Таблица с массами серводвигателей и груза
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.555977*k_s+k_s4  0.225 0.105*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Mass, kg','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold','Tag', 'textMass');
mas={'Cargo' mc; 'Motor 1' ms0; 'Motor 2' ms1; 'Motor 3' ms2; 'Motor 4' ms3; 'Motor 5' ms4};
TabMass=uitable('Data',mas,'Units', 'normalized','Position',[0.555977*k_s+k_s4 0.026 0.105*k_s 0.202],...
    'ColumnWidth',{65 65},'ColumnName',[],'RowName',[],'FontName','Symbol','FontSize',14,...
    'ColumnEditable', [false true],'Tag','TabMass');

% Таблицы с выходными данными
% Таблица с вычисленными углами поворотов
AngDeg = ['Angles,' ' ' char(hex2dec('B0'))];
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.670977*k_s+k_s4 0.225 0.084*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', AngDeg,'FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold','Tag', 'textAng');
AngName={'<HTML><font size=+1>&alpha</HTML>' ' '; '<HTML><font size=+1>&beta</HTML>' ' ';...
    '<HTML><font size=+1>&theta</HTML>' ' ';'<HTML><font size=+1>&phi</HTML>' 90;...
    '<HTML><font size=+1>&psi</HTML>' 90};
TabAng=uitable('Data',AngName,'Units', 'normalized','Position',[0.670977*k_s+k_s4 0.06 0.084*k_s 0.168],...
    'ColumnWidth',{30 75},'ColumnName',[],'RowName',[],'FontName','Symbol','FontSize',14,'Tag','TabAng');

% Таблица с величинами длин звеньев
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.757477*k_s+k_s4  0.225 0.12*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Length of link, m','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold');
Leng={'<HTML>L<sub>1</sub>=</HTML>' l1; '<HTML>L<sub>2</sub>=</HTML>' l2};
TabLength=uitable('Data',Leng,'Units', 'normalized','Position',[0.771227*k_s+k_s4 0.158 0.0925*k_s 0.069],...
    'ColumnWidth',{40 75},'ColumnName',[],'RowName',[],'ColumnEditable', [false true],...
    'FontName','Symbol','FontSize',14);

%% Блок элементов №3

% Кнопка вызова помощи
uicontrol('Style', 'pushbutton', 'Units', 'normalized','Position', [0.944 0.95 0.6*0.04*k_s 0.6*0.06],...
    'BackgroundColor', [133/255,201/255,181/255],'String','?','FontSize',18,'FontName','Book Antiqua',...
    'FontWeight','Bold','Callback', @HelpApp);

% Кнопка закрытия приложения
ClAp=uicontrol('Style', 'pushbutton', 'Units', 'normalized','Position', [0.974 0.95 0.6*0.04*k_s 0.6*0.06],...
    'BackgroundColor', [133/255,201/255,181/255],'String','X','FontSize',18,'FontName','Book Antiqua',...
    'FontWeight','Bold','Callback', @CloseApp);

% Область текста с тегом Con
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.9448*k_s-k_s3  0.89 0.114*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Connection','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold','Tag', 'Con');

% Меню подключения/отключения манипулятора
DevCon=uicontrol('style','popupmenu', 'Units', 'normalized','position',[1.0566*k_s-k_s3  0.895 0.11*k_s 0.04],...
    'string',{'Switch off';'Arduino';'USB2Dynamixel';'OpenCM';'Bluetooth'},'Value',1,'Callback', @BtnPlot,'FontSize',12,...
    'FontName','Book Antiqua','backgroundcolor',[1 1 1],'foregroundcolor' ,[.1 .1 .5]);

% Поле выбора углового шага, на который поворачиваются Dynamixelи 
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.9448*k_s-k_s3  0.795+k_s5 0.114*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Angular step, deg:','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold');
% Область ввода текста 0.04 0.026
AngStep=uicontrol('Style', 'edit', 'Units', 'normalized','Position', [1.0566*k_s-k_s3  0.8+k_s5 0.09*k_s 0.04],...
    'String', '0.024','BackgroundColor','w','FontSize',13,'FontName','Book Antiqua','Tag','edtAngStep');

% Выбор типа мотора
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.924*k_s-k_s3  0.745+k_s5 0.134*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Parameters of motors:','FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold');
% Кнопка перезаписи параметров моторов
RWM=uicontrol('Style', 'togglebutton', 'Units', 'normalized','Position', [1.0566*k_s-k_s3  0.75+k_s5 0.08*k_s 0.04],...
    'BackgroundColor', [255/255,238/255,155/255],'String','OverWrite','FontSize',13,...
    'FontName','Book Antiqua','FontWeight','Bold','Callback', @ReWr,'Tag','ReWrMo');

MDat={'<HTML><font size=+1><center />Motor</HTML>' '<HTML><font size=+1><center />Type</HTML>'...
    '<HTML><font size=+1><center />Speed</HTML>'...
    '<HTML><font size=+1><center />P</HTML>' '<HTML><font size=+1><center />I</HTML>'...
    '<HTML><font size=+1><center />D</HTML>' '<HTML><font size=+1><center />ID</HTML>'};
TypMot= {'№ 1 (Base)' 'Dynamixel' '84' '32' '8' '2'; '№ 2 (Center)' 'Dynamixel' '104' '32' '8' '2';... 
     '№ 3 (Wrist)' 'Dynamixel' '210' '32' '1' '1';  '№ 4 (Wrist2)' 'Dynamixel' '110' '32' '1' '1';  ...
     '№ 5 (Grip)' 'Servo' '' ' ' ' ' ' '};
% TypMot= {'№ 1 (Base)' 'Dynamixel' '84' '32' '6' '0'; '№ 2 (Center)' 'Dynamixel' '104' '32' '6' '0';... 
%      '№ 3 (Wrist)' 'Dynamixel' '210' '32' '1' '1';  '№ 4 (Grip)' 'Servo' '' ' ' ' ' ' '};
TabMot=uitable('Data',TypMot,'Units', 'normalized','Position', [0.90*k_s-k_s3  0.545+k_s5 0.2934*k_s 0.198],...
    'ColumnFormat',({[] {'Dynamixel' 'Servo' 'Disabled'} 'numeric' 'numeric'}),'ColumnName',MDat,'RowName',[],...
    'ColumnEditable',[false true true true true true false],'ColumnWidth',{100 100 50 30 30 30 30},...
    'FontName','Symbol','FontSize',14);

% Отметка учёта перегрузки моторов
MOLC=uicontrol('Style', 'checkbox', 'Units', 'normalized','Position', [0.975*k_s-k_s3  0.502+k_s5 0.154*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String','Motor overload check','FontSize',13,...
    'FontName','Book Antiqua','FontWeight','Bold');%,'Callback',@BtnPlot,'Tag','ReWrMo');

% Кнопки поворота моторов
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.9298*k_s-k_s3  0.460+k_s5 0.2472*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Grip rotation',...
    'FontSize',12,'FontName','Book Antiqua','FontWeight','Bold');
GrRot=uicontrol('Style', 'slider', 'Units', 'normalized','Position', [0.99*k_s-k_s3  0.443+k_s5 0.161*k_s 0.022],...
    'BackgroundColor', [255/255,238/255,155/255],'Min',psmin,'Max',psmax,'Value',90,...
    'Callback',@ValRot,'Tag','GRot');
AngZe = ['Motor №4     ' num2str(psmin) char(hex2dec('B0'))];
AngEn = [num2str(psmax) char(hex2dec('B0'))];
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.89*k_s-k_s3  0.425+k_s5 0.10*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', AngZe,'FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold');
uicontrol('Style', 'text', 'Units', 'normalized','Position', [1.159*k_s-k_s3  0.425+k_s5 0.034*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', AngEn,'FontSize',12,...
    'FontName','Book Antiqua','FontWeight','Bold');

% Управление хватом
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.9322*k_s-k_s3  0.388+k_s5 0.114*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Operation Mode','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold');
OpM=uicontrol('style','popupmenu', 'Units', 'normalized','position',[1.057*k_s-k_s3  0.392+k_s5 0.11*k_s 0.04],...
    'string',{'Manual';'Teleoperation'},'Value',1,'Callback', @GrCo,'FontSize',12,... % 
    'FontName','Book Antiqua','backgroundcolor',[1 1 1],'foregroundcolor' ,[.1 .1 .5]);

% Управление хватом
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.9452*k_s-k_s3  0.348+k_s5 0.114*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Grip Control','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold');
GrCont=uicontrol('style','popupmenu', 'Units', 'normalized','position',[1.057*k_s-k_s3  0.352+k_s5 0.07*k_s 0.04],...
    'string',{'Hold';'Drop';'Stop';'Check';'Rotate'},'Value',3,'Callback', @GrCo,'FontSize',12,...
    'FontName','Book Antiqua','backgroundcolor',[1 1 1],'foregroundcolor' ,[.1 .1 .5]);

% Вывод данных с датчиков силы и расстояния
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.9298*k_s-k_s3  0.364 0.2472*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Data from sensors',...
    'FontSize',14,'FontName','Book Antiqua','FontWeight','Bold');
TabSens=uitable('Data', {'FSR №1' 'on' ' ' 'N'; 'FSR №2' 'on' ' ' 'N'; 'Ultrasonic' 'on' ' ' 'm'},...
    'Units', 'normalized','Position', [0.936*k_s-k_s3  0.27 0.231*k_s 0.099],...
    'ColumnFormat',({[] {'off' 'on'} []}),'ColumnEditable',[false true false false],'ColumnName',[],...
    'RowName',[],'ColumnWidth',{95 70 85 40},'FontName','Book Antiqua','FontSize',14);

% Значение максимальных крутящих моментов
uicontrol('Style', 'text', 'Units', 'normalized','Position', [0.9298*k_s-k_s3  0.225 0.2472*k_s 0.04],...
    'BackgroundColor', [133/255,201/255,181/255],'String', 'Torques, kg*cm','FontSize',14,...
    'FontName','Book Antiqua','FontWeight','Bold');

% TorqName={'<HTML>T<sub>1</sub></HTML>' ' ' ' ' ' ' 64; '<HTML> T<sub>2</sub></HTML>' ' ' ' ' ' ' 31.6;...
%     '<HTML>T<sub>3</sub></HTML>' ' ' ' ' ' ' 16.5;'<HTML>T<sub>4</sub></HTML>' ' ' ' ' ' ' 6.26};
TorqName={'<HTML>T<sub>1</sub></HTML>' ' ' ' ' ' ' 81.6 ' '; '<HTML> T<sub>2</sub></HTML>' ' ' ' ' ' ' 56.1 ' ';...
    '<HTML>T<sub>3</sub></HTML>' ' ' ' ' ' ' 16.5 ' ';'<HTML>T<sub>4</sub></HTML>' ' ' ' ' ' ' 16.5 ' ';...
    '<HTML>T<sub>5</sub></HTML>' ' ' ' ' ' ' 6.26 ' '};
TCN={'<HTML><font size=+1><center />№</HTML>' '<HTML><font size=+1><center />T<SUB>max. est.</SUB></HTML>'...
    '<HTML><font size=+1><center />T<SUB>est</SUB></HTML>' '<HTML><font size=+1><center />T<SUB>real</SUB></HTML>'...
    '<HTML><font size=+1><center />T<SUB>max</SUB></HTML>' '<HTML><font size=+1><center />U<SUB>cur</SUB></HTML>'};
TabMaxTorq=uitable('Data',TorqName,'Units', 'normalized',...
    'Position', [0.887*k_s-k_s3  0.02 0.3164*k_s 0.207],'ColumnWidth',{35 75 75 75 75 65},...
    'ColumnName',TCN,'RowName',[],'FontName','Symbol','FontSize',14);


%% Дополнительные действия
% Скрываем указатель на окно приложения 
set(hF, 'HandleVisibility', 'callback');

axes(ris0); % Переключение на график, отображающий положение манипулятора

end

% Функция построения изображения дрона
function PicDrone

xdr1=0.001*[152.1 29.1 152.1 159.1 166.1 289.1 166.1 166.1 152.1 152.1 173.1 173.1 145.1 145.1 173.1];
ydr1=0.001*[104 108.5 113 126 113 108.5  104 113 113 104 104 93 93 104 104];
xdr0=0.001*[14.5 20.1 -53.7 -173 -173 173 173 53.7 -20.1 -14.5];
ydr0=0.001*[0 48 48 82 93 93 82 48 48 0];

rectangle('Position',0.001*[-14.5,-14.5,29,29], 'Curvature',[1,1]);
p4=plot(xdr1,ydr1,'k',-xdr1,ydr1,'k',xdr0,ydr0,'k');

end

% Функция нажатия на кнопку Plot
function BtnPlot(src,evt)

global q x0 y0

if q==0
    q=1;
    Angl=checkRange; % считывание значений максимального рабочего диапазона манипулятора
    [x0,y0]=StartPoint(Angl(2,3),Angl(1,2)); % зависит от максимального угла theta и минимального угла beta
end

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения
str0 = get(handles.edtStep, 'String'); % берем текст из строки ввода (шаг увеличения координаты h)
h=str2num(str0);

% Считывание координат из строк ввода
str = get(handles.edtX, 'String');
x=str2num(str);
x1=x; % новое положение
x=x0; % предыдущее положение

str2 = get(handles.edtY, 'String');
y=str2num(str2);
y1=y; % новое положение
y=y0; % предыдущее положение

StartApp(x,y,x1,y1)
end

% Функция нажатия на кнопку Up
function UpArrow(src,evt)

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения
str0 = get(handles.edtStep, 'String'); % берем текст из строки ввода (шаг увеличения координаты h)
h=str2num(str0);
% Считывание координат из строк ввода
str = get(handles.edtX, 'String');
x=str2num(str);
x1=x;
str2 = get(handles.edtY, 'String');
y=str2num(str2);
y1=y+h;
StartApp(x,y,x1,y1);
end

% Функция нажатия на кнопку Down
function DownArrow(src,evt)

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения
str0 = get(handles.edtStep, 'String'); % берем текст из строки ввода (шаг увеличения координаты h)
h=str2num(str0);
% Считывание координат из строк ввода
str = get(handles.edtX, 'String');
x=str2num(str);
x1=x;
str2 = get(handles.edtY, 'String');
y=str2num(str2);
y1=y-h;
StartApp(x,y,x1,y1);
end

% Функция нажатия на кнопку Right
function RightArrow(src,evt)

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения
str0 = get(handles.edtStep, 'String'); % берем текст из строки ввода (шаг увеличения координаты h)
h=str2num(str0);
% Считывание координат из строк ввода
str = get(handles.edtY, 'String');
y=str2num(str);
y1=y;
str2 = get(handles.edtX, 'String');
x=str2num(str2);
x1=x+h;
StartApp(x,y,x1,y1);
end

% Функция нажатия на кнопку Left
function LeftArrow(src,evt)

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения
str0 = get(handles.edtStep, 'String'); % берем текст из строки ввода (шаг увеличения координаты h)
h=str2num(str0);
% Считывание координат из строк ввода
str = get(handles.edtY, 'String');
y=str2num(str);
y1=y;
str2 = get(handles.edtX, 'String');
x=str2num(str2);
x1=x-h;
StartApp(x,y,x1,y1);
end

% Считывания положения слайдера
function ValRot(src,evt)

global GrRot TabAng

ValAng=get(GrRot,'Value');
AngRot=get(TabAng,'Data');
AngRot(5,2)={int32(ValAng)};
set(TabAng,'Data',AngRot);
GripRotate;

end

% Функция нажатия на кнопку Help
function HelpApp(src,evt)

% Создаем графическое окно с тегом figure
HelpF = figure('Name', 'Help', 'NumberTitle','off','MenuBar', 'none', 'Units', 'characters','Position', [100 0 155.526 150],...
    'Color', [255/255,255/255,255/255],'Tag', 'HelpFigure');
% Вставка изображения с описанием 
handles.banner = imread('Help.png'); 
ris2=axes('Units', 'normalized','Position',[0.05 0.05 0.9 0.9]);
image(handles.banner);
set(ris2,'visible','off','Units', 'pixels');
end

% Функция закрытия приложения
function CloseApp(src,evt)

global DevCon CountArd CountDyn Ard CountExit p

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора

CountExit=1;

if SwC~=1
    ChButs(SwC); % Мониторинг текущих параметров датчиков и моторов
end

if SwC==3 % USB2Dynamixel
    writeDigitalPin(Ard,'D3',0); % отключение питания
    closePort(p); % Close port
    unloadlibrary('dxl_x64_c');
    CountDyn=0;
end

if SwC==2 % Arduino
    clear serv Ard % Отключение Arduino
    CountArd=0;
end

pause(0.1);

clc
clear all
clear all hidden
close all hidden
end

%% Блок вспомогательных функций
% Первичная функция
function StartApp(x,y,x1,y1)

global DevCon Start

Proc(x,y,x1,y1); % Обработка введённого положения

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора

if (SwC>=2)
    ChButs(SwC); % Мониторинг текущих параметров датчиков и моторов
end

ElapsedSens = cputime - Start;

end

% Распределение заданий в зависимости от подключения
function Proc(x,y,x1,y1)

global DevCon CountArd CountDyn CountOCM CountBT serv Ard CountCalc ...
    TabSens Dxl IDm InitData p

CountCalc=1; % Счётчик для отслеживания начала расчёта

InitData=PlotLocation(x,y,x1,y1);
%ElapsedCalc = cputime - Start
pause(0.1);
SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора

if (SwC==1) && ((CountArd~=0) || (CountDyn~=0))
    closePort(p); % Close port
    unloadlibrary('dxl_x64_c'); % отключение библиотеки для моторов Dynamixel
    writeDigitalPin(Ard,'D3',0); % отключение питания
   
    % Удаление показаний сенсоров
    Tsens=get(TabSens,'Data');
    TSens(1,3)={' '};
    TSens(2,3)={' '};
    TSens(3,3)={' '};
    set(TabSens,'Data',TSens);
           
    CountArd=0;
    CountDyn=0;
    CountOCM=0;
    
    clear serv Ard IDm Dxl % Отключение Arduino
end

if (SwC==2) && (CountArd==0)
    [Ard,serv]=ArdSwitch(SwC); % Включение Arduino
else
    if ((CountOCM~=0) || (CountDyn==1)) &&  (SwC==2) && (CountArd==1)
        closePort(p); % Close port
        unloadlibrary('dxl_x64_c'); % отключение библиотеки для моторов Dynamixel
        writeDigitalPin(Ard,'D3',0); % отключение питания

        CountDyn=2;
        CountOCM=0;
        
        clear Dxl IDm %p % Отключение Arduino
    end
end
%ElapsedArd = cputime - Start

if (SwC==3) && ((CountDyn==0) || (CountDyn==2))
    if CountDyn==2
        writeDigitalPin(Ard,'D3',1); % отключение питания
    end
    DynoSwitch(SwC); % Включение USB2Dynamixel
    if IDm==0
        set(DevCon,'Value',2);
    end
end
%ElapsedDyno = cputime - Start

if (SwC==4) && (CountOCM==0)
    Dxl=OpenCMCon(SwC); % Включение OpenCM
end

if (SwC==5) && (CountBT==false)
    BTCon(SwC); % Управление по Bluetooth
end

pause(0.1);

if (SwC>=2)
    CountCalc=0;
    WriteAngles(SwC,InitData,Ard,serv); % Запись текущих положений на моторы
end

end

% Функция проверки нажатия кнопок
function ChButs(SwC)

global RArr UArr LArr DArr Pplo GrHo GrDr GSt De De2 ChOb TabMot Ard...
    CountExit ChSt CountCalc Co IDm x0 ClAp RWM %Dxl Us

for k=1:1:10000
    %Start = cputime; % измерение времени работы функции
    
    WrData;
    
    % Прекращение функции при нажатии закрыть приложение
    %chb=exist('ClAp')
    if CountExit==1%0 || chb==2
        break
    end
    
    if (get(De,'Value')==1) || (get(De2,'Value')==1)|| ChSt==1 ...
            || (get(ClAp,'Value')==1) || (get(RWM,'Value')==1) || (SwC==1)
        break
    end
    
    ChB(1)=get(UArr,'Value');
    ChB(2)=get(LArr,'Value');
    ChB(3)=get(RArr,'Value');
    ChB(4)=get(DArr,'Value');
    ChB(5)=get(Pplo,'Value');
    
    for ii=1:1:length(ChB)
        if ChB(ii)==1
            CB=0;
        else
            CB=1;
        end
    end
    
    if CB==0
        break
    else
        set(UArr,'Value',0);
        set(LArr,'Value',0);
        set(RArr,'Value',0);
        set(DArr,'Value',0);
        set(Pplo,'Value',0);
        set(GSt,'Value',0);
        set(GrHo,'Value',0);
        set(GrDr,'Value',0);
        set(ChOb,'Value',0);
    end
    %Elapsed = cputime - Start % измерение времени работы функции
    pause(1)%0.2);
    
    if (CountCalc==1)
        break
    else
        if ((k>2) || (Co>0))
            Otkat=ChObstacle; % Проверка избегания столкновения с препятствием
            if Otkat~=0
                Otkat=0;
                break
            end
        end
    end
    
    
    % Считывание данных
    if SwC>=2
        SensData(Ard);
    end
    
    if SwC==3
        [kMrD,ChMot]=NumbMot({'Dynamixel'}); % Проверка количества моторов Dynamixel
        for i=1:kMrD
            if strcmp({'Dynamixel'},ChMot(i,2))==1
                DynoData(IDm(i),i); % Считывание данных моторов Dynamixel
            end
        end
    end
    
end

end

% Проверка наличия препятствия
function Otkat=ChObstacle

global yach CoorX CoorY TabMaxTorq Co compres DatTorq x0 y0 Steph MOLC

chcond=get(MOLC, 'Value');

if chcond~=0
    % Считывание текущих координат
    str = get(CoorX, 'String');
    x=str2num(str);
    str2 = get(CoorY, 'String');
    y=str2num(str2);
    
    % Считываем шаг изменения координат
    str0 = get(Steph, 'String');
    h=0.03; % Шаг, на который отступает манипулятор при перегрузке
    
    % Считывание значений максимальных и вычисленных моментов
    TMT=get(TabMaxTorq,'Data');
    T1max=cell2mat(TMT(1,5));
    T2max=cell2mat(TMT(2,5));
    T1est=cell2mat(TMT(1,3));
    T2est=cell2mat(TMT(2,3));
    
    % Проверка изменения положения манипулятора
    npo=1;
    if (x==x0) || (y==y0)
        npo=0;
    end
    
    % Проверка превышения допустимой нагрузки
    mvt=0;
    if (DatTorq(yach,1)/T1max>0.96) || (DatTorq(yach,2)/T2max>0.90) || ...
            (DatTorq(yach,1)/T1est>1.25) || (DatTorq(yach,2)/T2est>1.5)
        mvt=1;
    end
    
    if yach>5
        if Co>=1
            compres=checkT(DatTorq,yach,Co,1.45);
        else
            compres=checkT(DatTorq,yach,Co,1.35);
        end
        
        if (Co<5) && ...
                (((npo==1) && (mvt==1)) || ((npo~=1) && ((compres==1) || (mvt==1)))...
                || ((Co>=1) && ((compres==1) || (mvt==1)))) % Новое положение и перегрузка
            Co=Co+1; % изменение значения счётчика
            x1=x-h;
            y1=x1*y/x;
            Otkat=1;
            StartApp(x,y,x1,y1);
        else
            if Co>=5
                Co=0;
                x1=0.06;
                y1=-0.09;
                Otkat=1;
                StartApp(x,y,x1,y1);
            else
                Co=0;
                Otkat=0;
            end
        end
    else
        Otkat=0;
    end
else
    Co=0;
    Otkat=0;
end

end

% Функция сравнения крутящих моментов
function compres=checkT(T,ind,Co,Coef)

if (T(ind,1)/T(ind-(1+Co),1)>Coef) || (T(ind,2)/T(ind-(1+Co),2)>Coef)
    compres=1;
else
    compres=0;
end

end

% Cчитывание данных и запись в файл
function WrData

global TabSens TabAng TabMaxTorq Start yach CoorX CoorY...
    CountName filename TabMass mcc err massc DatTorq ExpName

if CountName==0
    filename=ChangeName;
    CountName=CountName+1;
end

A = {'Time','X, m','Y, m','FSR №1, N','FSR №2, N','Distance, m',...
    'alpha, deg', 'beta, deg','theta, deg', 'phi, deg','T1, m','T2, m',...
    'T3, m','U1, V','U2, V','U3, V','mcc, kg','mcr, kg','error, %','mcav, kg'};
sheet = 1;
xlswrite(filename,A,sheet,'B2');

nY='B';
yach=yach+1;
numYach=[nY num2str(yach)];
nYa=['V' num2str(yach)];
MassData=zeros(1,12);

% запись времени от начала отсчёта
MassData(1) = cputime - Start;

% Считывание координат из строк ввода
%handles = guihandles(src); % запись в структуру handles указателей на объекты приложения
str = get(CoorX, 'String');
MassData(2)=str2num(str);
str2 = get(CoorY, 'String');
MassData(3)=str2num(str2);

Tsens=get(TabSens,'Data'); % данные с датчиков
MassData(4)=cell2mat(Tsens(1,3));
MassData(5)=cell2mat(Tsens(2,3));
MassData(6)=cell2mat(Tsens(3,3));

angles=get(TabAng,'Data'); % запись углов без учёта поворота гриппера
MassData(7)=cell2mat(angles(1,2));
MassData(8)=cell2mat(angles(2,2));
MassData(9)=cell2mat(angles(3,2));
MassData(10)=cell2mat(angles(4,2));

TMT=get(TabMaxTorq,'Data'); % значения крутящих моментов и данных о напряжениях на моторах
MassData(11)=cell2mat(TMT(1,4));
DatTorq(yach,1)=MassData(11);
MassData(12)=cell2mat(TMT(2,4));
DatTorq(yach,2)=MassData(12);
MassData(13)=cell2mat(TMT(3,4));
DatTorq(yach,3)=MassData(13);
MassData(14)=cell2mat(TMT(1,6));
MassData(15)=cell2mat(TMT(2,6));
MassData(16)=cell2mat(TMT(4,6));

MassData(17)=mcc;

M=get(TabMass,'Data');
MassData(18)=cell2mat(M(1,2));

MassData(19)=err;
MassData(20)=massc;

ttt={get(ExpName,'String')};

xlswrite(filename,MassData,sheet,numYach);
xlswrite(filename,(ttt),sheet,nYa);

end

% Создание нового файла для записи данных
function filename=ChangeName

%filename = 'D:\Yashin\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\testdata.xlsx';
filename = 'D:\Учёба\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\testdata.xlsx';

% Проверка существования имени
%path='D:\Yashin\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\';
path='D:\Учёба\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\';
name='testdata';
ext='.xlsx';
%i=xlsread('D:\Yashin\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\testdata.xlsx',1,'A1:A1'); % считывание номера предыдущего эксперимента
i=xlsread('D:\Учёба\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\testdata.xlsx',1,'A1:A1'); % считывание номера предыдущего эксперимента
chee=1;
while chee~=0
    chee=exist(filename);
    if chee~=0
        filename=[path name num2str(i) ext];
        i=i+1;
    end
end

%xlswrite('D:\Yashin\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\testdata.xlsx',i,1,'A1'); % запись номера текущего эксперимента
xlswrite('D:\Учёба\SkolTech\Ph.D\Дрон с манипулятором\Расчёты\Experiment data\testdata.xlsx',i,1,'A1'); % запись номера текущего эксперимента

end

% Проверка нахождения параметра в нужном диапазоне
function P=ParamCheck(P,MinP,MaxP)
if P<MinP
    P=MinP;
else
    if P>MaxP
        P=MaxP;
    end
end
end

% Проверка знаков при координатах
function [znx,zny]=Octothorpe(x,y,x0,y0)

% Определение знака при координате X
if x~=0
    znx=abs(x)/x;
else
    if abs(x0)/x0<0
        znx=1;
    else
        znx=-1;
    end
end

% Определение знака при координате Y
if y~=0
    zny=abs(y)/y;
else
    if abs(y0)/y0<0
        zny=1;
    else
        zny=-1;
    end
end

end

% Вычисление длины по теореме косинусов
function len=TeorCos(a,b,angle)
len=sqrt(a^2+b^2-2*a*b*cosd(angle));
end

%% Блок расчёта параметров
% Функция с исходными данными
function InputData

clc
clear all

global g l1 l2 l3 z cm1 cm2 cm3 arm4 Z1 Z2 mc ms0 ms1 ms2 ms3 ms4 ml1 ml2...
    mx mkp fi q ChAn ChSt CountArd CountDyn CountOCM CountBT CountInvM...
    CountName CountExit T0calc CalibT mmc gamma yach err massc CountMot...
    Co compres almin almax bemin bemax temin temax psmin psmax

g=9.80665; % м/с2, ускорение свободного падения

l1 = 0.27698; %0.274379; %0.294644; %0.2989; %0.274; % м, длина звена № 1
l2 = 0.259219; %0.328827; %0.330082; %0.30644; %0.310; % м, длина звена № 2
l3 = 0.058; % м, расстояние от оси сервомотора № 2 до центра масс сервомотора № 3
%0.045;  % м, длина звена № 3

z=0.0313; %0.0398; %0;% м, смещение первого звена по вертекали

cm1=0.113643; %0.185821; %0.119571; %0.139542;%0.300608; % м, расстояние от оси сервомотора № 0 до центра масс звена 1
cm2=0.097669; %0.196804; %0.139379; %0.157359;%0.13164; % м, расстояние от оси сервомотора № 1 до центра масс звена 2
cm3=0.09385; %0.065027; %0.061421; % м, расстояние от оси сервомотора № 2 до центра масс хвата с грузом

arm4=0.050171;%0.075; % м, максимальное расстояние от оси шестерни № 2 до центра масс груза

Z1=13; % колич1ество зубьев шестерни № 1
Z2=24; % количество зубьев шестерни № 2

% Масса указана без учёта веса крепежа, проводов и датчиков
mc=0;%0.035; %0.24; % кг, масса груза
ms0=0.153; %0.072;%0.063; % кг, масса сервомотора № 0 (база)
ms1=0.126; %0.056;%0.063; % кг, масса сервомотора № 1
ms2=0.0535; %0.063; %0.056;%0.021; % кг, масса сервомотора № 2
ms3=0.0535; %0.056; %0.0158;%0.0078; % кг, масса сервомотора № 3
ms4=0.063; % кг, масса сервомотора № 4 (хват)
ml1=0.075+0.0035+6*0.0005+4*0.0003+0.0024*6*l1/(l1+l2); %0.055;%0.031; % кг, масса звена № 1, 0,0035 - подшипник
ml2=0.063+0.0035+6*0.0005+4*0.0003+0.0024*6*l2/(l1+l2); %0.059;%0.037; % кг, масса звена № 2
mx=0.063+8*(0.0016+0.0001)+6*0.0002+4*0.0028+3*0.0005; % кг, масса хвата
mkp=0.001; % кг, масса крестовины

% Грузы: 0.2719 - аккумулятор шуруповёрта, 0.2158 - рулетка, 0.169 - коробка с металлом, 0.1641 - коробка с MX-106, 0.0784 - деревянный куб,
% 0.0777 - мини тиски, 0.0419 - белый пластиковый куб со штрихкодом, 0.0399 - белый пластиковый куб, 0.0355 - оранжевый пластиковый параллелепипед
mmc=[0.1641 0.0784 0.0419 0.0399 0.0355]; % массив масс грузов
% T0calc=[4.39436282742831 1.66369414137586;6.28996744709001 1.29328297942829;5.34510282481346 1.26258662873457;5.65453891492921 1.47837488313661;5.75842427841379 1.26966687161803;6.29996138872704 1.46176397089384;5.82744050297219 1.28794584751303;6.43215609001060 1.25780570602980;6.53496420136355 1.20525165660815;6.40395118096490 1.10046522276335;6.74343894012486 1.27487974248199;6.50314383755538 1.31723764513101;6.27652951717607 1.95984425938905;5.59718986879193 2.10292789116791;5.51514775740210 1.69826563101890;4.85945416899317 1.61161907072253];
T0calc=[4.75962946817786 2.20435919790758;6.24501743679163 1.53428509154316;7.54047079337402 1.65119877942459;7.32604402789887 1.81147558849172;7.41211857018309 1.60162380122058;7.36339363557106 1.99969485614647;7.59656931124673 1.64707933740192;7.64262641673932 1.65014167393200;7.72721883173496 1.59739537925022;7.88747384481255 1.63564734088928;7.96276591107236 1.58158238884045;7.95350261551874 1.65859851787271;7.75230383609416 2.24620749782040;7.46591979075850 2.23917829119442;7.03169354838710 2.20717088055798;6.41835222319093 2.15548169136879];
CalibT=[52.0000000000000;57.7295779513083;63.4591559026165;69.1887338539247;74.9183118052329;80.6478897565412;86.3774677078494;92.1070456591577;97.8366236104659;103.566201561774;109.295779513082;115.025357464391;120.754935415699;126.484513367007;132.214091318315;137.943669269623];

almin=0;
almax=200;
bemin=0;
bemax=180;
temin=0;
temax=180;
psmin=0;
psmax=180;
fi=90; % градусов, угол раскрытия хвата
gamma=25; % максимальный угол наклона второго звена над плоскостью дрона

q=0; % счётчик для первого вывода графика
ChAn=0; % счётчик для первой проверки совпадения допустимых диапазонов
ChSt=0; % счётчик выключения хвата
CountArd=0; % счётчик включения Arduino
CountDyn=0; % счётчик включения USB2Dynamixel
CountOCM=0; % счётчик включения Open CM
CountBT=false; % счётчик включения Bluetooth
CountMot=0; % счётчик включения моторов
CountInvM=0; % счётчик расчёта обратной матрицы
CountName=0; % счётчик записи в файл
CountExit=0; % счётчик выхода из приложения
yach=2; % счётчик строк
Co=0; % счётчик отступления от препятствия
compres=0; % счётчик наличия повторной перегрузки

err=0; % значение ошибки вычисления массы груза
massc=0; % усреднённое значение массы груза

end

% Функция построения положения хвата
function PicGrip(xg0,yg0,fi)

% Общая часть
xgr(1,1)=xg0;
ygr(1,1)=yg0;
xgr(1,2)=xgr(1,1)+0.027611;
ygr(1,2)=ygr(1,1)+0.012157;

% Верхняя и нижняя части
for i=1:2
    xgr(i,3)=xgr(1,1)+0.047798;
    ygr(i,3)=ygr(1,1)+(-1)^(i+1)*0.0135;
    xgr(i,4)=xgr(i,3)+0.031*cosd(fi);
    ygr(i,4)=ygr(i,3)+(-1)^(i+1)*0.031*sind(fi);
    xgr(i,5)=xgr(i,3)+0.022;
    ygr(i,5)=ygr(1,1)+(-1)^(i+1)*0.005255;
    xgr(i,6)=xgr(i,5)+0.031*cosd(fi);
    ygr(i,6)=ygr(i,5)+(-1)^(i+1)*0.031*sind(fi);
    xgr(i,7)=xgr(i,6)+0.034123;
    ygr(i,7)=ygr(i,6);
end

% Дополнительные точки эскиза корпуса хвата
xgr(1,8)=xgr(1,1)+0.003131;
ygr(1,8)=ygr(1,1)+0.029;
ygr(2,8)=ygr(1,1)-0.029;
xgr(1,9)=xgr(1,8)+0.028584;

% Изображение хвата
plot([xgr(1,1),xgr(1,2)],[ygr(1,1),ygr(1,2)],'k',...
    [xgr(1,3),xgr(1,4)],[ygr(1,3),ygr(1,4)],'k',...
    [xgr(1,5),xgr(1,6)],[ygr(1,5),ygr(1,6)],'k',...
    [xgr(1,4),xgr(1,6),xgr(1,7)],[ygr(1,4),ygr(1,6),ygr(1,7)],'k-o',...
    [xgr(2,3),xgr(2,4)],[ygr(2,3),ygr(2,4)],'k',...
    [xgr(2,5),xgr(2,6)],[ygr(2,5),ygr(2,6)],'k',...
    [xgr(2,4),xgr(2,6),xgr(2,7)],[ygr(2,4),ygr(2,6),ygr(2,7)],'k-o',...
    'LineWidth',3,'MarkerSize',2)

% Отображение зубчатого зацепления
rectangle('Position',[(xgr(1,3)-0.0135),(ygr(1,3)-0.0135),(0.0135)*2,(0.0135)*2], 'Curvature',[1,1])
rectangle('Position',[(xgr(2,3)-0.0135),(ygr(2,3)-0.0135),(0.0135)*2,(0.0135)*2], 'Curvature',[1,1])
rectangle('Position',[(xgr(1,2)-0.006732),(ygr(1,2)-0.006732),(0.006732)*2,(0.006732)*2], 'Curvature',[1,1])

% Отображение эскиза корпуса хвата
plot([xgr(1,1),xgr(1,8),xgr(1,9),xgr(1,5),xgr(1,5),xgr(1,9),xgr(1,8),xgr(1,1)],...
    [ygr(1,1),ygr(1,8),ygr(1,8),ygr(1,5),ygr(2,5),ygr(2,8),ygr(2,8),ygr(1,1)],'k',0,0.08,'b x')
PicDrone;
end

% Вычисление углов Beta и Theta, править!
function [beta,theta]=CalcAngl(x,y,Angl)

syms t bet alf a b c d ff
global CountInvM l1 l2 z beta1
%StartLaLaLa = cputime;
if CountInvM==0
    CountInvM=1;
    WKin = waitbar(0,'Computation of inverse kinematics'); % Окно ожидания расчёта обратной матрицы
    
    % Запись матриц перехода между системами координат
    A(:,:,1)=[cos(t) -sin(t) 0 0; sin(t) cos(t) 0 0; 0 0 1 0; 0 0 0 1];
    A(:,:,2)=[1 0 0 a; 0 1 0 0; 0 0 1 0; 0 0 0 1];
    A(:,:,3)=[1 0 0 0; 0 1 0 ff; 0 0 1 0; 0 0 0 1];
    A(:,:,4)=[cos(bet) -sin(bet) 0 0; sin(bet) cos(bet) 0 0; 0 0 1 0; 0 0 0 1];
    A(:,:,5)=[1 0 0 b; 0 1 0 0; 0 0 1 0; 0 0 0 1];
    A(:,:,6)=[cos(alf) -sin(alf) 0 0; sin(alf) cos(alf) 0 0; 0 0 1 0; 0 0 0 1];
    
    % Цикл для вычислления обратной матрицы, независимо от количества матриц
    T=A(:,:,1);
    sz=size(A);
    if sz(3)>=2
        for i=2:sz(3)
            T=T*A(:,:,i);
        end
    end
    T=simplify(T);
    
    % Формирование кравнения для вычисления угла beta
    if simplify(T(1,4)^2+T(2, 4)^2)~=a^2
        eq=simplify(T(1,4)^2+T(2, 4)^2-c^2-d^2);
    else
        eq=simplify(T(1,4)-c^2);
    end
    
    beta1=collect(simplify(solve(eq,bet,'Real', true))) % вычисление угла Beta
    t1=collect(simplify(solve(eq,t,'Real', true))); % вычисление угла Beta
    
    waitbar(1,WKin,'Successfully ;-)'); % Окно ожидания расчёта обратной матрицы
    close(WKin); % Закрытие окна расчёта обратной матрицы
    
end
%ElapsedLaLaLa = cputime - StartLaLaLa

beta0=double(subs(beta1,[a b c d ff],[l1 l2 x y z]))*180/pi;
%ElapsedLol = cputime - StartLaLaLa
%beta0=double(beta0)*180/pi
% Выбор значения угла Beta в диапазоне от 0 до 180
j=1;
for i=1:length(beta0)
    if fix(beta0(i)*1e3)==0
        beta(j)=0;
        j=j+1;
    else
        if (beta0(i)>0) && (beta0(i)<=180)
            beta(j)=beta0(i);
            j=j+1;
        else
            if fix(beta0(i))==-180
                beta(j)=180;
                j=j+1;
            else
                if fix(beta0(i))>180
                    beta(j)=999;
                    j=j+1;
                end
            end
        end
    end
    i=i+1;
end

chb=exist('beta');

if chb==0 || chb==2
    beta=-999;
end

beta0=real(beta);

% Вычисление угла theta
k1=l2*cosd(beta0)+l1;
k2=l2*sind(beta0)+z;

theta0=-(atan2d(y,x)-atan2d(k2,k1));

% Проверка значения угла Theta в диапазоне от 0 до 180
j=1;
for i=1:length(theta0)
    if (fix(theta0(i))>=Angl(1,3)) && (fix(theta0(i))<=Angl(2,3))
        theta=theta0(i);
        beta=beta0(i);
        i=length(beta0);
    end
    i=i+1;
end

if exist('theta')==0
    theta=999;
end

if length(theta)>1 || length(beta)>1
    theta=theta(1);
    beta=beta(1);
end

%ElapsedOlololo = cputime - StartLaLaLa
end

% Функция вычисления положения манипулятора, править!
% Порядок данных в массиве InitData: theta, beta, alpha, phi, gamma
function InitData=PlotLocation(x,y,x1,y1)

global q l1 l2 z fi TabAng CoorY CoorX choo ChaCond TabMaxTorq xa ya...
    xc yc arm123x arm123y x0 y0 xp yp

xp=x0;
yp=y0;
%% Получение исходной информации
%Start2 = cputime; % измерение времени работы функции
Angl=checkRange; % Получение информации о рабочем диапазоне манипулятора

% Величины углов в предыдущей точке
angles0=get(TabAng,'Data');
[rAng,cAng]=size(angles0);
for i=1:rAng
    if i>=4
        InitData(i)=cell2mat(angles0(i,2));
    else
        InitData(i)=cell2mat(angles0(4-i,2));
    end
end

% Запись исходного положения
if q==0
    q=1;
    [x0,y0]=StartPoint(Angl(2,3),Angl(1,2)); % поиск координат манипулятора при минимальных значениях углов beta и theta
else
    x0=x;
    y0=y;
end

%% Проверка нахождения координат в рабочем диапазоне манипулятора
% Запись введённого положения
x2=x1;
y2=y1;

% Считывание информации о приоритетной координате
val = get(choo,'Value'); % Значения: 1 - нет приоритета, 2 - X, 3 - Y

% Считывание информации о наличии ограничений связанных с креплением манипулятора к дрону
Sw = get(ChaCond,'Value');

% Проверка значений координат, чтобы не превышали допустимые значения X и Y
if val~=1
    x1=ParamCheck(x1,Angl(1,5),Angl(2,5));
    y1=ParamCheck(y1,Angl(1,6),Angl(2,6));
else
    if val == 1 % Возврат к предыдущим координатам в случае ввода координат вне допустимого диапазона
        if (x1<Angl(1,5)) || (x1>Angl(2,5)) || (y1<Angl(1,6)) || (y1>Angl(2,6))
            x1=x0;
            y1=y0;
        end
    end
end

% Проверка координат в связи с ограничением длины звеньев
if sqrt(x1^2+y1^2)<=(sqrt(l1^2+z^2)+l2)
    x=x1;
    y=y1;
else
    [znx,zny]=Octothorpe(x1,y1,x0,y0);
    if val == 2 % Выбрана ось X, как приоритетная
        x=x1;
        y=zny*sqrt((sqrt(l1^2+z^2)+l2)^2-x1^2);
    else
        if val == 1 % Возврат к предыдущим координатам в случае ввода координат вне допустимого диапазона
            x=x0;
            y=y0;
        else
            if val == 3 % Выбрана ось Y, как приоритетная
                y=y1;
                x=znx*sqrt((sqrt(l1^2+z^2)+l2)^2-y1^2);
            end
        end
    end
end
% 1
x;
y;

[x,y]=CheckGeom(Sw,val,x,y,x0,y0); % Дополнительная проверка из-за ограничения связанного с наличием дрона
% 2
x;
y;

%% Вычисление углов между звеньями по координатам
% Определение углов beta и theta
[db,dt]=CalcAngl(x,y,Angl);
db=180-db;

[znx,zny]=Octothorpe(x,y,x0,y0);

p=0; % Счётчик возврата к начальной точке
imp=0; % Счётчик возврата недостижимости новой точки

% Проверка нахождения угла beta в рабочем диапазоне
if (db<Angl(1,2)) || (db>Angl(2,2))
    while (db<Angl(1,2)) || (db>Angl(2,2)) || p==0
        if val~=1
            db=ParamCheck(db,Angl(1,2),Angl(2,2));
            c2=cosd(180-db);
            r=TeorCos(sqrt(l1^2+z^2),l2,db+atand(z/l1));
        end
        
        if val==1 % Отсутстувует пересчёт координат, возврат к предыдущим координатам
            x=x0;
            y=y0;
            p=1;
        else
            if val==2 % Приоритет координата X
                y=zny*sqrt(r^2-x^2);
            else
                if val==3 % Приоритет координата Y
                    x=znx*sqrt(r^2-y^2);
                end
            end
            [x,y]=CheckGeom(Sw,val,x,y,x0,y0); % Дополнительная проверка из-за ограничения связанного с наличием дрона
        end
        
        [db,dt]=CalcAngl(x,y,Angl);
        db=180-db;
        
        imp=imp+1; % подсчёт количества итераций
        
        if imp==50 % возвращение к предыдущей точке, если не удаётся достигнуть нового значения
            x=x0;
            y=y0;
            p=1;
        end
    end
end

%3
x;
y;

[znx,zny]=Octothorpe(x,y,x0,y0);

if p~=1 % Проверка нахождения угла theta в рабочем диапазоне, если не произошёл возврат к исходным координатам
    if (dt<Angl(1,3)) || (dt>Angl(2,3))
        while (dt<Angl(1,3)) || (dt>Angl(2,3)) || p==0
            if val~=1
                dt=ParamCheck(dt,Angl(1,3),Angl(2,3));
            end
            
            if val==1 % Отсутстувует пересчёт координат, возврат к предыдущим координатам
                x=x0;
                y=y0;
                p=1;
            else
                if val==2 % Приоритет координата X
                    y=sqrt(l2^2-(-znx*y-sqrt(l1^2+z^2)*cosd(180-dt-atand(z/l1)))^2)-sqrt(l1^2+z^2)*sind(180-dt-atand(z/l1));
                else
                    if val==3 % Приоритет координата Y
                        x=sqrt(l2^2-(-zny*y-sqrt(l1^2+z^2)*sind(180-dt-atand(z/l1)))^2)-sqrt(l1^2+z^2)*cosd(180-dt-atand(z/l1));
                    end
                end
                [x,y]=CheckGeom(Sw,val,x,y,x0,y0); % Дополнительная проверка из-за ограничения связанного с наличием дрона
            end
            
            [db,dt]=CalcAngl(x,y,Angl);
            db=180-db;
            
            imp=imp+1; % подсчёт количества итераций
            
            if imp==50 % возвращение к предыдущей точке, если не удаётся достигнуть нового значения
                x=x0;
                y=y0;
                p=1;
            end
        end
    end
end

%4
x;
y;

% Определение угла alfa при параллельности полу конечного звена
da=db+dt-90;
if da>Angl(2,1) || da<Angl(1,1)
    x=x0;
    y=y0;
    dt=InitData(1);
    db=InitData(2);
    da=InitData(3);
end   

% Перезапись начальных координат
x0=x;
y0=y;

% Запись полученных координат в приложение
set(CoorX,'string',x);
set(CoorY,'string',y);

% Запись полученных углов в таблицу
datAng=get(TabAng,'Data');
datAng(2,2)={db};
datAng(3,2)={dt};
datAng(1,2)={da};
set(TabAng,'Data',datAng);

da;
db;
dt;
fi=cell2mat(datAng(4,2)); % считывание текущего положения угла phi

% Координаты звеньев
LinkCoord=CalcCoord(dt,db,da);
for i=1:4
    xc(i)=LinkCoord(i,1);
    yc(i)=LinkCoord(i,2);
end
%ElapsedAng = cputime - Start2

%% Рассчёт крутящих моментов
[T0,T1,T2,T3,arm123x,arm123y]=CalcTorq(db,dt);

TMT=get(TabMaxTorq,'Data');
TMT(1,3)={T0};
TMT(2,3)={T1};
TMT(3,3)={T2};
TMT(5,3)={T3};
set(TabMaxTorq,'Data',TMT);

%% Вывод графической информации
% Изображение текущего положения манипулятора и его центра масс на графике

cla

hold on

p1=plot(xa,ya,'g','LineWidth',5); % Изобрачение рабочей области манипулятора
p2=plot(xc,yc,'k-o','LineWidth',3,'MarkerSize',4); % Изображение текужего положения манипулятора
p3=plot(arm123x,arm123y,'r x','LineWidth',2,'MarkerSize', 10); % Изображение центра масс манипулятора
p4=plot(0,0.08,'b x','LineWidth',2,'MarkerSize', 10); % Изображение центра масс дрона
PicDrone;

PicGrip(xc(4),yc(4),fi);

leg=legend([p1 p2 p3 p4],'Work Area','Manipulator','Mass center of manipulator','Mass center of drone');
%legend('boxoff');
set(leg,'FontSize',14,'FontName','Book Antiqua','FontWeight','Bold','Location','NorthWest');
%ElapsedAll = cputime - Start2

end

% Функция считывания введённых диапазонов углов и координат и проверки их нахождения в допустимых диапазонах
% Angl состоит из следующих данных: Min,Max - 1 и 2; alfa,beta,theta,x,y - 1..5
function Angl=checkRange

global TabAngles TabLength ChaCond l1 l2 z ChAn xa ya Angl0 gamma

% Первая проверка допустимых диапазонов
if ChAn==0
    Angl=get(TabAngles,'Data');
    Angl0=Angl;
    ChAn=1;
else
    Angl=get(TabAngles,'Data');
end    

% Запись прошлых значений длин звеньев и считывание новых длин
l10=l1;
l20=l2;
TL=get(TabLength,'Data');
l1=cell2mat(TL(1,2));
l2=cell2mat(TL(2,2));

compAngl=sum(sum(Angl~=Angl0)); % проверка изменения диапазона

if (compAngl>0) || (l1~=l10) || (l2~=l20) || (ChAn==1)  % Костыль
    
    % Проверка рабочего диапазона углов alpha, beta и theta
    RangAng=[-70 340; 0 180; 0 180]'; % максимально допустимые значения углов
    for i=1:2
        for j=1:3
            Angl(i,j)=ParamCheck(Angl(i,j),RangAng(1,j),RangAng(2,j));
        end
    end
    
    % Проверка рабочего диапазона координаты Х
    % Определение минимального значения Х
    if Angl(1,2)>=360-2*Angl(2,3)-Angl(2,2) % betaMin>=360-2*tetaMax-betaMax
        [Angl(1,5),yM]=CalcPos(Angl(2,3),Angl(2,2)); % xMin=l1*cosd(-tetaMax)-l2*cosd(betaMax+tetaMax)
    else
        [Angl(1,5),yM]=CalcPos(Angl(2,3),Angl(1,2)); % xMin=l1*cosd(-tetaMax)-l2*cosd(betaMin+tetaMax)
    end
    
    % Определение максимального значения Х (выполняется при thetaMin+atand(z/l1))
    if (Angl(1,2)<=(180-Angl(1,3))) && (Angl(2,2)>=(180-Angl(1,3))) % (betaMin<(180-tetaMin)) && (betaMax>(180-tetaMin))
        Angl(2,5)=l1*cosd(-Angl(1,3)-atand(z/l1))+z*cosd(-90+Angl(1,3)+atand(z/l1))+l2; % xMax=l1*cosd(-tetaMin)+l2
    else
        if Angl(1,2)>180-Angl(1,3) %betaMin>360-tetaMin
            [Angl(2,5),yM]=CalcPos(Angl(1,3)+atand(z/l1),Angl(1,2)); % xMax=l1*cosd(-tetaMin)-l2*cosd(betaMin+tetaMin)
        else
            if Angl(2,2)<180-Angl(1,3) %betaMin>360-tetaMin
                [Angl(2,5),yM]=CalcPos(Angl(1,3)+atand(z/l1),Angl(2,2)); % xMax=l1*cosd(-tetaMin)-l2*cosd(betaMax+tetaMin)
            end
        end
    end

    % Проверка рабочего диапазона координаты Y
    % Определение минимального значения Y
    if Angl(1,3)>90 && Angl(2,3)>90 % tetaMin>90 && tetaMax>90
        if Angl(2,2)<(270-Angl(1,3)) % betaMax<270-tetaMin
            [xM,Angl(1,6)]=CalcPos(Angl(1,3),Angl(2,2)); % yMin=l1*sind(-tetaMin)-l2*cosd(betaMax+tetaMin) только все синусы наверно
        else
            if (Angl(2,2)>=(270-Angl(1,3))) && (Angl(1,2)<=(270-Angl(1,3))) % betaMax>=270-tetaMin & betaMin<=270-tetaMin
                Angl(1,6)=-l1*sind(Angl(1,3))-z*sind(-90+Angl(1,3))-l2; % yMin=-l1*sind(tetaMin)-l2
            else
                if Angl(1,2)>(270-Angl(1,3)) % betaMin>270-tetaMin
                    [xM,Angl(1,6)]=CalcPos(Angl(1,3),Angl(1,2)); % yMin=l1*sind(-tetaMin)-l2*cosd(betaMin+tetaMin) только все синусы наверно
                end
            end
            %Angl(1,5)=l1*sind(-Angl(1,3))+l2*sind(Angl(2,2)+Angl(1,3)); % yMin=l1*sind(-tetaMin)+l2*sind(betaMax+tetaMin)
        end
    else
        if Angl(1,3)<=90 && Angl(2,3)>=90 % tetaMin<=90 && tetaMax>=90
            thetaMean=real(90+CalcAuxAng(sqrt(l1^2+z^2),l2,Angl(2,2)));
            if Angl(2,3)>thetaMean % ?max > ?mean
                Angl(1,6)=-TeorCos(sqrt(l1^2+z^2),l2,Angl(2,2)); % yMin=-sqrt(l1^2+l2^2-2*l1*l2*cosd(betaMax))
            else
                [xM,Angl(1,6)]=CalcPos(Angl(2,3),Angl(2,2)); % yMin=l1*sind(-tetaMax)+l2*sind(betaMax+tetaMax)
            end
        else
            if Angl(1,3)<90 && Angl(2,3)<90 % tetaMin<90 && tetaMax<90
                [xM,Angl(1,6)]=CalcPos(Angl(2,3),Angl(2,2)); % yMin=l1*sind(-tetaMax)+l2*sind(betaMax+tetaMax)
            end
        end
    end
    
    % Определение максимального значения Y
    ksi=fix(real(CalcAuxAng(sqrt(l1^2+z^2),l2,Angl(1,2))));
    if Angl(1,3)<=(90+ksi) % thetaMin<=(90+ksi)
        omega=90-Angl(1,3);
        if Angl(2,2)<omega
            [xM,Angl(2,6)]=CalcPos(Angl(1,3),Angl(2,2)); % yMax=l1*sind(-tetaMin)+l2*sind(betaMax+tetaMin)
        else
            if (Angl(2,2)>=omega) && (Angl(1,2)<=omega)
                Angl(2,6)=-l1*sind(Angl(1,3))-z*sind(-90+Angl(1,3))+l2; % yMax=l1*sind(-tetaMin)+l2
            else
                if Angl(1,2)>omega
                    [xM,Angl(2,6)]=CalcPos(Angl(1,3),Angl(1,2)); % yMax=l1*sind(-tetaMin)+l2*sind(betaMin+tetaMin)
                end
            end
        end
    else
        omega=270-Angl(2,3);
        if (Angl(2,2)<omega) || (Angl(2,2)<2*omega-Angl(1,2))
            [xM,Angl(2,6)]=CalcPos(Angl(2,3),Angl(1,2)); % yMax=l1*sind(-tetaMax)-l2*cosd(betaMin+tetaMax) только все синусы наверно
        else
            if (Angl(1,2)>omega) || (Angl(1,2)>=2*omega-Angl(2,2))
                [xM,Angl(2,6)]=CalcPos(Angl(2,3),Angl(2,2)); % yMax=l1*sind(-tetaMax)-l2*cosd(betaMax+tetaMax) только все синусы наверно
            end
        end
    end
    
    % Считывание информации о наличии ограничений связанных с креплением манипулятора к дрону
    Sw = get(ChaCond,'Value');
    if (Angl(2,6)>l2*sind(gamma)+z) && (Sw==1)
        Angl(2,6)=l2*sind(gamma)+z;
    end
        
    [xa,ya]=PlotWorkArea(Angl); % отображение рабочей области
    
    Angl(2,6)=max(ya); % поправка максимального значения Y при наличии дрона(временное решение)
    
    set(TabAngles,'Data',Angl);
    
    ChAn=2; 
end

Angl0=Angl; % запись последнего диапазона

end

% Функция определения начальной допустимой точки
function [x0,y0]=StartPoint(theta,beta)

global TabAng

% Определение начальных допустимых координат (только для первого вывода графика)
alpha=180-beta-theta;
LinkCoord=CalcCoord(theta,beta,alpha);
x0=LinkCoord(4,1);
y0=LinkCoord(4,2);
db0=beta;
dt0=theta;
da0=alpha;

% Запись полученных углов в таблицу
datAng=get(TabAng,'Data');
datAng(2,2)={db0};
datAng(3,2)={dt0};
datAng(1,2)={da0};
set(TabAng,'Data',datAng);
end

% Дополнительная проверка координат из-за ограничения связанного с наличием дрона
function [x,y]=CheckGeom(Sw,val,x,y,x0,y0)

global l1 z gamma

p=l1-z/tand(gamma);
if Sw==1 % корректировка с учётом структурных ограничений
    if val==3 % Приоритетной является координата Y
        if (x>=0) && (x<p) && (y>=0)
            x=p;
        else
            if (x<p) && (y>0)
                y=0; % возможно нужно подправить
            else
                if (x>=p) && (y>=0)
                    if y>(x-p)*tand(gamma)
                        x=y/tand(gamma)+p;
                    end
                end
            end
        end
    else
        if val==2 % Приоритетной является координата X, возможно нужно подправить
            if (x<p) && (y>0)
                y=0;
            else
                if (x>=p) && (y>=0)
                    if x<y/tand(gamma)+p
                        y=(x-p)*tand(gamma);
                    end
                end
            end
        else
            if  val==1
                if ((x<p) && (y>0)) || ((x>=p)&&(y>(x-p)*tand(gamma)))
                x=x0;
                y=y0;
                end
            end
        end
    end
end
end

% Функция построения рабочей области манипулятора
function [xa,ya]=PlotWorkArea(Angl)

global l1 l2 z gamma ChaCond TabMaxTorq
%Start3 = cputime; % измерение времени работы функции

WAr = waitbar(0,'Computation of WorkArea'); % Окно ожидания расчёта рабочей области

% Считывание информации о наличии ограничений связанных с креплением манипулятора к дрону
Sw = get(ChaCond,'Value');

% Рассчёт количества точек
h=0.1;

% Построение области при tethaMax от betaMax до betaMin
[xa1,ya1]=CalcArc((l1*cosd(Angl(2,3))+z*cosd(-90+Angl(2,3))),(-l1*sind(Angl(2,3))-z*sind(-90+Angl(2,3))),l2,-(Angl(2,2)-180+Angl(2,3)),-(Angl(1,2)-180+Angl(2,3)),h); %[xa1,ya1]=CalcArc((l1*cosd(tetaMax)),(-l1*sind(tetaMax)),l2,-(betaMax-180+tetaMax),-(betaMin-180+tetaMax),h);

% Построение области при betaMin от tetaMax до tetaMin
phi1=CalcAuxAng(sqrt(l1^2+z^2),l2,Angl(1,2)+atand(z/l1)); % phi1=acosd((l1-l2*cosd(betaMin))/sqrt(l1^2+l2^2-2*l1*l2*cosd(betaMin)));
[xa2,ya2]=CalcArc((0),(0),TeorCos(sqrt(l1^2+z^2),l2,Angl(1,2)+atand(z/l1)),-(Angl(2,3)-phi1-atand(z/l1)),-(Angl(1,3)-phi1-atand(z/l1)),h); % [xa2,ya2]=CalcArc((0),(0),sqrt(l1^2+l2^2-2*l1*l2*cosd(betaMin)),-(tetaMax-phi1),-(tetaMin-phi1),h);

% Построение области при tethaMin от betaMin до beta Max
[xa3,ya3]=CalcArc((l1*cosd(Angl(1,3))+z*cosd(-90+Angl(1,3))),(-l1*sind(Angl(1,3))-z*sind(-90+Angl(1,3))),l2,(180-Angl(1,3)-Angl(1,2)),(180-Angl(1,3)-Angl(2,2)),-h); % [xa3,ya3]=CalcArc((l1*cosd(tetaMin)),(-l1*sind(tetaMin)),l2,(180-tetaMin-betaMin),(180-tetaMin-betaMax),-h);

% Построение области при betaMax от tethaMin до tethaMax
phi2=CalcAuxAng(sqrt(l1^2+z^2),l2,Angl(2,2)+atand(z/l1)); % phi2=acosd((l1-l2*cosd(betaMax))/sqrt(l1^2+l2^2-2*l1*l2*cosd(betaMax)));
[xa4,ya4]=CalcArc((0),(0),TeorCos(sqrt(l1^2+z^2),l2,Angl(2,2)+atand(z/l1)),-(Angl(1,3)-phi2-atand(z/l1)),-(Angl(2,3)-phi2-atand(z/l1)),-h); % [xa4,ya4]=CalcArc((0),(0),sqrt(l1^2+l2^2-2*l1*l2*cosd(betaMax)),-(tetaMin-phi2),-(tetaMax-phi2),-h);ElapsedPi = cputime - Start3

% Объединение полученных координат рабочей области
xa=[xa1 xa2 xa3 xa4];
ya=[ya1 ya2 ya3 ya4];

% Определение максимальных крутящих моментов моторов
i=1;
Tmax=[0 0 0 0 0];
for i=1:length(xa)
    
    % Проверка нахождения манипулятора в допустимой зоне в I квадранте из-за наличия дрона
    if Sw==1
        if (xa(i)<TeorCos(sqrt(l1^2+z^2),l2,Angl(1,2)+atand(z/l1))) && (ya(i)>0)
            xa(i)=xa(i-1);
            ya(i)=ya(i-1);
        else
            p=l1-z/tand(gamma);
            if (xa(i)>=TeorCos(sqrt(l1^2+z^2),l2,Angl(1,2)+atand(z/l1))) && (xa(i)<=p) && (ya(i)>0)
                ya(i)=0;
            else
                if (xa(i)>p) && (xa(i)<=l1+l2*cosd(gamma)) && (ya(i)>(xa(i)-p)*tand(gamma)) 
                    ya(i)=(xa(i)-p)*tand(gamma);
                end
            end
        end
    end
    
    [db,dt]=CalcAngl(xa(i),ya(i),Angl);
    [T0,T1,T2,T3,arm123x,arm123y]=CalcTorq(db,dt);
    
    % Обновление максимальных значений крутящих моментов
    if T0>Tmax(1)
        Tmax(1)=T0;
    end
     if T1>Tmax(2)
        Tmax(2)=T1;
     end
     if T2>Tmax(3)
        Tmax(3)=T2;
     end
     Tmax(4)=16.5;
     if T3>Tmax(4)
        Tmax(5)=T3;
     end
    
end
%ElapsedCalcu = cputime - Start3
% Запись максимальных значений моментов
TMT=get(TabMaxTorq,'Data');
for i=1:5
    if i~=4
        TMT(i,2)={Tmax(i)};
    end
end
set(TabMaxTorq,'Data',TMT);

waitbar(1,WAr,'Successfully ;-)'); % Окно ожидания расчёта рабочей области
close(WAr); % Закрытие окна расчёта рабочей области

%Elapsedbl = cputime - Start3
end

% Функция определения значения угла beta
function [db,c2,s2,r0,r]=findBeta(x,y,l1,l2,betaMin,betaMax)

c2=(x^2+y^2-l1^2-l2^2)/(2*l1*l2);
if c2==1
    db=0;
else
    db=acosd(c2);
end
db=real(180-db);

r0=l1^2+l2^2-2*l1*l2*cosd(db); % Определение текущего радиус-вектора
     
% Проверка нахождения угла beta в рабочем диапазоне
if (db<betaMin) || (db>betaMax)
    db=ParamCheck(db,betaMin,betaMax);
    c2=cosd(180-db);
    r=l1^2+l2^2-2*l1*l2*cosd(db); % Определение нового радиус-вектора
else
    r=r0;
end
    
s2=sind(180-db);
if abs(s2)<1e-6 % Замена точного значения
    s2=0;
end
    
end

% Функция определения угла tetha
function [dt,c1,s1]=findTetha(x,y,l1,l2,c2,s2,tetaMin,tetaMax)

c1=(y*l2*s2+x*(l1+l2*c2))/(l1^2+l2^2+2*l1*l2*c2);
s1=(-x*l2*s2+y*(l1+l2*c2))/(l1^2+l2^2+2*l1*l2*c2);
dt=-acosd(c1)+180;
    
% Проверка положения звена №1 относительно оси Х
if (c1>0 && s1>=0) || (c1<0 && s1>=0)
    dt=360-dt;
end
    
% Проверка нахождения угла teta в рабочем диапазоне
if 180-dt<tetaMin
    dt=180-tetaMin;
else
    if 180-dt>tetaMax
        if x>=0 && y>=0
            dt=180-tetaMax;
        else
            if (x<0) || ((x>=0) && (y<0)) %dt>180%db==betaMin
                dt=180-tetaMin;
            end
        end
    end
end

end

% Функция вычисления координат звеньев
function LinkCoord=CalcCoord(theta,beta,alpha)

global l1 l2 l3 z

%alpha=90-100;
%alpha=180-beta-theta%+atand(z/l1);

LinkCoord(1,1)=0; % X
LinkCoord(1,2)=0; % Y
LinkCoord(2,1)=l1*cosd(-theta);
LinkCoord(2,2)=l1*sind(-theta);
LinkCoord(3,1)=LinkCoord(2,1)+z*cosd(-90+theta);
LinkCoord(3,2)=LinkCoord(2,2)-z*sind(-90+theta);
LinkCoord(4,1)=LinkCoord(3,1)-l2*cosd(beta+theta);
LinkCoord(4,2)=LinkCoord(3,2)+l2*sind(beta+theta);
LinkCoord(5,1)=LinkCoord(4,1)+l3*cosd(180-theta-beta-alpha);
LinkCoord(5,2)=LinkCoord(4,2)+l3*sind(180-theta-beta-alpha);

end

% Функция вычисления положения третьего линка
function [xMax,yMax]=CalcPos(theta,beta)

global l1 l2 z

xMax=l1*cosd(-theta)+z*cosd(-90+theta)-l2*cosd(beta+theta); % X
yMax=l1*sind(-theta)-z*sind(-90+theta)+l2*sind(beta+theta); % Y

end

% Функция для вычисления вспомогательного угла
function AuxAng=CalcAuxAng(a,b,angle)
AuxAng=acosd((a-b*cosd(angle))/sqrt(a^2+b^2-2*a*b*cosd(angle)));
end

% Матрица поворота
function R=RotMat(arz,ary,arx)
Rz=[cosd(arz) -sind(arz) 0 0; sind(arz) cosd(arz) 0 0; 0 0 1 0; 0 0 0 1];
Ry=[cosd(ary) 0 sind(ary) 0; 0 1 0 0; -sind(ary) 0 cosd(ary) 0; 0 0 0 1];
Rx=[1 0 0 0; 0 cosd(arx) -sind(arx) 0; 0 sind(arx) cosd(arx) 0; 0 0 0 1];
R=Rz*Ry*Rx;
end

% Матрица переноса
function D=DisMat(qz,qy,qx)
D=[1 0 0 qx; 0 1 0 qy; 0 0 1 qz; 0 0 0 1];
end

% Функция расчёта крутящих моментов моторов (нужно править...)
function [T0,T1,T2,T3,arm123x,arm123y]=CalcTorq(beta,teta)

global TabMass l1 l2 l3 g cm1 cm2 cm3 arm4 Z1 Z2 ml1 ml2 mx z mkp

M=get(TabMass,'Data');
mc=cell2mat(M(1,2)); % кг, масса груза
ms0=cell2mat(M(2,2)); % кг, масса сервомотора № 0
ms1=cell2mat(M(3,2)); % кг, масса сервомотора № 1
ms2=cell2mat(M(4,2)); % кг, масса сервомотора № 2
ms3=cell2mat(M(5,2)); % кг, масса сервомотора № 3
ms4=cell2mat(M(4,2)); % кг, масса сервомотора № 4
m23=ml2+mx+mc+ms3+ms2+ms4; % кг, масса 2-го звена с сервомоторами (2 и 3), крепежом, хватом и грузом
m123=ml1+ml2+mx+ms3+ms2+ms1+ms4; % кг, масса 1-го и 2-го звеньев с сервомоторами (1, 2, 3), крепежом, хватом и грузом

% Центр тяжести манипулятора без груза
arm123x=((ml1*cm1+(ms1+ml2+mx+ms3+ms2+ms4)*l1)*cosd(teta)+(ml2*(cm1)+(mx+ms3+ms4+ms2)*(l2))*cosd(180-(beta+teta))+mx*l3+ms3*cm3)/m123;
arm123y=((ml1*cm1+(ms1+ml2+mx+ms3+ms2+ms4)*l1)*sind(-teta)+(ml2*(cm1)+(mx+ms3+ms4+ms2)*(l2))*sind(180-(beta+teta)))/m123;

T4=arm4*mc*g; % момент, создаваемый грузом
u=Z2/Z1; % передаточное число
T3=10.19716*T4/u; % кг-см, крутящий момент сервомотора № 3
T2=10.19716*(mx*cm3+mc*(cm3+arm4)+ms3*l3+0.022*0.0207+0.164*0.01+0.173*0.006)*g; % кг-см, крутящий момент сервомотора № 2
T1=T2+10.19716*((mc + mx + ms3+ms4 + ms2+0.0207+0.01+0.006)*l2 + ml2*cm2)*g*(cosd(180-teta-beta)); % кг-см, крутящий момент сервомотора № 1
T0=T1+10.19716*((mc + mx + ms3+ms4 + ms2 + ml2 + ms1+0.0207+0.01+0.006+0.02)*sqrt(l1^2+z^2) + ml1*cm1)*g*(cosd(teta-acosd(l1/sqrt(l1^2+z^2)))); % кг-см, крутящий момент сервомотора № 0

%if T0<0
%    T0=-1*T0;
%end

end

% Функция вычисления координат рабочей области (построение одного элемента)
function [xa,ya]=CalcArc(xc,yc,R,a1,a2,h)
xa=xc + R * cos((a1*pi/180):h:(a2*pi/180));
ya=yc + R * sin((a1*pi/180):h:(a2*pi/180));
end

%% Блок управления устройствами
% Функция подключения/отключения Arduino
function [Ard,serv]=ArdSwitch(SwC)

global TabSens CountArd Us serv tps

[kMr,ChMot]=NumbMot({'Servo'}); % Проверка количества сервомоторов

if (SwC>=2) && (kMr~=0)
    
    WCon = waitbar(0,'Connection to Arduino'); % Окно ожидания подключения
    clear Ard serv
    Ard=arduino('btspp://98D33491078C','uno'); % Подключение к Arduino
    CountArd=1;
    
    writeDigitalPin(Ard,'D3',1); % включение питания
    
    % Подключение ультразвукового датчика
    waitbar(1/6,WCon,'Connection Ultrasonic sensor'); % Окно ожидания подключения
    Tsens=get(TabSens,'Data');
    if strcmp({'on'},Tsens(3,2))==1
        Us = addon(Ard, 'JRodrigoTech/HCSR04', 'D12', 'D11'); % Подключение ультразвукового датчика (trigger pin D7 и echo pin D11)
    else
        Us=0;
    end
    
    AngMas=ConvAng; % Считывание текущих значений углов
    
    % Подключение сервомоторов
    Pins=[{'D8'} {'D7'} {'D4'} {'D3'} {'D2'}]; % подключение моторов к пинам Arduino (база, центр, запястье, схват)
    j=1;
    for i=1:5
        waitbar((i+1)/6,WCon,'Connection to Motors'); % Окно ожидания подключения
        if strcmp({'Servo'},ChMot(i,2))==1 % Проверка подключения к сервомотору
            serv(j) = servo(Ard,strjoin(Pins(i))); % Подключение к сервомотору № 1 (база) к пину 8
            if i==5
                if AngMas(i-1)~=cell2mat({' '})
                    writePosition(serv(j),AngMas(i-1));
                end
            elseif AngMas(i)~=cell2mat({' '})
                writePosition(serv(j),AngMas(i));
            end
            tps(j)=i; % Запись номеров сервомоторов
            j=j+1;
        end
    end
    % Считывание и перезапись показаний сенсоров
    SensData(Ard);
    
    waitbar(6/6,WCon,'Successfully ;-)'); % Окно ожидания подключения
    close(WCon); % Закрытие окна ожидания подключения

end

end

% Функция считывания показаний датчиков силы и расстояния
function SensData(Ard)

global TabSens TabMass Us DevCon mcc err massc

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора

if SwC>=2
    Tsens=get(TabSens,'Data');
    
    if strcmp({'on'},Tsens(1,2))==1 % Проверка подключения сенсора № 1
        V1=readVoltage(Ard,strjoin({'A0'}));
        if V1<0.4545
            V1=0.4545;
        end
        DatSens1=CalcForce(V1);
        Tsens(1,3)={DatSens1};
    end
    
    if strcmp({'on'},Tsens(2,2))==1 % Проверка подключения сенсора № 2
        DatSens2=CalcForce(readVoltage(Ard,strjoin({'A4'})));
        if DatSens2<1.071
            DatSens2=0;
        end
        Tsens(2,3)={DatSens2};
    end
    
    M=get(TabMass,'Data');
    if (DatSens1==0) && (DatSens2==0)
        M(1,2)={0};
        err=0;
        massc=0;
        set(TabMass,'Data',M);
    end
    
    % Расчёт примерного веса груза
%     if (DatSens1~=0) || (DatSens2~=0)
        mcc=CalcCargo(0);
%     else
%         mcc=0;
%     end
    
    if strcmp({'on'},Tsens(3,2))==1 % Проверка подключения ультразвукового датчика
        DatSens3 = readDistance(Us);
        Tsens(3,3)={DatSens3};
    end
    
    set(TabSens,'Data',Tsens); % Запись данных датчиков в таблицу
    
end

end

% Функция вычисления прикладываемой к датчику силы
function FSens=CalcForce(VSens)

global g

R2=[100000 30000 11000 6200 3400 2100 1300 740 450 310 260]; % Ом, сопротивление на резисторе
F2=g*0.001*[16 20 50 100 260 510 1000 2000 4000 7000 10000]; % Н, величина прикладываемой силы

if VSens<(50/110)
    FSens=0;
else
    RSens=10000*5/VSens-10000;
    FSens=interp1(R2,F2,RSens); % вычисление силы для полученного напряжения датчика
end

end

% Функция подключения/отключения моторов Dynamixel при использовании USB2Dynomixel
function DynoSwitch(SwC)

global CountArd CountDyn CountOCM Us IDm Ard serv  p PROTOCOL_VERSION group LEN_MX_MOVING

[kMr,ChMot]=NumbMot({'Dynamixel'}); % Проверка количества моторов Dynamixel
    
if (SwC==3) && (kMr~=0)
    
    if CountOCM==1
        CountOCM=0;
        clear Dxl IDm
    end
    
    WConD = waitbar(0,'Connection to USB2Dynamixel (~1 sec)'); % Окно ожидания подключения
    
    if CountArd~=1
        [Ard,serv]=ArdSwitch(SwC);
    end
    
    %loadlibrary('dxl_x64_c', 'dynamixel.h'); % подключение библиотеки для моторов Dynamixel
    [notfound, warnings] = loadlibrary('dxl_x64_c', 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h', 'addheader', 'group_bulk_read.h');
    
    % Подключение моторов
    waitbar(1/2,WConD,'Connection with motors'); % Окно ожидания подключения
    pause(0.1);
    p=defCOM; % Подключение моторов
    packetHandler(); % Initialize PacketHandler Structs
    openPort(p);
    BAUDRATE = 1000000;
    setBaudRate(p, BAUDRATE);
    PROTOCOL_VERSION = 1.0;
    group = groupBulkRead(p, PROTOCOL_VERSION);
    LEN_MX_MOVING=1;
    
    IDm=DynID(kMr,ChMot,p,PROTOCOL_VERSION); % Определение ID моторов
    
    pause(0.2);

    if IDm~=0
        for jDm=1:kMr
            DynoData(IDm(jDm),jDm);
        end
        waitbar(2/2,WConD,'Successfully ;-)'); % Окно ожидания подключения
    else
        waitbar(2/2,WConD,'Dynamixels are absent'); % Окно ожидания подключения
    end
    
    % Добавление моторов в группу со всеми моторами
    CurAng(1)=read2ByteTxRx(p, PROTOCOL_VERSION, IDm(1),36);
    CurAng(2)=read2ByteTxRx(p, PROTOCOL_VERSION, IDm(2),36);
    CurAng(3)=read2ByteTxRx(p, PROTOCOL_VERSION, IDm(3),36);
    
    % Add parameter storage for Dynamixel#1 present position value
    dxl_addparam_result = groupBulkReadAddParam(group, IDm(1), 36, CurAng(1));
    if dxl_addparam_result ~= true
        fprintf('[ID:%03d] groupBulkRead addparam failed', IDm(1));
        return;
    end
    
    % Add parameter storage for Dynamixel#2 present moving value
    for i=[2,3]
        dxl_addparam_result = groupBulkReadAddParam(group, IDm(i), 46, LEN_MX_MOVING);
        if dxl_addparam_result ~= true
            fprintf('[ID:%03d] groupBulkRead addparam failed', IDm(i));
            return;
        end
    end
    
    CountDyn=1;
    close(WConD); % Закрытие окна ожидания подключения
       
end

end

% Функция определения номера COM порта с USB2Dynamixel
function p=defCOM(src,evt)

% port_num=7;
% 
% while port_num~=252
%     portCOM=['COM' num2str(port_num)];
%     p=portHandler(portCOM); % подключение мотора со скоростью передачи данных 1 Mb
%     if p == 1
%         break
%     else
%         port_num=port_num+1
%     end
% end
p=portHandler('COM7'); % подключение мотора со скоростью передачи данных 1 Mb

end

% Функция определение ID мотора Dynamixel (1, 5, 11, 15)
function IDm=DynID(kMr,ChMot,p,PROTOCOL_VERSION)

global TabMot

kM=0; % Счётчик количества моторов
ID=1; % Переменная для определения текущего ID
IDm=0;
while (kM<kMr) || (ID<252)
    dxl_model_number = pingGetModelNum(p, PROTOCOL_VERSION, ID);
    dxl_comm_result = getLastTxRxResult(p, PROTOCOL_VERSION);
    if (dxl_comm_result == 0) %|| (s == 2)
        kM=kM+1;
        IDm(kM)=ID; % Запись полученного ID
        ChMot(kM,7)={ID};
        
        write1ByteTxRx(p, PROTOCOL_VERSION, IDm(kM), 24, 1); % запись удержания момента
        write2ByteTxRx(p, PROTOCOL_VERSION, IDm(kM), 6, 0); % запись минимального угла CW
        if pingGetModelNum(p, PROTOCOL_VERSION, IDm(kM))==12 %NMot(kMr)==12
            write2ByteTxRx(p, PROTOCOL_VERSION, IDm(kM), 8, 1023); % запись максимального угла CCW для AX-12
        else
            write2ByteTxRx(p, PROTOCOL_VERSION, IDm(kM), 8, 4095); % запись максимального угла CCW для MX-28T и MX-64T
        end
        write2ByteTxRx(p, PROTOCOL_VERSION, IDm(kM), 14, 1023); % включение максимального крутящего момента
        write2ByteTxRx(p, PROTOCOL_VERSION, IDm(kM), 34, 1023); % включение максимального крутящего момента
    end
    ID=ID+1;
    
    if (kM==kMr) || (ID==252)
        break
    end
end
%     KolMot=kMr;
%     for i=1:length(IDm)
%         calllib('dxl_x64_c', 'dxl_ping',int32(IDm(i))); % Проверка отклика мотора
%         s=calllib('dxl_x64_c', 'dxl_get_result') % Проверка ответа мотора
%         if (s == 1) %|| (s == 2)
%             KolMot=KolMot-1
%         end
%     end
pause(0.1)

if IDm~=0
    DynoSpeed(kMr,IDm,ChMot);
end

set(TabMot,'Data',ChMot);

end

% Функция проверки скоростей и коэффициентов ПИД-регулятора моторов Dynamixel
function DynoSpeed(kMr,IDm,ChMot)

global TabMot p PROTOCOL_VERSION

DynCom=[32 28 27 26]; % номера команд для скорости, коэффициентов P, I и D соответственно
DynCom2=[32 28 26 48]; % номера команд для скорости, коэффициентов P, I и D соответственно

for jDm=1:kMr
    for i=3:1:6
        PDyno(i)=str2num(cell2mat(ChMot(jDm,i)));
        
        % Проверка нахождения значений в допустимом диапазоне
        if i==3
            PDyno(i)=ParamCheck(PDyno(i),0,1023);
        else
            PDyno(i)=ParamCheck(PDyno(i),0,252);
        end
        
        if i-2==1
            write2ByteTxRx(p, PROTOCOL_VERSION, IDm(jDm),DynCom(i-2),int32(PDyno(i))); % запись проверенного параметра на мотор
        else
            if jDm<kMr
                write1ByteTxRx(p, PROTOCOL_VERSION, IDm(jDm),DynCom(i-2),int32(PDyno(i))); % запись проверенного параметра на мотор
            else
                write1ByteTxRx(p, PROTOCOL_VERSION, IDm(jDm),DynCom2(i-2),int32(PDyno(i))); % запись проверенного параметра на мотор
                write1ByteTxRx(p, PROTOCOL_VERSION, IDm(jDm),(DynCom2(i-2)+1),int32(PDyno(i))); % запись проверенного параметра на мотор
            end
        end
        %Dxl.writeWord(IDm(jDm),DynCom(i-2),PDyno(i)); % запись проверенного параметра на мотор
        ChMot(jDm,i)=cellstr(num2str(PDyno(i))); % перезапись нового значения параметра
    end
end

set(TabMot,'Data',ChMot);

end

% Функция считывания данных с моторов Dynamixel !есть ссылка на конкретные ID!
function DynoData(ID,jDm)

global TabMaxTorq TabAng CoorX CoorY CountMot CountDyn InitData p PROTOCOL_VERSION IDm

% считывание значений напряжений на моторах
TMT=get(TabMaxTorq,'Data'); % считывание данных таблицы с данными моторов
V=read1ByteTxRx(p, PROTOCOL_VERSION, ID,42)/10;
TMT(jDm,6)={V};

% считывание нагрузок моторов
Tm=read2ByteTxRx(p, PROTOCOL_VERSION,ID,40); % считывание текущей нагрузки
% Enco=read2ByteTxRx(p, PROTOCOL_VERSION, IDm(1),36)
% Enco2=read2ByteTxRx(p, PROTOCOL_VERSION, IDm(2),36)
% Enco3=read2ByteTxRx(p, PROTOCOL_VERSION, IDm(3),36)
% Проверка моторов на восприятие нагрузки и перезапуск при необходимости
if (Tm==0) && (CountMot~=0) && (CountDyn~=2)
    CurAng=read2ByteTxRx(p, PROTOCOL_VERSION, ID,36);
    write2ByteTxRx(p, PROTOCOL_VERSION, ID,34,1023); % восстановление восприятия нагрузки
    write2ByteTxRx(p, PROTOCOL_VERSION, ID,14,1023); % восстановление восприятия нагрузки
    write2ByteTxRx(p, PROTOCOL_VERSION, ID,30,int32(CurAng)); % запись требуемого положения
    Tm=read2ByteTxRx(p, PROTOCOL_VERSION, ID,40); % повторное считывание нагрузки
    pause (0.1)
    
    % Обновление информации о положении в приложении
    datAng=get(TabAng,'Data');
    Beta=cell2mat(datAng(2,2));
    Theta=cell2mat(datAng(3,2));
    str = get(CoorY, 'String');
    y=str2num(str);
    str = get(CoorX, 'String');
    x=str2num(str);
    
    if ID==1
        Theta=CurAng*0.088-90;
        datAng(3,2)={Theta};
    else
        if ID==5
            Beta=CurAng*0.088-90;
            datAng(2,2)={Beta};
        end
    end
    
    [x1,y1]=CalcPos(Theta,Beta);
    InitData=PlotLocation(x,y,x1,y1);
else
    % Корректировка в соответствии с направлением вращения мотора
    if Tm>1023
        Tm=Tm-1023;
    end
    
    % Считывание информации о крутящих моментаж
    TorgDm=[cell2mat(TMT(1,5)) cell2mat(TMT(2,5)) cell2mat(TMT(3,5)) cell2mat(TMT(4,5))]; % массив максимальных крутящих моментов для моторов
    
    TMT(jDm,4)={((Tm*(1/1023)*TorgDm(jDm)*(V/14.8)))};
    set(TabMaxTorq,'Data',TMT); % перезапись данных о нагрузках моторов
end

end

% Функция определения номера COM порта с OpenCM
function Dxl=OpenCMCon(SwC)

global CountArd CountDyn CountOCM IDm

[kMr,ChMot]=NumbMot({'Dynamixel'}); % Проверка количества моторов Dynamixel
    
if (SwC==4) && (kMr~=0)
    
    if CountArd~=1
        [Ard,serv]=ArdSwitch(SwC);
    end
    
    if CountDyn==1
        CountDyn=0;
        closePort(p); % Close port
        unloadlibrary('dxl_x64_c'); % отключение библиотеки для моторов Dynamixel
        clear IDm
    end
    
    WConO = waitbar(0,'Connection to OpenCM (~1 sec)'); % Окно ожидания подключения
    
    USBBaudRate = 115200; % Установка скорости обмена информацией
    Dxl = DXL(USBBaudRate,'COM8'); % Подключение OpenCM
    
    % Подключение моторов
    waitbar(1/2,WConO,'Connection with motors'); % Окно ожидания подключения
    CountOCM=1;
    IDm=DynID2(kMr,ChMot); % Определение ID моторов
    for jDm=1:kMr
        %DynoSpeed(jDm,IDm,ChMot);
        DynoData2(IDm(jDm),jDm);
    end
    
    waitbar(2/2,WConO,'Successfully ;-)'); % Окно ожидания подключения
    close(WConO); % Закрытие окна ожидания подключения
    
end

end

% Функция определение ID мотора Dynamixel
function IDm=DynID2(kMr,ChMot)

global Dxl

    kM=0; % Счётчик количества моторов
    ID=1; % Переменная для определения текущего ID
    while (kM<kMr) || (ID<252)
        if Dxl.ping(ID)==ID
            kM=kM+1;
            IDm(kM)=ID; % Запись полученного ID

            Dxl.writeWord(IDm(kM),6,0); % запись минимального угла CW
            if NMot(kMr)==11
                Dxl.writeWord(IDm(kM),8,1023); % запись максимального угла CCW для AX-12
            else
                Dxl.writeWord(IDm(kM),8,4095); % запись максимального угла CCW для MX-28T и MX-64T
                %Dxl.writeByte(IDm(kM),73,40); % запись необходимого ускорения
            end
            Dxl.writeWord(IDm(kM),14,1023); % включение максимального крутящего момента
            Dxl.writeWord(IDm(kM),34,1023); % включение максимального крутящего момента
        end
        ID=ID+1;
    end
    
    DynoSpeed2(kMr,IDm,ChMot);
        
end

% Функция проверки скоростей и коэффициентов ПИД-регулятора моторов Dynamixel
function DynoSpeed2(kMr,IDm,ChMot)

global TabMot Dxl

DynCom=[32 28 27 26]; % номера команд для скорости, коэффициентов P, I и D соответственно
DynCom2=[32 28 26 48]; % номера команд для скорости, коэффициентов P, I и D соответственно

for jDm=1:kMr
    for i=3:1:6
        PDyno(i)=str2num(cell2mat(ChMot(jDm,i)));
        
        % Проверка нахождения значений в допустимом диапазоне
        if i==3
            PDyno(i)=ParamCheck(PDyno(i),0,1023);
        else
            PDyno(i)=ParamCheck(PDyno(i),0,252);
        end
        
        if i-2==1
            Dxl.writeWord(IDm(jDm),DynCom(i-2),int32(PDyno(i))); % запись проверенного параметра на мотор
        else
            if jDm<kMr
                Dxl.writeByte(IDm(jDm),DynCom(i-2),int32(PDyno(i))); % запись проверенного параметра на мотор
            else
                Dxl.writeByte(IDm(jDm),DynCom2(i-2),int32(PDyno(i))); % запись проверенного параметра на мотор
                Dxl.writeByte(IDm(jDm),(DynCom2(i-2)+1),int32(PDyno(i))); % запись проверенного параметра на мотор
            end
        end
        ChMot(jDm,i)=cellstr(num2str(PDyno(i))); % перезапись нового значения параметра
    end
end

set(TabMot,'Data',ChMot);

end

% Функция считывания данных с моторов Dynamixel !есть ссылка на конкретные ID!
function DynoData2(ID,jDm)

global TabMaxTorq TabAng CoorX CoorY CountMot Dxl

% считывание значений напряжений на моторах
TMT=get(TabMaxTorq,'Data'); % считывание данных таблицы со значениями крутящих моментов
V=Dxl.readByte(ID,42)/10;
TMT(jDm,6)={V};

% считывание нагрузок моторов
Tm=Dxl.readWord(ID,40); % считывание текущей нагрузки

% Проверка моторов на восприятие нагрузки и перезапуск при необходимости
if (Tm==0) && (CountMot~=0)
    CurAng=Dxl.readWord(ID,36); % считывание последнего положения
    Dxl.writeWord(ID,34,1023); % восстановление восприятия нагрузки
    Dxl.writeWord(ID,14,1023); % восстановление восприятия нагрузки
    Dxl.writeWord(ID,30,int32(CurAng)); % запись требуемого положения
    Tm=Dxl.readWord(ID,40); % повторное считывание нагрузки
    pause (0.1)
    
    % Обновление информации о положении в приложении
    datAng=get(TabAng,'Data');
    Beta=cell2mat(datAng(2,2));
    Theta=cell2mat(datAng(3,2));
    str = get(CoorY, 'String');
    y=str2num(str);
    str = get(CoorX, 'String');
    x=str2num(str);
    
    if ID==1
        Theta=CurAng*0.088-90;
        datAng(3,2)={Theta};
    else
        if ID==5
            Beta=CurAng*0.088-90;
            datAng(2,2)={Beta};
        end
    end
    
    [x1,y1]=CalcPos(Theta,Beta);
    StartApp(x,y,x1,y1);

end

% Корректировка в соответствии с направлением вращения мотора
if Tm>1023
    Tm=Tm-1023;
end

% Считывание информации о крутящих моментаж
TMT=get(TabMaxTorq,'Data'); % считывание данных таблицы со значениями крутящих моментов
TorgDm=[cell2mat(TMT(1,5)) cell2mat(TMT(2,5)) cell2mat(TMT(3,5))]; % массив максимальных крутящих моментов для моторов

TMT(jDm,4)={((Tm*(1/1023)*TorgDm(jDm)*(V/14.8)))};
set(TabMaxTorq,'Data',TMT); % перезапись данных о нагрузках моторов

end

% Подсчёт количества моторов
function [kMr,ChMot]=NumbMot(Ty)

global TabMot

% Проверка количества моторов Dynamixel
ChMot=get(TabMot,'Data');
[rM,cM]=size(ChMot);
kMr=0;
for im=1:rM
    if strcmp(Ty,ChMot(im,2))==1
        kMr=kMr+1;
    end
end

end

% Функция для кнопки перезаписи параметров моторов
function ReWr(src,evt)

global IDm DevCon RWM

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора
[kMr,ChMot]=NumbMot({'Dynamixel'}); % Проверка количества моторов Dynamixel

if SwC==3
    DynoSpeed(kMr,IDm,ChMot);
else
    if SwC==4
        DynoSpeed2(kMr,IDm,ChMot)
    end
end
set(RWM,'Value',0);

end

% Функция передачи данных на моторы
function WriteAngles(SwC,InitData,Ard,serv)

global TabMot TabAng tps CountMot IDm %Us serv %Dxl db0 dt0 da0

% Считывание текущих значений углов
datAng=get(TabAng,'Data');
GenAng=[cell2mat(datAng(3,2)) cell2mat(datAng(2,2)) cell2mat(datAng(1,2)) cell2mat(datAng(5,2)) cell2mat(datAng(4,2))]; % массив значений текущих углов dt, db, da и fi

%InitAng=[dt0; db0; da0] % массив значений углов в предыдущем положении манипулятора
ChMot=get(TabMot,'Data'); % Проверка количества моторов Dynamixel

% Определение максимального интервала между текущим и предыдущим углом
maxDelta=0;
for i=1:3
    Delta(i)=GenAng(i)-InitData(i); % определение интервала между текущим

[100

[100

[100 KB maximum, text cropped]

 KB maximum, text cropped]

 KB maximum, text cropped]

 и предыдущим углом
    if Delta(i)~=0
        Znak(i)=Delta(i)/abs(Delta(i)); % определение направления изменения угла
    else
        Znak(i)=1;
    end
    if Delta(i)>maxDelta
        maxDelta=Delta(i);
    end
end

% Передача значений углов на моторы Dynamixel
if SwC==3
    [kMrD,ChMot]=NumbMot({'Dynamixel'}); % Проверка количества моторов Dynamixel
    for i=1:kMrD
        DynoData(IDm(i),i);
    end
    if CountMot==0
        CountMot=1;
    end
    DAngMass=DynoAng(GenAng); % массив значений текущих углов для моторов Dynamixel
    DInAngMas=DynoAng(InitData); % массив значений начальных углов для моторов Dynamixel
%     DynoMotion(DAngMass);
    SmoothDyno(IDm,DAngMass,DInAngMas,maxDelta);
end

% Передача значений углов на сервомоторы
[kMrS,ChMot]=NumbMot({'Servo'}); % Проверка количества моторов Servo
if SwC>=2
    AngMas=ConvAng; % Считывание текущих значений углов
    InAngMas=ConvAng; % Считывание текущих значений углов
    if kMrS>=2
        for i=1:kMrS-1
            if strcmp({'Servo'},ChMot(i,2))==1
                SlowServo(AngMas(tps(i)),InAngMas(i),serv(i),maxDelta,Znak(i));
            end
        end
    end

    if strcmp({'Servo'},ChMot(4,2))==1
        writePosition(serv(kMrS),AngMas(4));
    end

    % Считывание данных датчиков
    SensData(Ard);
end

end

% Преобразование текущих значений углов в углы моторов для моторов Dynamixel
function DAngMass=DynoAng(GenAng)

Theta=(90+GenAng(1))/0.088; %89
Beta=(90+GenAng(2))/0.088;
Alpha=(60+GenAng(3))/0.29;
Psi=(60+GenAng(4))/0.29; % 0.3516
DAngMass=[Theta Beta Alpha Psi];

end

% Функция для выполнения плавного вращения моторов Dynamixel
function SmoothDyno(ID,CurAng,InAng,maxDelta)

global AngStep p PROTOCOL_VERSION %TabAng %Dxl

% datAng=get(TabAng,'Data');
% GamAng=cell2mat(datAng(5,2));

ah=get(AngStep,'String'); % 0.015
h=str2num(ah)*180; % шаг изменения угла

[kMrD,ChMot]=NumbMot({'Dynamixel'}); % Проверка количества моторов Servo

if maxDelta>h
    Nd=fix(maxDelta/h); % определение количества шагов для перехода в новое положение
    Angl=InAng; % Запись  первой позиции для углов
    
    for i=1:kMrD-1
        Delta(i)=CurAng(i)-InAng(i); % определение интервала между текущим и предыдущим углом
        if Delta(i)~=0
            Znak(i)=Delta(i)/abs(Delta(i)); % определение направления изменения угла
        else
            Znak(i)=1;
        end
        step(i)=Znak(i)*(abs(Delta(i))/Nd);
    end
    
    for j=1:1:Nd
        for i=1:kMrD-1
            Angl(i)=Angl(i)+step(i);
%             write2ByteTxRx(p, PROTOCOL_VERSION, ID(i),30,int32(Angl(i))); % запись нового положения от 0 до 1023 (0-300 градусов)
            %Dxl.writeWord(ID(i),30,Angl(i));
            %DynoData(ID(i),i);
        end
        DynoMotion(Angl);
%         Angl(1)
        mass(j,1)=abs(CalcCargo(0)); % первичное вычисление массы груза
        %WrData;
        pause(0.05)
    end
    
    % Запись конечного положения манипулятора
    Angl=CurAng;
    for i=1:kMrD
        write2ByteTxRx(p, PROTOCOL_VERSION, ID(i),30,int32(Angl(i))); % запись нового положения от 0 до 1023 (0-300 градусов)
    end
else
    for i=1:kMrD
        write2ByteTxRx(p, PROTOCOL_VERSION, ID(i),30,int32(CurAng(i))); % запись нового положения от 0 до 1023 (0-300 градусов)
    end
end

%calllib('dxl_x64_c', 'dxl_read_word',ID,14); % проверка максимального крутящего момента
%calllib('dxl_x64_c', 'dxl_read_word',ID,34);
%Dxl.readWord(ID,14); % проверка максимального крутящего момента
%Dxl.readWord(ID,34);

end

% функция для приведения в движение всех моторов одновременно
function DynoMotion(CurAng)

global p PROTOCOL_VERSION IDm group LEN_MX_MOVING dxl1_present_position dxl2_moving

for i=1:3
    write2ByteTxRx(p, PROTOCOL_VERSION,IDm(i),30,int32(CurAng(i))); % запись нового положения от 0 до 1023 (0-300 градусов)
end

while 1
    % Bulkread present position and moving status
    groupBulkReadTxRxPacket(group);
    
    for i=1:3
        if (i==1)
            % Get Dynamixel#1 present position value
            dxl1_present_position = groupBulkReadGetData(group, IDm(i), 36, 2);
        end
        % Get Dynamixel#2 moving status value
        dxl2_moving = groupBulkReadGetData(group, IDm(i), 46, LEN_MX_MOVING);
    end
    
%     if ~(abs(int32(CurAng(1,1)) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD);
        break;
%     end
end

end

% Преобразование текущих значений углов в углы моторов для Arduino
function AngMas=ConvAng

global TabAng

datAng=get(TabAng,'Data');
da=cell2mat(datAng(1,2))/180;
db=1-cell2mat(datAng(2,2))/180;
dt=1-cell2mat(datAng(3,2))/180;
psi=cell2mat(datAng(5,2))/180;
fi=1.132674-(cell2mat(datAng(4,2))*13.5)/(180*6.732);
AngMas=[dt db da psi fi];

end

% Функция замедления перемещения сервомоторов
function SlowServo(angle,angle0,servos,maxDelta,delta,zn)

%Start = cputime; % измерение времени работы функции

h=0.004*180; % шаг изменения угла
angleEnd=angle;
if maxDelta>h
    Nd=fix(delta/h);
    angle=angle0;
    for i=1:Nd
        angle=angle+zn*h;
        writePosition(servos,angle);
    end
    angle=angleEnd;
    writePosition(servos,angle);
else
    writePosition(servos,angle);
end

%Elapsed = cputime - Start % измерение времени работы функции

end

% Подключение датчиков
function BTCon(SwC)

global ActSw SerCon CountBT InitEncAng mn0 DevCon

ActSw=true;
pause(0.07)

[kMr,ChMot]=NumbMot({'Dynamixel'}); % Проверка количества моторов Dynamixel
    
if (SwC==5) && (kMr~=0)
    
    WConA = waitbar(0,'Connection to Arduino'); % Окно ожидания подключения
%     SerCon=connect_bluetooth;    
    SerCon=serial('COM8','baudrate',115200); %38400 COM23 COM5
    
    set(SerCon,'Terminator','CR/LF')
%     set(SerCon, 'InputBufferSize', 1024); % number of bytes in inout buffer
%     set(SerCon, 'Baudrate', 38400);  %set baudrate with same using arduino (9600) or 19200? 38400
    set(SerCon,'DataBits', 8);
    set(SerCon,'StopBits', 1);
    set(SerCon, 'Timeout',10);
    SerCon.ReadAsyncMode = 'continuous';
    % SerCon.ReadAsyncMode = 'manual';
    % set(SerCon, 'Parity', 'none');
    % set(SerCon, 'FlowControl', 'none');
    pause(0.2)
    disp('Подключаемся');
    
    try % Обработчик исключений
        waitbar(1/3,WConA,'COM port opening...'); % Обновление окна ожидания
        fopen(SerCon);       
        CountBT=true;
        waitbar(2/3,WConA,'Data checking...'); % Обновление окна ожидания
        disp('Ждём данные');
       
%         readasync(SerCon);
%         pause(0.01);
%         stopasync(SerCon);
        while(isnan(str2double(fscanf(SerCon)))==0) % отправка текстового символа, чтобы понять, когда начинать считывание
        end
        
        pause(0.5)
        
        fprintf(SerCon,'\z');
        InitEncAng=fscanf(SerCon,'%f');%str2num(fscanf(d));
        mn0=InitEncAng
        waitbar(1,WConA,'Successfully'); % Обновление окна ожидания
    catch err % Обработка возможных ошибок
        CountBT=false;
        set(DevCon,'Value',1);
        disp('Не удалось подключиться');
        waitbar(1,WConA,'No data'); % Обновление окна ожидания
    end
    
    pause(0.1)
    close(WConA); % Закрытие окна подключения Arduino
end

ActSw=false;

end
%% Дополнительные функции
% Переход в одну из заранее обозначенных точек
function PrePa(src,evt)

global l1 l2 z Pointsy

pNumb=get(Pointsy,'Value');

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения

% запоминаем предыдущие координаты
str = get(handles.edtY, 'String');
y=str2num(str);
str = get(handles.edtX, 'String');
x=str2num(str);

xpo=[(l2-l1+0.0000001) 0.074 -0.092388 0.574 0.42841 0.0135641];
ypo=[-z -0.109 -0.59762 0 -0.0167825 -0.428523];

if pNumb>1 % zero point
    x1=xpo(pNumb-1);
    y1=ypo(pNumb-1);
    StartApp(x,y,x1,y1);
end

set(Pointsy,'Value',1);

end

% Выполнения демонстрации
function FRDemo(src,evt)

% координаты промежуточных точек
%xdem=[0 0.18 0.3 0.44 0.5 0.54 0.4 0.28 0 -0.14 -0.08 0 0.06];
%ydem=[-0.24 -0.16 0 0.06 0.1 -0.2 -0.4 -0.52 -0.6 -0.54 -0.38 -0.24 -0.07];
xdem=[0.18 0.3 0.34 0.36 0.4 0.34 0.28 0 -0.14 -0.08 0 0.06];
ydem=[-0.16 0 0.06 -0.1 -0.2 -0.4 -0.52 -0.6 -0.54 -0.38 -0.24 -0.07];
ldem=length(xdem);

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения

for i=1:1:ldem
    
    % запоминаем предыдущие координаты
    str = get(handles.edtY, 'String');
    y=str2num(str);
    str = get(handles.edtX, 'String');
    x=str2num(str);
    
    % Записываем новые координаты
    x1=xdem(i);
    y1=ydem(i);
    
    StartApp(x,y,x1,y1);
    
    if i==5 % Схватывание груза
        ObMove(1,src);
        pause(0.4);
    else
        if i==9 % Отпускание груза
            ObMove(2,src);
        end
    end
    
    pause(0.8);
end

set(handles.Dem,'Value',0); % возвращение кнопки в исходное положение

end

% Функция взаимодействия с грузом
function ObMove(val,src)

global GrCont GrRot

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения

set(GrRot,'Value',90);
ValRot(src);
set(GrCont,'Value',val);
GrCo(src);
pause(0.4);
set(GrRot,'Value',180);
ValRot(src);

end

% Выполнения цикла вычислений массы полученного груза
function ChWeigh(src,evt)

global TabMass TabMaxTorq TabAng DevCon err massc

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения

% координаты промежуточных точек
%theta=[76 97 114];
%beta=[74 44 145];
theta=52;
beta=90;
xc=0;
yc=0;
h=-0.1;

% вычисление начальной точки и диапазона углов поворота радиус-вектора
[xr,yr]=CalcPos(theta,beta);
a1=atand(yr/xr);
a2=-89; % 101
R=sqrt(xr^2+yr^2);
[xa,ya]=CalcArc(xc,yc,R,a1,a2,h);
P=length(xa);

M=get(TabMass,'Data');
M(1,2)={0};
err=0;
massc=0;

set(TabMass,'Data',M);

angles=get(TabAng,'Data'); % углы
beta=cell2mat(angles(2,2));
theta=cell2mat(angles(3,2));

[T0,T1,T2,T3,arm123x,arm123y]=CalcTorq(beta,theta);

TMT=get(TabMaxTorq,'Data');
TMT(1,3)={T0};
TMT(2,3)={T1};
TMT(3,3)={T2};
TMT(5,3)={T3};
set(TabMaxTorq,'Data',TMT);

% выполнение алгоритма вычисления веса груза
k=0;
CountExp=3; % Количество повторений
for k=1:CountExp
    for i=1:P
        
        if i==2
            pause(0.1); % пауза для стабилизации после вытягивания манипулятора
        end
        
        % запоминаем предыдущие и записываем новые координаты
        str = get(handles.edtY, 'String');
        y=str2num(str);
        str = get(handles.edtX, 'String');
        x=str2num(str);
        x1=xa(i);
        y1=ya(i);
        StartApp(x,y,x1,y1);
        
        mass(i,k)=abs(CalcCargo(i)); % первичное вычисление массы груза
        
        pause(0.016)
    end
end
m=CargoMass(mass,CountExp,P); % вычисление уточнённой массы груза

% Запись вычисленного значения массы груза
M(1,2)={m};
set(TabMass,'Data',M);

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора
ChButs(SwC);

set(handles.Demo2,'Value',0); % возвращение кнопки в исходное положение

end

% Выполнения цикла вычислений массы полученного груза
function ChWeigh0(src,evt)

global TabMass TabMaxTorq TabAng IDm DevCon err massc p PROTOCOL_VERSION

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения

% координаты промежуточных точек
%theta=[76 97 114];
%beta=[74 44 145];
theta=52;
theta=140;
beta=90;
xc=0;
yc=0;
h=-0.1;

% вычисление начальной точки и диапазона углов поворота радиус-вектора
[xr,yr]=CalcPos(theta,beta);
a1=atand(yr/xr);
a2=-89; % 101
R=sqrt(xr^2+yr^2);
[xa,ya]=CalcArc(xc,yc,R,a1,a2,h);
P=length(xa);

M=get(TabMass,'Data');
M(1,2)={0};
err=0;
massc=0;

set(TabMass,'Data',M);

angles=get(TabAng,'Data'); % углы
beta=cell2mat(angles(2,2));
theta=cell2mat(angles(3,2));

[T0,T1,T2,T3,arm123x,arm123y]=CalcTorq(beta,theta);

TMT=get(TabMaxTorq,'Data');
TMT(1,3)={T0};
TMT(2,3)={T1};
TMT(3,3)={T2};
TMT(5,3)={T3};
set(TabMaxTorq,'Data',TMT);

% выполнение алгоритма вычисления веса груза
k=0;
CountExp=10; % Количество повторений
for k=1:CountExp
    tic;
    % запоминаем предыдущие и записываем новые координаты
    str = get(handles.edtY, 'String');
    y=str2num(str);
    str = get(handles.edtX, 'String');
    x=str2num(str);
    x1=xa(P);
    y1=ya(P);
    InitData=PlotLocation(x,y,x1,y1);
    % Считывание текущих значений углов
    datAng=get(TabAng,'Data');
    GenAng=[cell2mat(datAng(3,2)) cell2mat(datAng(2,2)) cell2mat(datAng(1,2)) cell2mat(datAng(5,2)) cell2mat(datAng(4,2))]; % массив значений текущих углов dt, db, da и fi
    DAngMass=DynoAng(GenAng); % массив значений текущих углов для моторов Dynamixel
    DynoMotion(DAngMass)
%     for i=1:3
%         write2ByteTxRx(p, PROTOCOL_VERSION, IDm(1),30,int32(DAngMass(i))); % запись нового положения от 0 до 1023 (0-300 градусов)
%     end
    
    toc
    
    i=0;
    DesAng=0;
    while DesAng<138
        i=i+1;
        mass(i,k)=abs(CalcCargo(0)); % первичное вычисление массы груза
        DesAng=0.08*read2ByteTxRx(p, PROTOCOL_VERSION, IDm(1),36)
        pause(0.001)
    end
    pause(1)
    
    str = get(handles.edtY, 'String');
    y=str2num(str);
    str = get(handles.edtX, 'String');
    x=str2num(str);
    x1=xa(1);
    y1=ya(1);
    InitData=PlotLocation(x,y,x1,y1);
    % Считывание текущих значений углов
    datAng=get(TabAng,'Data');
    GenAng=[cell2mat(datAng(3,2)) cell2mat(datAng(2,2)) cell2mat(datAng(1,2)) cell2mat(datAng(5,2)) cell2mat(datAng(4,2))]; % массив значений текущих углов dt, db, da и fi
    DAngMass=DynoAng(GenAng); % массив значений текущих углов для моторов Dynamixel
    DynoMotion(DAngMass);
% write2ByteTxRx(p, PROTOCOL_VERSION, IDm(1),30,int32((90+52)/0.08)); % запись нового положения от 0 до 1023 (0-300 градусов)
    pause(1)
end
m=CargoMass(mass,CountExp,P); % вычисление уточнённой массы груза

% Запись вычисленного значения массы груза
M(1,2)={m};
set(TabMass,'Data',M);

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора
ChButs(SwC);

set(handles.Demo2,'Value',0); % возвращение кнопки в исходное положение

end

% Функция вычисления веса
function mcc=CalcCargo(i)

global TabMass TabMaxTorq TabAng mx g l1 l2 T0calc CalibT l3 cm1 cm2 cm3 arm4 ml1 ml2 z

% Добавить обновление значения веса груза

M=get(TabMass,'Data');
ms0=cell2mat(M(2,2)); % кг, масса сервомотора № 0
ms1=cell2mat(M(3,2)); % кг, масса сервомотора № 1
ms2=cell2mat(M(4,2)); % кг, масса сервомотора № 2
ms3=cell2mat(M(5,2)); % кг, масса сервомотора № 3
mm= mx + ms3 + ms2 + ms1+0.0207+0.01+0.006;

TMT=get(TabMaxTorq,'Data'); % значения крутящих моментов
Data(1)=cell2mat(TMT(1,4));
Data(2)=cell2mat(TMT(2,4));
Data(3)=cell2mat(TMT(3,4));

Data(4)=cell2mat(TMT(1,3));
Data(5)=cell2mat(TMT(2,3));
Data(6)=cell2mat(TMT(3,3));

if Data(4)<0
    Data(1)=-Data(1);
end

angles=get(TabAng,'Data'); % углы
%alpha=cell2mat(angles(1,2));
beta=cell2mat(angles(2,2));
theta=cell2mat(angles(3,2));
%fi=cell2mat(angles(4,2));

%Tpart2=(mx*cm3+ms3*l3+0.022*0.0207+0.164*0.01+0.173*0.006); % масса на плечо для захвата
%mpart2=mx + ms3 + 0.0207 + 0.01 + 0.006 + ms2; % запас

%mc0=(Data(3)/(10.19716*g)-(mx*cm3+ms3*l3+0.022*0.0207+0.164*0.01+0.173*0.006))/(cm3+arm4)
%mc01=(Data(3)-Data(6))/(10.19716*g*(cm3+arm4)); % запас

%mc10=((Data(2)-Data(3))/(10.19716*g*cosd(180-theta-beta))-mpart2*l2 - ml2*cm2)/l2; % запас
%mc1=((Data(2)/(10.19716*g)-Tpart2)/cosd(180-theta-beta)-mpart2*l2 - ml2*cm2)/((cm3+arm4)*cosd(180-theta-beta)+l2); % запас, расчёт массы груза без учёта Т3
%mc11=(Data(2)-Data(5))/(10.19716*g*((cm3+arm4)+l2*cosd(180-theta-beta))); % запас

%mc20=(Data(1)/(10.19716*g)-((Tpart2+((mpart2)*l2 + ml2*cm2)*cosd(180-theta-beta))+((ml2 + ms1+mpart2)*sqrt(l1^2+z^2) + ml1*cm1)*cosd(theta-acosd(l1/sqrt(l1^2+z^2)))))/(cm3+arm4+l2*cosd(180-theta-beta)+sqrt(l1^2+z^2)*cosd(theta-acosd(l1/sqrt(l1^2+z^2))))
%mc2=((Data(1)-Data(2))/(10.19716*g*cosd(theta-acosd(l1/sqrt(l1^2+z^2))))-ml1*cm1)/sqrt(l1^2+z^2)-ml2-ms1-mpart2; % запас
%mc21=(Data(1)-Data(4))/(10.19716*g*((cm3+arm4)+l2*cosd(180-theta-beta)+sqrt(l1^2+z^2)*cosd(theta-acosd(l1/sqrt(l1^2+z^2)))))
Tmc2=interp1(CalibT,T0calc(:,1),theta);
Tmc3=interp1(CalibT,T0calc(:,2),theta);
% if i~=0
    mcc=0.215-(Tmc2-Tmc3-Data(3)+Data(6))/(10.19716*g*l2*cosd(180-theta-beta));
% else
%     mcc=-(Data(2)-Data(5)-Data(3)+Data(6))/(10.19716*g*l2*cosd(theta-beta));
% end

end

% Вычисление массы груза на базе полученных данных
function mOpt=CargoMass(mass,CountExp,P)

global mmc err massc

% Уточнение веса груза
j=1;
errMin=999;
for j=1:P
    err=999;
    m=0;
    k=1;
    mv=mean(mass(j,:)); % Первичное вычисление массы груза
    mass2=0;
    for i=1:CountExp
        if ((mass(j,i)-mv)/mv)<0.2
            mass2(k)=mass(j,i);
            k=k+1;
        end
    end
    massn(j)=mean(mass2);
    
    for i=1:length(mmc)
        acc=(massn(j)-mmc(i))*100/mmc(i); % отклонение от фактического значения массы груза
        if abs(acc)<err
            m=mmc(i);
            err=abs(acc);
        end
    end
    if err<errMin
        mOpt=m;
        errMin=err;
        massc=massn(j);
    end
end

end

%% Управление гриппером
% Функция распределения заданий для гриппера
function GrCo(src,evt)

global GrCont ChSt

ChSt=1; % переключение в режим работы хвата

GrNumb=get(GrCont,'Value');

handles = guihandles(src); % запись в структуру handles указателей на объекты приложения

if GrNumb==1
    GripHold(src);
elseif GrNumb==2
    GripDrop(src);
elseif GrNumb==4
    UltraCheck(src);
elseif GrNumb==5
    GripRotate(src);
else
    GripStop(src);
    if GrNumb~=3
        set(GrCont,'Value',3);
    end
end

if GrNumb~=3
    set(GrCont,'Value',3) % возвращение кнопки в отключенное состояние
end

ChSt=0;

end

% Функция зажатия груза хватом
function GripHold(src,evt)

global TabAng xc yc xa ya arm123x arm123y fi q serv DevCon Ard GrCont

handles = guihandles(src); % записываем в структуру handles указатели на объекты приложения

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора
% set(handles.GrDrop,'Value',0);
[kMrS,ChMot]=NumbMot({'Servo'}); % Проверка количества моторов Servo

if q~=0
    % Считываем координат X, Y и углов
    str = get(handles.edtX, 'String');
    x=str2num(str);
    str2 = get(handles.edtY, 'String');
    y=str2num(str2);
    datAng=get(TabAng,'Data');
    fi=cell2mat(datAng(4,2));
    if fi~=cell2mat({' '})
        fin=1.132674-(fi*13.5)/(180*6.732);
    else
        fin=1.132674-(90*13.5)/(180*6.732);
    end
    if SwC>=2
        writePosition(serv(kMrS),fin);
        SensData(Ard);
    end
    
    pause(0.1); % ожидание в случае изменения режима
    
    while fin<=0.88
        fin=fin+0.21; % 0.03
        %fin=0.88;
        fi=(1.132674-fin)*180*6.732/13.5;
        cla
        p1=plot(xa,ya,'g','LineWidth',5); % Изобрачение рабочей области манипулятора
        p2=plot(xc,yc,'k-o','LineWidth',3,'MarkerSize',4); % Изображение текужего положения манипулятора
        p3=plot(arm123x,arm123y,'r x','LineWidth',2,'MarkerSize', 10); % Изображение центра масс манипулятора
        p4=plot(0,0.08,'b x','LineWidth',2,'MarkerSize', 10); % Изображение центра масс дрона

        PicGrip(x,y,fi);
        
        leg=legend([p1 p2 p3 p4],'Work Area','Manipulator','Mass center of manipulator','Mass center of drone');
        set(leg,'FontSize',14,'FontName','Book Antiqua','FontWeight','Bold','Location','NorthWest');

        datAng(4,2)={fi};
        set(TabAng,'Data',datAng);
        
        if SwC>=2
            writePosition(serv(kMrS),fin);
            SensData(Ard);
        end
        
        pause(0.1)

        val = get(GrCont,'Value'); % проверяем значение кнопки с тэгом ChStop
        if (val~=1)
            break
        end
        
    end
end

end

% Функция разжатия хвата
function GripDrop(src,evt)

global TabAng xc yc xa ya arm123x arm123y fi q serv DevCon Ard GrCont

[kMrS,ChMot]=NumbMot({'Servo'}); % Проверка количества моторов Servo
SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора
handles = guihandles(src); % записываем в структуру handles указатели на объекты приложения

if q~=0
    % Считываем координат X, Y и углов
    handles = guihandles(src);
    str = get(handles.edtX, 'String');
    x=str2num(str);
    str2 = get(handles.edtY, 'String');
    y=str2num(str2);
    datAng=get(TabAng,'Data');
    fi=cell2mat(datAng(4,2));
    fin=1.132674-(fi*13.5)/(180*6.732);
    if SwC>=2
        SensData(Ard);
        writePosition(serv(kMrS),fin);
    end
    
    pause(0.1); % ожидание в случае изменения режима
    
    %while fin>=0.13
        %fin=fin-0.03;
        fin=0.13;
        fi=(1.132674-fin)*180*6.732/13.5;
        cla
        p1=plot(xa,ya,'g','LineWidth',5); % Изобрачение рабочей области манипулятора
        p2=plot(xc,yc,'k-o','LineWidth',3,'MarkerSize',4); % Изображение текужего положения манипулятора
        p3=plot(arm123x,arm123y,'r x','LineWidth',2,'MarkerSize', 10); % Изображение центра масс манипулятора
        p4=plot(0,0.08,'b x','LineWidth',2,'MarkerSize', 10); % Изображение центра масс дрона

        PicGrip(x,y,fi);

        leg=legend([p1 p2 p3 p4],'Work Area','Manipulator','Mass center of manipulator','Mass center of drone');
        set(leg,'FontSize',14,'FontName','Book Antiqua','FontWeight','Bold','Location','NorthWest');
        
        datAng(4,2)={fi};
        set(TabAng,'Data',datAng);
        
        if SwC>=2
            SensData(Ard);
            writePosition(serv(kMrS),fin);
        end
        
        pause(0.1)
        
%         val = get(GrCont,'Value'); % проверяем значение кнопки с тэгом ChStop
%         if (val~=2)
%             break
%         end
        
   %end
end

end

% Функция остановки функционирования хвата
function GripStop(src,evt)

global serv Ard DevCon fi

[kMrS,ChMot]=NumbMot({'Servo'}); % Проверка количества моторов Servo
SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора

handles = guihandles(src); % записываем в структуру handles указатели на объекты приложения
% val = get(handles.ChStop,'Value'); % проверяем значение кнопки с тэгом ChStop

% if (val~=0) && (ChSt==0)
%     set(handles.ChStop,'Value',0); % возвращение кнопки в исходное положение, если хват не функционировал
% else
%     HoDr=0; % переключатель кнопок Hold/Drop/Stop
%     pause(0.1); % ожидание в случае изменения режима
% end

if SwC>=2
    SensData(Ard);
    fin=1.132674-(fi*13.5)/(180*6.732);
    writePosition(serv(kMrS),fin);
end

end

% Функция автоматического захвата объекта
function UltraCheck(src,evt)

global TabSens SwC x0 GrCont

% записываем в структуру handles указатели на объекты приложения
handles = guihandles(src);

% берем текст из строки ввода (координата Х)
str = get(handles.edtX, 'String');
x1=str2num(str);
x=x0;

% берем текст из строки ввода (координата Y)
str2 = get(handles.edtY, 'String');
y2=str2num(str2);

if SwC==2
    Tsens=get(TabSens,'Data');
    k=0;
    SU=cell2mat(Tsens(3,3));
    if SU>0.06
        x=x1;
        x1=x1+(SU-0.06);
        y=y2;
        y1=y2;
        InitData=PlotLocation(x,y,x1,y1);
        pause(0.1);
    end
    while k~=2
        if (cell2mat(Tsens(3,3))>=0.03 && cell2mat(Tsens(3,3))<=0.4) && k==0
            str2 = get(handles.edtY, 'String');
            y=str2num(str2);
            y1=y+0.003;            
            InitData=PlotLocation(x,y,x1,y1);
            yUp=y1;
        else
            if (cell2mat(Tsens(3,3))>=0.03 && cell2mat(Tsens(3,3))<=0.4) && k==1
                str2 = get(handles.edtY, 'String');
                y=str2num(str2);
                y1=y-0.003;
                InitData=PlotLocation(x,y,x1,y1);
                yD=y1;
            else
                k=k+1;
                y=y1;
                y1=y2;
                InitData=PlotLocation(x,y,x1,y1);
                pause(0.3);
            end
        end
        pause(0.16);
        Tsens=get(TabSens,'Data');
        
        val = get(GrCont,'Value'); % проверяем значение кнопки с тэгом ChStop
        if (val==3)
            break
        end
    end
end

SensData(Ard);

pause(1)

Tsens=get(TabSens,'Data');
d=cell2mat(Tsens(3,3));

y=y1;
y1=yD+(yUp-yD)/2-0.01;
InitData=PlotLocation(x,y,x1,y1);

pause(0.1);

x=x1;
x1=x1+d+0.015;
InitData=PlotLocation(x,y,x1,y1);

pause(0.2);

% GH = get(GrHo,'Value'); % Считывание подключения Arduino
% if GH~=1
%     set(GrHo,'Value',1); % подключение Arduino для включения питания
%     GripHold(src);
%     set(GrHo,'Value',0);
% end
%angMax=0.88;
%angMin=0.13;
%SlowServo(angMax,angMin,serv(4),angMax);

pause(0.3);

y=y1;
y1=y1+0.04;
InitData=PlotLocation(x,y,x1,y1);

pause(0.2);

x=x1;
x1=0.22;
y=y1;
y1=0;
InitData=PlotLocation(x,y,x1,y1);

end

% Функция поворота гриппера
function GripRotate(src,evt)

global p PROTOCOL_VERSION TabAng GrCont DevCon

datAng=get(TabAng,'Data');
GamAng=cell2mat(datAng(5,2));
psi=int32((60+GamAng)/0.29); %0.3516

SwC = get(DevCon,'Value'); % Считывание типа подключения манипулятора

if (SwC>=2)
    write2ByteTxRx(p, PROTOCOL_VERSION, 15,30,psi);
    ChButs(SwC); % Мониторинг текущих параметров датчиков и моторов
end

end