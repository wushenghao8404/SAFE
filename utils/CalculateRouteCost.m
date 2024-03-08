function [ route_cost,feasible,Load ] = CalculateRouteCost( Route,Cost,Demand,param)
%   Route --route vector
route_cost=0;
feasible=true;
depot=param('depot');
Capacity=param('capacity');
N=param('n');
Load=[];
Route(Route>N)=depot;  % truncation
pc=1000;       % penalty coefficient
cap=Capacity;
len=length(Route);
dpos=find(Route==depot,1);
Route=circshift(Route,[0,1-dpos]);
for i=1:len
%         fprintf('%d %d %d\n',S(curpos),depot,n);
    if Route(i)==depot||Route(i)>N
        if cap<0
            feasible=false;
            route_cost=route_cost-cap*pc;
        end
        Load=[Load Capacity-cap];
        cap=Capacity;
    end
    in=circplus(i,1,len);
    route_cost=route_cost+Cost(Route(i),Route(in));
    cap=cap-Demand(Route(i));
end
Load=[Load Capacity-cap];
Load(1)=[];
end

