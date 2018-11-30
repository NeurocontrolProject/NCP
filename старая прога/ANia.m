%cd c:\work\nfb
x = load('D0000002','-ASCII')';
X = abs(fft(x(:,1000:end),2048,2));
f = linspace(0,250,2048);
T = 250*60;
Xbl = x(:,1000:T);
Xli = x(:,T+1:2*T);
Xri = x(:,2*T+1:3*T);
Xlr = x(:,3*T+1:4*T);
Xrr = x(:,4*T+1:5*T);
[b,a] = butter(4,[9 11]/125);
xnb = (filtfilt(b,a,x(:,1000:end)'))';
Xlif = (filtfilt(b,a,Xli'))';
Xrif = (filtfilt(b,a,Xri'))';
Xlrf = (filtfilt(b,a,Xlr'))';
Xrrf = (filtfilt(b,a,Xrr'))';
Xblf = (filtfilt(b,a,Xbl'))';


Cbl0 = Xblf*Xblf'/size(Xbl,2);
Cli0 = Xlif*Xlif'/size(Xlif,2);
Cri0 = Xrif*Xrif'/size(Xrif,2);
    %regularize covariances
Cbl = Cbl0 + 0.1 * trace(Cbl0) * eye(19) / 19;
Cli = Cli0 + 0.1 * trace(Cli0) * eye(19) / 19;
Cri = Cri0 + 0.1 * trace(Cri0) * eye(19) / 19;
[VLIBL DLIBL] = eig(Cli,Cbl);
[VRIBL DRIBL] = eig(Cri,Cbl);
[VLIRI DLIRI] = eig(Cri,Cli);
[VRILI DRILI] = eig(Cli,Cri);
W = [VLIRI(:,1) VLIRI(:,end) VRILI(:,1) VRILI(:,end) ];
Z = W'*xnb;
clear Zc;
for k=1:size(W,2)
    Zc(k,:) = conv(ones(1,250),Z(k,:).^2);
end;
S = ones(1,size(Z,2));
S(1:T-1000)=1;
S(T-1000+1:2*T-1000)=1;
S(2*T-1000+1:3*T-1000)=2;
S(3*T-1000+1:4*T-1000)=1;
S(4*T+1-1000:5*T-1000)=2;

% build shrinkage (linear) classifier
obj = train_shrinkage(Zc(:,T-1000+1:end-2*T)',S(T-1000+1:end-2*T)');
W12 = obj.W;
U = W12'*Zc; % control signal
figure
plot(W12'*Zc)
grid