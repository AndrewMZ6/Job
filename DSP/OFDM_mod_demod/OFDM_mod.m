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
            infoScNum = fftSize - 2*guardSize - 1;
            informationalIndexes1 = 1:floor(infoScNum/2);
            informationalIndexes2 = ceil(infoScNum/2):infoScNum;
            bits = randi([0, 1], 1, infoScNum*2);
            mod = (qammod(bits', 4, 'InputType', 'bit'))';
            spec = [zeros(1, guardSize), mod(informationalIndexes1), 0, ...
                mod(informationalIndexes2), zeros(1, guardSize)];
            ofdmTime = ifft(spec);
            params.guardSize = guardSize;
            params.fftSize = fftSize;
            params.bits = bits;
end