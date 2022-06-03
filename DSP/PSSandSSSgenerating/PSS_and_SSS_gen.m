clearvars;
close all;
clc;
pkg load communications;

% PSS generation
N2ID = 2;
x(1:7) = [1, 0, 0, 1, 1, 0, 1];

% M -sequence calculation
for i = 1: 127 - 7
  x(i + 7) = mod((x(i+4) + x(i)), 2);
end

% calculate m and dpss for 3 values of N2ID
for N2ID = 0:2
  for n = 0:126
    m = mod((n + 43*N2ID), 127);
    dpss(N2ID + 1, n + 1) = 1 - 2*x(m + 1);
  end
end

% SSS generation
##N1ID = 95;

% 2 M-sequences for generating SSS
x0(1:7) = [1, 1, 0, 1, 1, 1, 0];
x1(1:7) = [1, 0, 1, 1, 0, 0, 0];

for i = 1:231
  x0(i + 7) = mod((x0(i + 4) + x0(i)), 2);
  x1(i + 7) = mod((x0(i + 4) + x1(i)), 2);
end

% generating SSS
for N1ID = 0:335
  m0 = 15*fix(N1ID/112) + 5*N2ID;
  m1 = mod(N1ID, 112);

  for n = 0:126
    dsss1(N1ID + 1, n + 1) = 1 - 2*mod(x0(n + m0 + 1), 127);
    dsss2(N1ID + 1, n + 1) = 1 - 2*mod(x1(n + m1 + 1), 127);
  end
  
  dsss = dsss1.*dsss2;
end

ssblock = zeros([240 4]); 
ssblock(56:182,1) = 1*dpss(N2ID+1,:);
ssblock(56:182,3) = 2*dsss(N1ID+1,:);
%% 4 ѕостроение сигналов в частотной области
figure
imagesc(abs(ssblock)) 
caxis([0 4]);
axis xy;
xlabel('OFDM symbol');
ylabel('Subcarrier')