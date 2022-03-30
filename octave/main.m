clc; 
clearvars;
close all;
pkg load communications;

%% ���� �������

% ������ ���������
M = 4;

% ����� �������������� ���
N = 2000;

% ������� �������������
fs = 50e6;

% ������� �������
fc = 10e6;

% ���������� ������������
L = 10;

% ���������� ����� ����� ������������
N_interpolated = 1024*L;

% ��������� ���
timeline = 0:1/fs:N_interpolated/fs - 1/fs;

% ��������� ���
freqline = 0:fs/N_interpolated:fs - fs/N_interpolated;

%% ������������ OFDM �������

% ������������ �������������� ���
bits = randi([0, 3], 1, N);

% QPSK ��������� 
mod = qammod(bits, M);

% ����������� ���������� � �������� ����������
spectrum = zeros(1, 1024);
spectrum(101:924) = mod(1:824);

% ������ ������� OFDM �������
figure;
plot(abs(spectrum));

% ��������� ������� OFDM �������
scatterplot(spectrum);

% ����� �������
spec_shifted = fftshift(spectrum);

figure; plot(abs(spec_shifted));


% ������ �����������������
spec_interp = [spec_shifted(1:512), zeros(1, N_interpolated - 1024), spec_shifted(513:1024)];

figure; plot(abs(spec_interp));

% ������� ������������������ ������� �� ��������� �������
sig_shifted_time = ifft(spec_interp);

% ��������� ��������� � ������������ ������������
I = real(sig_shifted_time);
Q = imag(sig_shifted_time);

% ������� �� ������� ��������� � ������������ ������������ � ������������
summary = I.*cos(2*pi*fc*timeline) - Q.*sin(2*pi*fc*timeline);

figure; plot(freqline, abs(fft(summary)));
xlabel('frequency, Hz');
scatter(real(fft(summary)), imag(fft(summary)), 'filled');

%% ��������� ����������� ������������� ������ ���������������

% ������������ ���������� �����
k1 = 0.9;
k2 = 0.6;
k3 = 0.4;

% ������������ ��� �����
sig1 = [summary, zeros(1, 4)]*k1;
sig2 = [zeros(1, 2), summary, zeros(1, 2)]*k2;
sig3 = [zeros(1, 4), summary]*k3;

% ������������ �����
sig_time_channel = sig1 + sig2 + sig3;

% ���������� ���� 
##sig_time_channel = awgn(sig_time_channel, 15, 'measured');

% ������ OFDM ������� ����� ������������� ������
figure;
plot(freqline, abs(fft(sig_time_channel(1:10240))));
xlabel('frequency, Hz');

% ��������� OFDM ������� ����� ������������� ������
scatterplot(fft(sig_time_channel(1:10240)));

% ������������ ��������������� ����������� �������
comp = [summary, zeros(1, 4)]*k1;

% ����������� ������� ���� � ���������� ������
sig_time_comp = sig_time_channel - comp;
sig_time_comp = sig_time_comp(3:10242);

% ������ OFDM ������� ����� ���������� �����������
spec_comp = fft(sig_time_comp);
figure;
plot(freqline, abs(spec_comp));
xlabel('frequency, Hz');

% ��������� OFDM ������� ����� ���������� �����������
scatterplot(spec_comp); xlim([-0.4, 0.4]);

%% � �������� �����

% �������������� ������� (������� �� ������� �������)
I_baseband = sig_time_comp.*cos(2*pi*fc*timeline);
Q_baseband = sig_time_comp.*(-sin(2*pi*fc*timeline));

% ����������� ������������ ������� �� ��������� � ������������ ������������
compl2 = complex(I_baseband, Q_baseband);


figure; plot(freqline, abs(fft(compl2)));
xlabel('frequency, Hz');

scatterplot(fft(compl2));

% ��������� (����������� �� ��������������� ������������ � ����-��������)
compl2_spec = fft(compl2);
compl2_spec2 = [compl2_spec(1:512), compl2_spec(end-511:end)];

% ����� ������� �������
compl2_spec2_shifted = fftshift(compl2_spec2);

scatterplot(compl2_spec2_shifted);
figure; plot(abs(compl2_spec2_shifted));

% ������ ������������ ������� ������
ocen = compl2_spec2_shifted(101:924)./spectrum(101:924);

figure; plot(abs(ocen));

scatterplot(ocen)

%% ������������� ������ ��� ��������� ������� OFDM �������

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