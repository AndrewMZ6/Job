clearvars; close all; clc;

load('167points_with_zero.mat');
input = 0:0.0000001:0.363;
y = polyval(coeffs, input);

k = ((polyval(coeffs, 0.1)/0.1) + (polyval(coeffs, 0.15)/0.15) + (polyval(coeffs, 0.2)/0.2) + ...
    ((polyval(coeffs, 0.25) - polyval(coeffs, 0.1))/(0.25 - 0.1)))/4;

% k = 3.6377/0.363;

LUT = dpd(coeffs, input, k);
predistorted_input = input + LUT;
predistorted_input(predistorted_input >= 0.363) = 0.363;

y2 = polyval(coeffs, predistorted_input);

figure;
plot(input, y, '--', 'LineWidth', 1.3); hold on;
plot(input, y2, 'LineWidth', 1.5); hold on;
xline(input(end));
grid on;
title('Amplifier input vs output');
xlabel('input, Volts');
ylabel('output, Volts');
legend('before dpd', 'after dpd');

% Если не использовать round то остаются скрытые цифры
M = containers.Map(round(input, 7), predistorted_input);

fs = 20e6; fc = 5e5; n = 1024*10; fc2 = 10e5;

freq_line = 0:fs/n:fs - fs/n;
bb_freq_line = freq_line - fs/2;
time_line = 0:1/fs:(n - 1)/fs;
sig = sin(2*pi*fc*time_line);
sig = sig*0.35;

amp = ampl(coeffs, sig);


figure; 
plot(sig); hold on;
plot(amp); grid on;
legend('original', 'amplified');
xlim([0, 100])

figure;
semilogy(bb_freq_line/1e6, abs(fftshift(fft(sig))), 'Black', 'LineWidth', 2); hold on;
semilogy(bb_freq_line/1e6, abs(fftshift(fft(amp)))); grid on;
xlabel('freq, MHz');
legend('original', 'amplified');


figure;
plot(input, predistorted_input, 'r--', 'LineWidth', 1.3); hold on;
plot(input, input, 'green--', 'LineWidth', 1.1); grid on;
ylim([0, 0.4]); title('AM / AM характеристика предысказителя')
xlabel('вход DPD, Volts');ylabel('выход DPD, Volts');
legend('predistorter output', 'predistorter input');
%% Применение карты на синусоиде
clc; close all; clearvars

N = 1000;
fs = 100e6; fc = 50e5; 
timeline = 0:1/fs:(N - 1)/fs; 
freqline = 0:fs/N:fs - 1/N;
bb_freq_line = freqline - fs/2;
load("167points_with_zero.mat");
load('M_3M630T001_rounded_7.mat');
u = 0.315;


sig = sin(2*pi*fc*timeline);
m = max(sig);
kk = u/m;
sig = sig*kk;

max(sig)

% округляем синусоиду
r_sin = round(sig, 7, 'decimals');

dpded = zeros(1, length(sig));

for i = 1:length(sig)
    if r_sin(i) >= 0
        dpded(i) = M(r_sin(i));
    else
        dpded(i) = -M(abs(r_sin(i)));
    end
end

amp_dpded = ampl(coeffs, dpded);
amp = ampl(coeffs, sig);
L = length(amp);

figure;
plot(bb_freq_line, 10*log10(abs(fftshift(fft(amp)/L)))); hold on;
plot(bb_freq_line, 10*log10(abs(fftshift(fft(awgn(amp_dpded, 300, 'measured')/L)))), 'LineWidth', 2); grid on;
xlabel('freq, MHz');
legend('no dpd', 'dpd');

figure;
plot(bb_freq_line,(abs(fftshift(fft(amp)/L)))); hold on;
plot(bb_freq_line,(abs(fftshift(fft(awgn(amp_dpded, 300, 'measured')/L)))), 'LineWidth', 2); grid on;
xlabel('freq, MHz');
legend('no dpd', 'dpd');

% figure; plot(10*log10(abs(fftshift(fft(awgn(amp_dpded, 300, 'measured'))))));
% figure; plot(abs(fftshift(fft(amp_dpded))));

figure; 
plot(amp); hold on;
plot(amp_dpded); grid on;
legend('no dpd', 'dpd');
xlim([0, 100])

