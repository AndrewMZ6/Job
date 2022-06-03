import numpy as np

class bit_gen:


	def bits(low = 0, high = 2, size = 10):
		bits = np.random.randint(low, high, size)
		return bits

	def qpsk(bits):

		moded = np.array([])
		for i in range(0, len(bits), 2):

			if bits[i]==0 and bits[i + 1]==0:
				moded = np.append(moded, -1 -1j)
			elif bits[i]==0  and bits[i + 1]==1:
				moded = np.append(moded, -1 +1j)
			elif bits[i]==1 and bits[i + 1]==0:
				moded = np.append(moded, +1 -1j)
			else:
				moded = np.append(moded, +1 +1j)

		return moded

	def ofdm(data):
		spec = np.append(np.append(np.zeros(100), data), np.zeros(100))
		ofdm_time = np.fft.ifft(spec)
		return ofdm_time

if __name__ == '__main__':
	print(True or False)
	