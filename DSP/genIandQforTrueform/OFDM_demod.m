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
            ofdmSpecShifted = fft(outerSig);
            ofdmSpec = fftshift(ofdmSpecShifted);
            infoScNum = params.fftSize - 2*params.guardSize;
            infoHalf = infoScNum/2;
            L1 = params.guardSize + 1;
            L2 = params.guardSize + infoHalf;
            R1 = L2 + 2;
            R2 = R1 -1 + infoHalf;
            noGuardsAndZeros = [ofdmSpec(L1:L2), ofdmSpec(R1:R2)];
            demodedBits = (qamdemod(noGuardsAndZeros', 4, 'OutputType', 'bit'))';
            [~, err] = biterr(params.bits, demodedBits);
        end