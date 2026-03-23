clc
clear
close all

user=5;
inter=2;
if user<10
    fname=strcat('a0', num2str(user));
    name=strcat('a0', num2str(user),'.fqrs.txt');
else
    fname=strcat('a', num2str(user));
    name=strcat('a', num2str(user),'.fqrs.txt');
end

[signal fs]= rdsamp(fname,[], []);
% signal= rdsamp(fname);

ann=rdann(fname,'fqrs',[],[]);
ECG=signal;
tm=0.001:0.001:60;
tm=tm';
cName=fname;
qrsAf=ann;

dbFlag=0;                   % debug flag
graph=0;                    % enable/disable graphical representation
saveFig=0;                  % =1 => save figures of the processing phases
saveFigRRf=0;               % =1 => save estimated fetal RR figures

% fs = 1000;             % sampling frequency
% ---- Artifact canceling ----
% 去尖峰噪声
% X=FecgFecgImpArtCanc(ECG,fs,cName,graph,dbFlag);
X=FecgImpArtCanc(ECG,fs,cName,0,saveFig);
% close all

% ---- detrending  ----低通滤波
% Xd=FecgDetrFilt(X,fs,cName,graph,dbFlag);
Xd=FecgDetrFilt(X,fs,cName,0,saveFig);
% close all

% ---- Power line interference removal by notch filtering ----
% Xf=FecgNotchFilt(Xd,fs,cName,graph,dbFlag);
Xf=FecgNotchFilt(Xd,fs,cName,0,saveFig);
% close all

% ---- Independent Component Analysis ----
% Xm=FecgICAm(Xf,fs,cName,graph,dbFlag,saveFig);
Se=FecgICAm(Xf,fs,cName,0,dbFlag,saveFig);

% ---- Signal interpolation
[Se,fs]=FecgInterp(Se,fs,inter,cName,0);

% ---- Channel selection and Mother QRS detection
qrsM=FecgQRSmDet(Se,fs,cName,0,dbFlag,saveFig,qrsAf);

% ---- Mother QRS cancelling
Xr=FecgQRSmCanc(Se,qrsM,fs,cName,1,1,saveFig,qrsAf);

Xr = derivative(Xr);
[z,~,Cond]=yanchibaihua3(Xr',1 ,0);

% ---- Source separation by ICA on residual signals
Ser=FecgICAf(Xr,fs,cName,graph,dbFlag,saveFig);
Ser1=FecgICAf(z',fs,cName,graph,dbFlag,saveFig);

% ----delete same yc----
yc=dis_spike(Ser1',0.5);


peakinterval=0.3*fs;
debug=0;
ann1=ann/1000*fs;


% ----threshold selecting ,clustering----

yc=[Ser yc']';
F=[];
for i=1:size(yc,1)
    [F1,F2,yc(i,:),th]=getspike(yc(i,:),fs,peakinterval,debug,ann1);
    F=[F,F1];
end
[F,CV] = compute_and_sort_cv(F);

% ----generate reference signal,20ms----
win=0.01*fs;
if ~isempty(F)
    refer=zeros(size(F,2),size(Ser,1));
    for i=1:size(F,2)
        if ~isempty(F{i})
            for j=1:size(F{i},2)
                refer(i,max(F{i}(j)-win,1):min(F{i}(j)+win,size(Ser,1)))=1;
            end
        end
        
    end
end

% ----constraint fastICA ----
i=1;
while i<=size(refer,1)
    %         yc(i,:)=fcica3(xw,refer(i,:));
    figure('NumberTitle', 'off', 'Name', '采集的阈值：')
%     set(gcf,'Position',get(0,'ScreenSize'));
    plot(refer(i,:))
    hold on
    plot(ann1,0.9,'k+')
    de=input('Please decide whether it can be a reference for cICA(press "enter" to accept or input "0" to decline it):','s');
    de = str2num(de);
    if de~=1
        fprintf('跳过第%d个Spike\n', i);
        i=i+1;
        continue
    end
    [yt, ~] = cfICA(z, refer(i,:),qrsM,qrsAf,fs,user);
    qrsFcfica=FecgQRSfDet(yt',fs,cName,qrsM,graph,dbFlag,0,saveFigRRf,qrsAf);


    ycmax = max(yt);
    figure;
%     set(gcf,'Position',get(0,'ScreenSize'));
    hold on;
    plot(yt);
    title([num2str(i),'/',num2str(size(yt,1))]);
    plot(ann1,ycmax/2,'r+');
    plot(qrsFcfica*fs,ycmax/2+1,'k+');
%     figResize(0, 1, 1, .35);
    i=i+1;

    [acc,ppv,sen,f1] = evaluation(qrsFcfica*fs/inter,qrsAf,1);
    fprintf('acc:%.4f,ppv:%.4f,sen:%.4f,f1:%.4f\n',acc,ppv,sen,f1);
    if f1 == 100
        break;
    end
close all
end


