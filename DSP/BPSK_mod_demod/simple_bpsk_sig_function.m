function [BPSKsig, params]= genBPSK(L, fc, fs, size)

% [BPSKsig, params]= genBPSK(L, fc, fs, size)
%
% Функция генерирующая БПСК модулированный сигнал (НЕ комплексный)
% на некоторой несущей частоте fc
%
% Входные аргументы:
% L - коэффициент интерполяции.     По умолчанию 10
% fc - частота несущей.             По умолчанию 10 МГц
% fs - частота дискретизации.       По умолчанию 50 МГц
% size - количество случайныйх бит. По умолчанию 1000.
%
% Выходные аргументы:
% BPSKsig - вещественный сигнал на несущей частоте
% params - пакет(cell) параметров необходимый для демодуляции принятого сигнала
%
% При заданных по умолчанию параметрах функция генерирует сигнал с
% количеством отсчётов 10 000, длительностью 200 мкс. Следоватльно чтобы в
% не децимировать принятый с осциллографа сигнал, необходимо установить
% развертку на осциллографе равной 200мкс*(50 000/ 10 000) = 1000 мкс.


if nargin <4; size = 1000;end
if nargin <3; fs=50e6;end
if nargin <2; fc=10e6;end
if nargin <1; L = 10; end

% длина интерполированной последовательности
N = L*size;
% Количество посылок в 50 000 точек осциллографа 
k = 50e3/N;

% Длительность сигнала в микросекундах
tau = (N/fs)*1e6;
% Время развертки осциллографа в микросекундах. Это время показывает какое
% время развертки должно быть установлено на осциллографе, чтобы в него
% влезало ровно k посылок (НЕ на деление, а на полный экран).
Tsw = tau*k;
disp(['длительность сгенерированного сигнала = ', num2str(tau), ' мкс']);
disp(['количество посылок на 50 000 точек = ', num2str(k)]);

DATA = randi([0 1], 1, size);

% NRZ
for i=1:size
    if (DATA(i)==1)
        MOD_DATA(i) = 1;
    else
        MOD_DATA(i) = -1;
    end
end

% Интерполяция
p=1; q=1;
for ind=1:size
    MOD_DATA_interp(q:L*p) = MOD_DATA(ind);
    q=(p*L+1);
    p=p+1;
end

t = (0:length(MOD_DATA_interp)-1)/fs;
car_sig = sin(2*pi*fc*t);

BPSKsig=MOD_DATA_interp.*car_sig;

% создание пакета с необходимыми данными для демодуляции
params = {BPSKsig, car_sig, L, DATA};
