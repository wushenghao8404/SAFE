function [ Route,CostPF,time ] = solverGreedy(Customer,Cost,depot,Capacity,Demand,param,ls )
tic
if length(Customer)==1
    Route=depot;
    CostPF=0;
    time=toc;
    Load=[];
    return
end
N=length(Customer);        % number of customers
innerRoute=[];
Route=[];
CostPF=0;
di=find(Customer==depot);  % depot's index in Ac
Ac=ones(1,N);
start=unidrnd(N);          % the customer id for as depot
while start==di
    start=unidrnd(N);      % avoid duplicate
end
Ac([di start])=0;          % in Ac the customer of curpos and di has been served

% nearest neighbor heuristic
cap=Capacity-Demand(Customer(start));
innerRoute=[innerRoute di start];
Ai=find(Ac==1);
while Ai
    seli=-1;
    minc=1e25;
    count=0;
    for j=1:length(Ai)
        count=count+1;
        if count>1000
            error('DEADLOCK DETECTED');
        end
        if (cap>Demand(Customer(Ai(j))))&&(Cost(Customer(innerRoute(end)),Customer(Ai(j)))<minc)
            seli=j;
            minc=Cost(Customer(innerRoute(end)),Customer(Ai(j)));
        end
    end
    if seli==-1
        cap=Capacity;
        innerRoute=[innerRoute di];  % back to the depot, use another vehicle
    else
        cap=cap-Demand(Customer(Ai(seli)));
        innerRoute=[innerRoute Ai(seli)];
        Ac(Ai(seli))=0;
    end
    Ai=find(Ac==1);   % Ai,Accessible index
end
Route=innerRoute;
for i=1:length(innerRoute)
    Route(i)=Customer(innerRoute(i));
end
[ fit,feasible,Load ] = CalculateRouteCost(Route,Cost,Demand,param);
if feasible
    CostPF=fit;
    if strcmp(ls,'2opt')
        dp=find(Route==depot);
        for i=1:length(dp)-1
            [Subroute,CostPF]=ls2opt(Route(dp(i):dp(i+1)-1),CostPF,Cost );
            di=find(Subroute==depot);
            Route(dp(i):dp(i+1)-1)=circshift(Subroute,[0,1-di]);
        end
        [Subroute,CostPF]=ls2opt(Route([dp(end):end 1:dp(1)-1]),CostPF,Cost );
        di=find(Subroute==depot);
        Route([dp(end):end 1:dp(1)-1])=circshift(Subroute,[0,1-di]);
    elseif strcmp(ls,'3opt')
        dp=find(Route==depot);
        for i=1:length(dp)-1
            [Subroute,CostPF]=ls3opt(Route(dp(i):dp(i+1)-1),CostPF,Cost );
            di=find(Subroute==depot);
            Route(dp(i):dp(i+1)-1)=circshift(Subroute,[0,1-di]);
        end
        [Subroute,CostPF]=ls3opt(Route([dp(end):end 1:dp(1)-1]),CostPF,Cost );
        di=find(Subroute==depot);
        Route([dp(end):end 1:dp(1)-1])=circshift(Subroute,[0,1-di]);
    end
else
    error('INFEASIBLE SOLUTION');
end
time=toc;
end

