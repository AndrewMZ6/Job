n_beams = 24;
n_DU = 1;
n_RU_per_DU = 2;
J = 8;
v_layers = 1;
Q_m = 8;
Rmax = 948/1024;
mu = 1;
Nrb = 273;
bw = 100e6;
Ts_mu = 3.5714e-05;
OH = 0.14;
f = 1;

##C??????? ???????? ?????? ???????? ????? ???? ?????????? ?? ??????? 1. ? ?????? ???????? 
##???? ???????? ?????? ???????? ???????? 1 ????? ???? ?????? UP ?????? ?? ??????? ???????.

C = 1e-6*J*(n_beams*v_layers*Q_m*f*Rmax*((Nrb*12)/Ts_mu)*(1 - OH));

##???????????? ?????????? ???????????, ??????????? ??? ???????? UP ???????, 
##???????????? ??? ?????????, ??? ?????? RU ???????????? ??????????? ????????? ???????? 
##???????? R
##MAX ????? ???? ??????? ???:

##Rmax = Ndu*Nru*Cmax;