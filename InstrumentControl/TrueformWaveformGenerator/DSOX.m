classdef DSOX
    %DSOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods (Static)
        function vmax = get_vmax(connID, chNum)
            if strcmpi(connID, 'default')
                connID = 'USB0::0x0957::0x179B::MY52447296::0::INSTR';
            end
           
            OSCI_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connID, 'Tag', '');
            
            if isempty(OSCI_Obj)
                OSCI_Obj = visa('Agilent', connID);
            else 
                fclose(OSCI_Obj);
                OSCI_Obj = OSCI_Obj(1);
            end
        
            % Открыть соединение с инструментом
            fopen(OSCI_Obj);
        
            % Запросить RANGe
            command = [':MEASure:VMAX? CHANnel', num2str(chNum)];
            vmax = str2num(query(OSCI_Obj, command)); 
            
            % прочитать строку ошибок
            request = ':SYSTEM:ERR?';
            instrumentError = query(OSCI_Obj, request);
            disp(instrumentError);
            
            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);
        end
        function range = get_screen_range(connID, chNum)
            if strcmpi(connID, 'default')
                connID = 'USB0::0x0957::0x179B::MY52447296::0::INSTR';
            end
           
            OSCI_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connID, 'Tag', '');
            
            if isempty(OSCI_Obj)
                OSCI_Obj = visa('Agilent', connID);
            else 
                fclose(OSCI_Obj);
                OSCI_Obj = OSCI_Obj(1);
            end
        
            % Открыть соединение с инструментом
            fopen(OSCI_Obj);
        
            % Запросить RANGe
            command = [':CHANnel', num2str(chNum), ':RANGe?'];
            range = str2num(query(OSCI_Obj, command));
            
            % прочитать строку ошибок
            request = ':SYSTEM:ERR?';
            instrumentError = query(OSCI_Obj,request);
            disp(instrumentError);
            
            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);
        end
        function set_screen_range(connID, chNum, voltage)
            if strcmpi(connID, 'default')
                connID = 'USB0::0x0957::0x179B::MY52447296::0::INSTR';
            end
           
            OSCI_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connID, 'Tag', '');
            
            if isempty(OSCI_Obj)
                OSCI_Obj = visa('Agilent', connID);
            else 
                fclose(OSCI_Obj);
                OSCI_Obj = OSCI_Obj(1);
            end
        
            % Открыть соединение с инструментом
            fopen(OSCI_Obj);
        
            % Запросить RANGe
            command = [':CHANnel', num2str(chNum), ':RANGe ', num2str(voltage)];
            fwrite(OSCI_Obj, command); 
            
            % прочитать строку ошибок
            instrumentError = query(OSCI_Obj,':SYSTEM:ERR?');
            disp(instrumentError);
            
            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);
        end
    end
end

