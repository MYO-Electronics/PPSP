function [S]=dis_spike(y,p,fs,graph)
        if isempty(p)
            p=0.4;
        end
        if nargin<3
            fs=1000;
        end
        if nargin<4
            graph=1;
        end
        S=[];
        win=fs/200;
        while ~ isempty(y) %isempty判断输入是否为空
            S=[S;y(1,:)];
            Co=zeros(size(y,1),1);
            for j=1:size(y,1)
                temp1=max(xcorr(y(1,2*win+1:end-2*win),y(j,2*win+1:end-2*win),'coeff')); %xcorr，是指互相关函数
                temp2=max(xcorr(y(1,2*win+1:end-2*win),-y(j,2*win+1:end-2*win),'coeff'));
                Co(j)=max(temp1,temp2);
            end
            y(Co>=p,:)=[];
        end
        
        if graph
            multiPlot('shaixuanguohoudey',S);
        end
        
    end
