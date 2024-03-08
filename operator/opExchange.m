function [ rS,rL ] = opExchange( S,L,Cost,Demand,param )
rL=L;
rS=S;
depot=param('depot');
capacity=param('capacity');
di=find(S==depot);
K=length(di);
i=unidrnd(K);
j=unidrnd(K);
while i==j
    i=unidrnd(K);
    j=unidrnd(K);
end
ri=[];
rj=[];
if i==K
    ri=S(di(i):end);
    rj=S(di(j):di(j+1)-1);
elseif j==K
    rj=S(di(j):end);
    ri=S(di(i):di(i+1)-1);
end
leni=length(ri);
lenj=length(rj);
improved=true;
while improved
    improved=false;
    for ii=1:leni
        if improved
            break;
        end
        for ji=1:lenj
            if improved
                break;
            end
            delta=-Cost(ri(ii),ri(circplus(ii,1,leni)))-Cost(rj(ji),rj(circplus(ji,1,lenj)))...
                  +Cost(ri(ii),rj(circplus(ji,1,lenj)))+Cost(rj(ji),ri(circplus(ii,1,leni)));
             if delta<-0.001
                 tr=ri(circplus(ii,1,leni):end);
                 tri=[ri(1:ii) rj(circplus(ji,1,lenj):end)];
                 trj=[rj(1:ji) tr];
                 loadi=0;
                 loadj=0;
                 for ki=1:length(ri)
                     loadi=loadi+Demand(ri(ki));
                 end
                 for ki=1:length(rj)
                     loadj=loadj+Demand(rj(ki));
                 end
                 if loadi>capacity||loadj>capacity
                     continue;
                 else
                     ri=tri;
                     rj=trj;
                     L=L+delta;
                     improved=true;
                 end
             end
        end
    end
end
ri=circshift(ri,1-find(ri==depot,1));
rj=circshift(rj,1-find(rj==depot,1));
if i==K
    rS=[S(1:di(j)-1) rj S(di(j+1):di(i)-1) ri];
elseif j==K
    rS=[S(1:di(i)-1) ri S(di(i+1):di(j)-1) rj];
elseif i<j
    rS=[S(1:di(i)-1) ri S(di(i+1):di(j)-1) rj S(di(j+1):end)];
elseif i>j
    rS=[S(1:di(j)-1) rj S(di(j+1):di(i)-1) ri S(di(i+1):end)];
end
end
