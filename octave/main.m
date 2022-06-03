clc; 
% hello this is some changes fro another guy in your team
clearvars;
close all;
pkg load communications;

%% Пред расчёты

% �?ндекс модуляции
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
modulated = qammod(bits, M);

% Расстановка поднесущих и защитных интервалов
spectrum = zeros(1, 1024);
spectrum(101:924) = modulated(1:824);

% График спектра OFDM символа
figure;
plot(abs(spectrum));

% Созвездие спектра OFDM символа
scatterplot(spectrum);

% Сдвиг спектра
spectrum_shifted = fftshift(spectrum);

figure; 
plot(abs(spectrum_shifted));

% Спектр интерполированный
shifted_zeropadded = [spectrum_shifted(1:512), zeros(1, N_interpolated - 1024), spectrum_shifted(513:1024)];

figure; 
plot(abs(shifted_zeropadded));

% перевод интерполированного сигнала во временную область
tx_signal_time = ifft(shifted_zeropadded);

% Выделение синфазной и квадратурной составляющей
I = real(tx_signal_time);
Q = imag(tx_signal_time);

% посадка на несущую синфазной и квадратурной составляющей и суммирование
tx_signal_carr = I.*cos(2*pi*fc*timeline) - Q.*sin(2*pi*fc*timeline);

figure; 
plot(freqline, abs(fft(tx_signal_carr)));
xlabel('frequency, Hz');

figure;
scatter(real(fft(tx_signal_carr)), imag(fft(tx_signal_carr)), 'filled');

%% �?ммитация аналогового многолучевого канала распространения

% Коэффициенты ослабления лучей
k1 = 0.9;
k2 = 0.6;
k3 = 0.4;

% Формирование трёх лучей
sig1 = [tx_signal_carr, zeros(1, 4)]*k1;
sig2 = [zeros(1, 2), tx_signal_carr, zeros(1, 2)]*k2;
sig3 = [zeros(1, 4), tx_signal_carr]*k3;

% Суммирование лучей
signal_multipathed = sig1 + sig2 + sig3;

% Добавление шума 
##signal_multipathed = awgn(signal_multipathed, 15, 'measured');

% Спектр OFDM символа после многолучевого канала
figure;
plot(freqline, abs(fft(signal_multipathed(1:10240))));
xlabel('frequency, Hz');

% Созвездие OFDM символа после многолучевого канала
scatterplot(fft(signal_multipathed(1:10240)));

% Формирование компенсируещего аналогового сигнала
analog_comp = [tx_signal_carr, zeros(1, 4)]*k1;

% Компенсация первого луча в аналоговом тракте
two_rays_signal = signal_multipathed - analog_comp;
two_rays_signal = two_rays_signal(3:10242);

% Спектр OFDM символа после аналоговой компенсации
two_rays_spectrum = fft(two_rays_signal);

figure;
plot(freqline, abs(two_rays_spectrum));
xlabel('frequency, Hz');

% Созвездие OFDM символа после аналоговой компенсации
scatterplot(two_rays_spectrum); xlim([-0.4, 0.4]);

%% В цифровой части

% Преобразование частоты (перенос на нулевую частоту)
I_baseband = two_rays_signal.*cos(2*pi*fc*timeline);
Q_baseband = two_rays_signal.*(-sin(2*pi*fc*timeline));

% Воссоздание комплексного сигнала из синфазной и квадратурной составляющих
rx_complex_carr = complex(I_baseband, Q_baseband);


figure; 
plot(freqline, abs(fft(rx_complex_carr)));
xlabel('frequency, Hz');

scatterplot(fft(rx_complex_carr));

% Децимация (избавляемся от высокочастотной составляющей и зеро-паддинга)
rx_carr_spectrum = fft(rx_complex_carr);
spectrum_deci = [rx_carr_spectrum(1:512), rx_carr_spectrum(end-511:end)];

% Сдвиг спектра обратно
rx_spectrum_shifted = fftshift(spectrum_deci);

scatterplot(rx_spectrum_shifted);
figure; plot(abs(rx_spectrum_shifted));

% Оценка передаточной функции канала
estimation = rx_spectrum_shifted(101:924)./spectrum(101:924);

figure; plot(abs(estimation));

scatterplot(estimation)

%% �?спользование оценки для погашения другого OFDM символа

predistorted_spectrum = spectrum(101:924).*estimation;
predistorted_spectrum = [zeros(1, 100), predistorted_spectrum, zeros(1, 100)];
predistorted_time = ifft(predistorted_spectrum);

figure; 
plot(abs(predistorted_spectrum));

compensated = -predistorted_time + ifft(rx_spectrum_shifted);

figure; 
plot(20*log10(abs(compensated))); hold on; 
plot(20*log10(abs(predistorted_time))); hold off;
legend('after compensation', 'before compensation');
grid on;
