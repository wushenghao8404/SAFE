function [ rC,rR,feasible ] = opOutMove( ci,R,TC,Cost,Demand,param )
rR=R;
feasible=true;
rr=param('compensation_ratio');
depot=param('depot');
i=find(R==ci);
in=circplus(i,1,length(R));
ip=circminus(i,1,length(R));
rC=TC-Cost(R(ip),R(i))-Cost(R(i),R(in))+Cost(R(ip),R(in))+rr*Cost(depot,R(i));
rR(i)=[];
end

