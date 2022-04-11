clc 
clear all
close all
Nid1 = 0;
Nid2 = 0;
%% 1 Формирование сигнала PSS
x(1:7) = [0 1 1 0 1 1 1];
for i = 1 : 127
 x(i + 7) = mod((x(i + 4) + x(i)),2);
end

for Nid2 = 0:2
  for n = 0:126
    m = mod((n+43*Nid2), 127);
    dpss(Nid2+1,n+1) = 1 - 2*x(m+1);
  end
end

%% 2 Формирование сигнала SSS
x0(1:7) = [ 1 0 0 0 0 0 0];
x1(1:7) = [ 1 0 0 0 0 0 0];

for i = 1 : 300
 x0(i+7) = mod((x0(i+4) + x0(i)),2);
 x1(i+7) = mod((x1(i+1) + x1(i)),2);
end 

for Nid1 = 0:335
 m0 = 15*fix(Nid1/112) + 5*Nid2; 
 m1 = mod(Nid1,112);
 
 for n = 0:126
   d1(Nid1 + 1,n+1) = 1-2*mod(x0(n+m0+1),127);
   d2(Nid1 + 1,n+1) = 1-2*mod(x1(n+m1+1),127);
 end
 dsss = d1.*d2;
end
 
%% 3 Размещение сигналов в частотной области
##v = mod(Nid1,4);
##k = 1;
ssblock = zeros([240 4]); 
ssblock(56:182,1) = 1*dpss(Nid2+1,:);
ssblock(56:182,3) = 2*dsss(Nid1+1,:);
%% 4 Построение сигналов в частотной области
figure
imagesc(abs(ssblock)) 
caxis([0 4]);
axis xy;
xlabel('OFDM symbol');
ylabel('Subcarrier')