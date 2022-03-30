clc; 
clearvars;
close all;
pkg load communications;

%% Пред расчёты

% Индекс модуляции
M = 4;

% Число информационных бит
N = 2000;

% Частота дискретизации
fs = 50e6;

% Частота несущей
fc = 10e6;

% коэффциент интерполяции
L = 10;

% Количество точек после интерполяции
N_interpolated = 1024*L;

% Временная ось
timeline = 0:1/fs:N_interpolated/fs - 1/fs;

% Частотная ось
freqline = 0:fs/N_interpolated:fs - fs/N_interpolated;

%% Формирование OFDM символа

% Формирование информаицонных бит
bits = randi([0, 3], 1, N);

% QPSK модуляция 
mod = qammod(bits, M);

% Расстановка поднесущих и защитных интервалов
spectrum = zeros(1, 1024);
spectrum(101:924) = mod(1:824);

% График спектра OFDM символа
figure;
plot(abs(spectrum));

% Созвездие спектра OFDM символа
scatterplot(spectrum);

% Сдвиг спектра
spec_shifted = fftshift(spectrum);

figure; plot(abs(spec_shifted));


% Спектр интерполированный
spec_interp = [spec_shifted(1:512), zeros(1, N_interpolated - 1024), spec_shifted(513:1024)];

figure; plot(abs(spec_interp));

% перевод интерполированного сигнала во временную область
sig_shifted_time = ifft(spec_interp);

% Выделение синфазной и квадратурной составляющей
I = real(sig_shifted_time);
Q = imag(sig_shifted_time);

% посадка на несущую синфазной и квадратурной составляющей и суммирование
summary = I.*cos(2*pi*fc*timeline) - Q.*sin(2*pi*fc*timeline);

figure; plot(freqline, abs(fft(summary)));
xlabel('frequency, Hz');
scatter(real(fft(summary)), imag(fft(summary)), 'filled');

%% Иммитация аналогового многолучевого канала распространения

% Коэффициенты ослабления лучей
k1 = 0.9;
k2 = 0.6;
k3 = 0.4;

% Формирование трёх лучей
sig1 = [summary, zeros(1, 4)]*k1;
sig2 = [zeros(1, 2), summary, zeros(1, 2)]*k2;
sig3 = [zeros(1, 4), summary]*k3;

% Суммирование лучей
sig_time_channel = sig1 + sig2 + sig3;

% Добавление шума 
##sig_time_channel = awgn(sig_time_channel, 15, 'measured');

% Спектр OFDM символа после многолучевого канала
figure;
plot(freqline, abs(fft(sig_time_channel(1:10240))));
xlabel('frequency, Hz');

% Созвездие OFDM символа после многолучевого канала
scatterplot(fft(sig_time_channel(1:10240)));

% Формирование компенсируещего аналогового сигнала
comp = [summary, zeros(1, 4)]*k1;

% Компенсация первого луча в аналоговом тракте
sig_time_comp = sig_time_channel - comp;
sig_time_comp = sig_time_comp(3:10242);

% Спектр OFDM символа после аналоговой компенсации
spec_comp = fft(sig_time_comp);
figure;
plot(freqline, abs(spec_comp));
xlabel('frequency, Hz');

% Созвездие OFDM символа после аналоговой компенсации
scatterplot(spec_comp); xlim([-0.4, 0.4]);

%% В цифровой части

% Преобразование частоты (перенос на нулевую частоту)
I_baseband = sig_time_comp.*cos(2*pi*fc*timeline);
Q_baseband = sig_time_comp.*(-sin(2*pi*fc*timeline));

% Воссоздание комплексного сигнала из синфазной и квадратурной составляющих
compl2 = complex(I_baseband, Q_baseband);


figure; plot(freqline, abs(fft(compl2)));
xlabel('frequency, Hz');

scatterplot(fft(compl2));

% Децимация (избавляемся от высокочастотной составляющей и зеро-паддинга)
compl2_spec = fft(compl2);
compl2_spec2 = [compl2_spec(1:512), compl2_spec(end-511:end)];

% Сдвиг спектра обратно
compl2_spec2_shifted = fftshift(compl2_spec2);

scatterplot(compl2_spec2_shifted);
figure; plot(abs(compl2_spec2_shifted));

% Оценка передаточной функции канала
ocen = compl2_spec2_shifted(101:924)./spectrum(101:924);

figure; plot(abs(ocen));

scatterplot(ocen)

%% Использование оценки для погашения другого OFDM символа

aa = spectrum(101:924).*ocen;
aa = [zeros(1, 100), aa, zeros(1, 100)];
aa_t = ifft(aa);

figure; plot(abs(aa));

cc = -aa_t + ifft(compl2_spec2_shifted);

figure; 
plot(20*log10(abs(cc))); hold on; 
plot(20*log10(abs(aa_t))); hold off;
legend('after compensation', 'before compensation');
grid on;