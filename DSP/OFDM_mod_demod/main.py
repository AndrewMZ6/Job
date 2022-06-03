import signals
import numpy as np
from matplotlib import pyplot as plt

bits = signals.bit_gen.bits(0, 2, 1648)
p = signals.bit_gen.qpsk(bits)

t = signals.bit_gen.ofdm(p)

print(len(t))

plt.plot(abs(np.fft.fft(t)))
plt.show()