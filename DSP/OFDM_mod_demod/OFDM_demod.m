 function [demodedBits, err] = OFDM_demod(outerSig, params)
            % -----------------------------------------------------------
            % Принимает на вход OFDM сигнал во временной области ofdmTime:
            %
            % demodRx(this)
            %
            % подсчитывает спектр входного OFDM сигнала:
            % 
            % ofdmSpec = fft(ofdmTime);
            %
            % вырезает информационные отсчёты, игнорируя защитные интервалы
            % и ноль несущей:
            %
            % noGuardsAndZeros = [ofdmSpec(101:512), ofdmSpec(514:924)];
            %
            % демодулирует информационные отсчёты:
            % 
            % demodedBits = (qamdemod(noGuardsAndZeros', 4, 'OutputType', 'bit'))';
            % 
            % На выход подается демодулированная битовая последовательность
            % demodedBits
            % -------------------------------------------------------------
            ofdmSpec = fft(outerSig);
            % guardSiz
            noGuardsAndZeros = [ofdmSpec(params.guardSize + 1:(params.fftSize/2 - 1)), ofdmSpec((params.fftSize/2 + 1):params.fftSize - params.guardSize)];
            demodedBits = (qamdemod(noGuardsAndZeros', 4, 'OutputType', 'bit'))';
            [~, err] = biterr(params.bits, demodedBits);
        end