% figure;
% semilogy(abs(fftshift(fft(amp)))); hold on;
% % semilogy(abs(fftshift(fft(amp_dpded))), 'LineWidth', 3);
% g = abs(fftshift(fft(amp_dpded)));

grid on;

%% Применение карты на двух тонах

clc; close all; clearvars;
fs = 20e6; 
fc = 5e5; 
n = 1024*10; 
fc2 = 10e5;
d0 = 0.315;
load("167points_with_zero.mat");
load("M_3M630T001_rounded_7.mat");

[sig, t, f] = signals.two_sins(n, fs, fc, fc2);
bbf = f - fs/2;
L = length(sig);

m = max(sig);

p = d0/m;

% o = 4.85;
sig = sig*p;
sig_r = round(sig, 7);
amp_nodpd = ampl(coeffs, sig);

dpded2 = zeros(1, length(sig));

for i = 1:length(sig)
    if sig_r(i) >= 0
        dpded2(i) = M(sig_r(i));
    else
        dpded2(i) = -M(abs(sig_r(i)));
    end
end

amp_dpd = ampl(coeffs, dpded2);

figure;
plot(t, sig); hold on;
plot(t, dpded2); hold on;
plot(t, amp_nodpd); hold on;
plot(t, amp_dpd, 'LineWidth', 1.5);
legend('Original', 'Predistorted original', 'No dpd', 'Dpd');
xlim([0, 5e-6]); grid on;

figure;
plot(bbf, abs(fftshift(fft(amp_nodpd)/L)), 'LineWidth', 3); hold on;
r = plot(bbf, abs(fftshift(fft(amp_dpd)/L)), 'LineWidth', 1.5); grid on;
r.Color = 'red';
r.LineStyle = '--';
title('two sins spectrum');
xlabel('freq, x100 kHz');
ylabel('amplitude');

% spec_dpd = fft(amp_dpd)/L;
spec_dpd = fft(awgn(amp_dpd, 150, 'measured'))/L;

spec_nodpd = fft(amp_nodpd)/L;
spec_y_nodpd_power = 10*log10(abs(fftshift(spec_nodpd)));
spec_y_dpd_power = 10*log10(abs(fftshift(spec_dpd)));

figure;
plot(bbf, spec_y_nodpd_power, 'LineWidth', 3); hold on;
p = plot(bbf, spec_y_dpd_power, 'LineWidth', 1.5); grid on;
p.Color = 'yellow';
title('two sins spectrum');
xlabel('freq, x100 kHz');
ylabel('power, dB');

% 
% figure;
% plot(input, predistorted_input, 'r--', 'LineWidth', 1.3); hold on;
% plot(input, input, 'green--', 'LineWidth', 1.1); grid on;
% ylim([0, 0.4]); title('AM / AM характеристика предысказителя')
% xlabel('вход DPD, Volts');ylabel('выход DPD, Volts');
% legend('predistorter output', 'predistorter input');
% 
% 
% 
% WG.load_data('default', sig_r, 1, fs, 'Twosins');
% WG.load_data('default', sig_r, 2, fs, 'Twosins');
%% Применение карты на OFDM
close all; clc; clearvars;
fs = 50e6; fc = 10e6; 

load("167points_with_zero.mat");
load('M_3M630T001_rounded_7.mat');
load('k.mat');

% u Регулирует амлитуду OFDM сигнала, приходящего на DPD
% максимальное значение u = 0.316104
u = 0.316;

NN = 5*1024;

% Если частота дискретизации = fs и NN в Х раз больше длины OFDM символа, то
% от будет занимать 1/X от fs

test = signals.ofdm(100, 1024);
spec = fft(test);

% занимаемая полоса
BW = ((length(test)/NN)*fs)/1e6; % МГц
disp(['Занимаемая полоса = ' ,num2str(BW), ' МГц'])

zero_paded = [spec(1:512), zeros(1, NN - 1024), spec(513:end)];
zero_time = ifft(zero_paded);

timeline = 0:1/fs:(length(zero_time) - 1)/fs; 
freqline = 0:fs/length(zero_time):fs - 1/length(zero_time);
bb_freq_line = freqline - fs/2;

carr_sin = -sin(2*pi*fc*timeline);
carr_cos = cos(2*pi*fc*timeline);

