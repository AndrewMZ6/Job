classdef signals
    % methods:
    %   signals.two_sins(n, fs, f1, f2)
    %   create two sinusoids and sum it
    
    properties
        
    end
    
    methods (Static)
        function sig_sum = two_sins(n, fs, f1, f2)
            % временная ось для создания синусоиды
            timeline = 0:1/fs:(n - 1)/fs;
            
            % генерация синусоид
            sig1 = sin(2*pi*f1*timeline);
            sig2 = sin(2*pi*f2*timeline);
            
            % 1 сигнал, который будет отправлен на ЦАП 
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

