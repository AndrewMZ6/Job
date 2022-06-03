function [ofdmTime, params] = OFDM_mod(guardSize, fftSize)

            % function = generateOFDM(this)
            % -------------------------------------------------------------
            % генерирует случайную битовую последовательность (расчёт
            % размера последовательности смотри в методе get.L) и
            % записывает её в свойство объекта bits
            % 
            % this.bits = randi([0, 1], 1, this.L*2);
            % 
            % модулирует полученную битовую последовательность QPSK:
            % 
            % mod = (qammod(this.bits', 4, 'InputType', 'bit'))';
            % 
            % добавляет защитные интервалы слева и
            % справа, ноль для несущей ставится на 512 отсчёт:
            % 
            % spec = [zeros(1, this.guardSize), mod(1:floor(this.L/2)), 0, ...
            %    mod(ceil(this.L/2):this.L), zeros(1, this.guardSize)];
            % 
            % при L = 823, floor(L/2) = 411, ceil(L/2) = 412. Таким образом
            % ноль попадает в нужный 512 отсчёт.
            % Полученный спектр переводится во временную область и
            % записывается в свойство ofdmTime
            %
            % this.ofdmTime = ifft(spec);
            %
            % -------------------------------------------------------------
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