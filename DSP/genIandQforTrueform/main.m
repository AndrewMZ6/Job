%% Сгенерировать ОФДМ символ 

guardSize = 100;
fftSize = 2048;
sig = OFDM_mod(guardSize, fftSize);

WG_function('USB0::0x0957::0x4B07::MY53401534::0::INSTR', real(sig), 30.72e6, 'Iofdm', 1);
WG_function('USB0::0x0957::0x4B07::MY53401534::0::INSTR', imag(sig), 30.72e6, 'Qofdm', 2);

figure;
plot(abs(fft(sig)));

%% 
sigreal = load('sigreal.txt');
sigimag = load('sigimag.txt');

WG_function('USB0::0x0957::0x4B07::MY53401534::0::INSTR', sigreal, 30.72e6, 'Iofdm', 1);
WG_function('USB0::0x0957::0x4B07::MY53401534::0::INSTR', sigimag, 30.72e6, 'Qofdm', 2);


sigCompl = complex(sigreal, sigimag);

figure; plot(sigreal);
%% JSON processor

json = load('response_1649219764788.txt');

k = 0;
for i = 1:2:length(json)
    k = k + 1;
    I(k) = json(i);
    Q(k) = json(i + 1);
end

compl = complex(I, Q);
compl_spec = fft(compl);

figure;
plot(abs(compl_spec(12:end - 10)));