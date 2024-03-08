function [ rC,rR,feasible ] = opInMove( ci,R,TC,Cost,Demand,param )
rC=TC;
rR=[];
feasible=true;
rr=param('compensation_ratio');
Capacity=param('capacity');
depot=param('depot');
K=length(find(R==depot));
subR=cell(1,K);
Load=0;
R=circshift(R,[0,1-find(R==depot,1)]);
for i=1:K
    subR{i}=depot;
end
k=1;
for i=2:length(R)
    if R(i)==depot
        Load=[Load 0];
        k=k+1;
    else
        subR{k}=[subR{k} R(i)];
        Load(end)=Load(end)+Demand(R(i));
    end
end
ins_cost=1e25;
ins_k=-1;
ins_i=-1;
for i=1:K
    if Load(i)+Demand(ci)<=Capacity
        for j=1:length(subR{i})
            jn=circplus(j,1,length(subR{i}));
            delta=-rr*Cost(depot,ci)-Cost(subR{i}(j),subR{i}(jn))+Cost(subR{i}(j),ci)+Cost(ci,subR{i}(jn));
            if delta<ins_cost
                ins_k=i;
                ins_i=j;
                ins_cost=delta;
            end
        end
    end
end
if ins_k==-1
    feasible=false;
    return;
else
    subR{ins_k}=[subR{ins_k}(1:ins_i) ci subR{ins_k}(ins_i:end)];
    for i=1:K
        rR=[rR subR{k}];
    end
    rC=TC+ins_cost;
end
    