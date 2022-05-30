classdef signals
    % методы:
    %   two_sins(n, fs, f1, f2)
    %   создаёт сумму двух синусоид с частотами f1 и f2 _|_|_
    %
    %   create qam4 ofdm baseband signal  -|__|-
    %   signals.ofdm(guardSize, fftSize)
    %
    %   demodulate ofdm signal using params
    %   signals.ofdm_demod(outerSig, params)

    
    properties
        
    end
    
    methods (Static)
        function [sig_sum, timeline, freqline] = two_sins(n, fs, f1, f2)
            %   [sig_sum, timeline, freqline] = signals.two_sins(n, fs, f1, f2)
            %   fs - частота дискретизации
            %   n - количество точек сигнала
            %   вторым и третьим параметром возвращает два массива - timeline и freqline
            %   timeline - массив отсчётов времени, использованный для построения синусоид
            %   freqline - массив отсчётов частот, использованный для построения спектра


            % временная ось для создания синусоиды
            timeline = 0:1/fs:(n - 1)/fs;

            % частотная ось для отображаения спектра
            freqline = 0:fs/n:fs - fs/n;
            
            % генерация синусоид
            sig1 = sin(2*pi*f1*timeline);
            sig2 = sin(2*pi*f2*timeline);
            
            % смесь
            sig_sum = real(sig1) + real(sig2);
        end
        function [ofdmTime, params] = ofdm(guardSize, fftSize)
            infoScNum = fftSize - 2*guardSize;
            infoHalf = infoScNum/2;
            L1 = guardSize + 1;
            L2 = guardSize + infoHalf;
            bits = randi([0, 1], 1, infoScNum*2);
            moded = (qammod(bits', 4, 'InputType', 'bit'))';
            spectrum = zeros(1, fftSize);
            spectrum(L1:L2) = moded(1:infoHalf);
            R1 = L2 + 2;
            R2 = R1 -1 + infoHalf;
            spectrum(R1:R2) = moded(infoHalf + 1:infoScNum);
            spectrum_shifted = fftshift(spectrum);
            ofdmTime = ifft(spectrum_shifted);
            
            params.guardSize = guardSize;
            params.fftSize = fftSize;
            params.bits = bits;
        end
        function [demodedBits, err] = ofdm_demod(outerSig, params)
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
    end
end