toDAC = real(zero_time).*carr_cos + imag(zero_time).*carr_sin;

% WG.load_data('default', real(zero_time).*carr_cos, 1, fs, 'NODPD');
% WG.load_data('default', imag(zero_time).*carr_sin, 2, fs, 'NODPD');

m = max(toDAC);
kk = u/m;
toDAC = toDAC*kk;
max(toDAC)

amplified_OFDM = ampl(coeffs, toDAC);

dpded3 = zeros(1, length(toDAC));
toDAC_r = round(toDAC, 4);

TF = zeros(1, length(toDAC_r));
for i = 1:length(toDAC_r)
    if isKey(M, abs(toDAC_r(i)))
        TF(i) = 1;
    else
        TF(i) = -1;
    end
end

for i = 1:length(toDAC)
    if toDAC_r(i) >= 0
        dpded3(i) = M(toDAC_r(i));
    else
        dpded3(i) = -M(abs(toDAC_r(i)));
    end
end


amplified_OFDM_dpd = ampl(coeffs, dpded3);

figure; 
plot(toDAC, 'LineWidth', 1.5); hold on;
plot(dpded3, 'LineWidth', 1.5); grid on; 
xlim([4232, 4259]);
ylabel('Амплитуда, В');
legend('orginal', 'dpded');
title('Сравнение оригинального сигнала и предыскажённого')

figure;
plot(timeline, amplified_OFDM); hold on;
plot(timeline, amplified_OFDM_dpd); grid on;
xlim([0, 1e-6]);
xlabel('Время, сек'); ylabel('Амплитуда, В');
legend('orginal', 'dpded');
title('Сравнение усиленного сигнала с DPD и без')

% % Тут не будет созвездия потому что это не комплексные значения

L = length(toDAC); 

figure;
plot(bb_freq_line/1e6, 10*log10(abs(fftshift(fft(toDAC))/L))); hold on;
plot(bb_freq_line/1e6, 10*log10(abs(fftshift(fft(amplified_OFDM))/L)), 'LineWidth', 1.5); hold on;
plot(bb_freq_line/1e6, 10*log10(abs(fftshift(fft(amplified_OFDM_dpd))/L)));
plot(bb_freq_line/1e6, 10*log10(abs(fftshift(fft(toDAC*k))/L)));
grid on;
xlabel('freq, MHz'); ylabel('power, dB');
legend('original', 'no dpd', 'dpd', 'ideal');
title('Спектры сигналов');


% WG.load_data('default', amplified_OFDM, 1, fs, 'NODPD');
% WG.load_data('default', amplified_OFDM, 2, fs, 'NODPD');
% 
% WG.load_data('default', amplified_OFDM_dpd, 1, fs, 'DPD');
% WG.load_data('default', amplified_OFDM_dpd, 2, fs, 'DPD');

% Проверка, если сначала предысказить, а потом уменьшить на какую-то
% величину

m2 = max(dpded3)
m3 = max(toDAC_r)
kk2 = 0.25;
newnondpded = (kk2/m3)*toDAC_r;
newnondpded_r = round(newnondpded, 7);
for i = 1:length(newnondpded_r)
    if toDAC_r(i) >= 0
        dpded5(i) = M(newnondpded_r(i));
    else
        dpded5(i) = -M(abs(newnondpded_r(i)));
    end
end

newdpded = (kk2/m2)*dpded3;

max(newnondpded)
max(newdpded)

amplified_OFDM_dpd_4 = ampl(coeffs, newdpded);
amplified_OFDM_dpd_5 = ampl(coeffs, dpded5);
amplified_OFDM_4 = ampl(coeffs, newnondpded);

figure;

plot(bb_freq_line/1e6, 10*log10(abs(fftshift(fft(amplified_OFDM_4))/L)), 'LineWidth', 1.5); hold on;
plot(bb_freq_line/1e6, 10*log10(abs(fftshift(fft(amplified_OFDM_dpd_4))/L))); hold on;
plot(bb_freq_line/1e6, 10*log10(abs(fftshift(fft(amplified_OFDM_dpd_5))/L))); hold on;

grid on;
xlabel('freq, MHz'); ylabel('power, dB');
legend('no dpd', 'dpd');
title('Спектры сигналов');