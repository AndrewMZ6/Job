%% Анализатор сигналов EXA N9010B USB visa
% Этот блок игнорируется если соединение происходит через LAN см. блок "EXA N9010B LAN"

exa = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x2A8D::0x1B0B::MY60240336::0::INSTR', 'Tag', '');

% Create the VISA object if it does not exist
% otherwise use the object that was found.
if isempty(exa)
    exa = visa('AGILENT','USB0::0x2A8D::0x1B0B::MY60240336::0::INSTR');
else
    fclose(exa);
    exa = exa(1);
end

exa.OutputBufferSize = 1e7;
exa.InputBufferSize = 1e7;
exa.timeout = 10;

fopen(exa);

%% Анализатор сигналов EXA N9010B LAN
% Этот блок игнорируется если соединение происходит через USB см. блок "EXA N9010B USB visa"

% Чтобы посмотреть ip используйте экранную клавиатуру. Win+R -> cmd ->
% ipconfig/all
exa = instrfind('Type', 'tcpip', 'RemoteHost', '192.168.073', 'RemotePort', 5025, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(exa)
    exa = tcpip('192.168.073', 5025);
else
    fclose(exa);
    exa = exa(1);
end

exa.OutputBufferSize = 1e7;
exa.InputBufferSize = 1e7;
exa.timeout = 10;

fopen(exa);

%% Получение данных от анализатора сигналов EXA N9010B
% этот блок общий как для LAN так и для USB и запускается после соединения с инструментом

acq_time = 2000e-6;
samp_rate = fsamp;
cent_freq = fcent;

fprintf(exa, '*RST;*CLS');

% Настройка режима и конфигурации
fprintf(exa, 'INST:SEL BASIC');
fprintf(exa, 'CONFigure:WAVeform');

fprintf(exa, ['FREQ:CENT ', num2str(cent_freq)]);
% set(exa, 'SATrigger', 'RFBurst');

fprintf(exa, ':INIT:CONT OFF');
fprintf(exa, [':WAV:SWE:TIME ', num2str(acq_time)]);

fprintf(exa,':INIT:IMM');


%Get IQ data
fprintf(exa, [':WAV:SRAT ', num2str(samp_rate)]);

% Get the interface object
% Tell it the precision
fprintf(exa,':FORM:DATA ASCii');

% fprintf(interface,':FORM:DATA MATLAB');

fprintf(exa,':READ:WAV0?');

fprintf(exa,'*WAI');

% exadata содержит сырые данные с анализатора типа <char>
% '2.306786738E-02,1.153779309E-02,1.795095950E-02,...'
exadata = fscanf(exa);
% data массив чисел <double>
data = str2num(exadata);
