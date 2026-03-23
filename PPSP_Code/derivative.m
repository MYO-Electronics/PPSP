function [decgr] = derivative(ecg)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
% raw derivative filter coefficients
% 5ms before and after, 3ms in the middle
fs=1000;
nu=ceil(0.005 * fs); nz=floor(0.0030*fs /2)*2 +1;  % nz=nearest odd value
B=[ones(nu,1);zeros(nz,1);-ones(nu,1)];
delay=floor(length(B)/2);

% ---   compute the derivative signal差分滤波器
ecgfx=[repmat(ecg(1,:),delay,1);ecg;repmat(ecg(end,:),delay,1)];
decgr=filtfilt(B,1,ecg);



end

