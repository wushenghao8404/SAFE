function [ route_best,cost_best,time ] = solverACS( Customer,Cost,depot,Capacity,Demand,param,ls)
tic
if length(Customer)==1
    route_best=depot;
    cost_best=0;
    time=toc;
    return;
end
N=length(Customer);  % number of total customer
NAnts=10;
Alpha=1;
Beta=3;
Gamma=2;
Rho=0.15;
q0=0.9;
% Tau_max=0.1;
% Tau_min=0.1;
termination=false;
NC_max=100;
NC=1;
stag=0;
Stag_max=10;
Tau=ones(N);
Eta=ones(N);
Theta=ones(N);
% initialization
[ route_best,cost_best ] = CVRP_solver( 'greed+2opt',Customer,Cost,depot,Capacity,Demand,param);
Tau0=1/(N*cost_best);
Tau=Tau*Tau0;
% Tau_max=Tau0;
% Tau_min=Tau_max*(1-0.05^(1/n))/((n/2-1)*0.05^(1/n));
for i=1:N
    for j=1:N
        Eta(i,j)=1/Cost(Customer(i),Customer(j));
        if Customer(i)==depot||Customer(j)==depot
            Theta(i,j)=eps;
        else
            Theta(i,j)=Cost(Customer(i),depot)+Cost(depot,Customer(j))-Cost(Customer(i),Customer(j));
        end
    end
end
di=find(Customer==depot,1);
while ~termination
%     disp(NC);
    stag=stag+1;
    flag=false(NAnts,1);
    T=zeros(NAnts,N);      % corresponding to each city's occupation
    curi=di*ones(NAnts,1);
    L=zeros(NAnts,1);
    ii=ones(NAnts,1);      % index of vehicle
    ji=ones(NAnts,1);      % customer index in the vehicle ii's route,number of vehicles used
    for k=1:NAnts
        T(k,di)=1;
    end
    flagret=false(NAnts,1);        % determing if an ant return to depot
    cap=Capacity*ones(NAnts,1);
    count=0;
    while true
        count=count+1;
        for k=1:NAnts
            if isempty(find(T(k,:)==0, 1))
                flag(k)=true;
            elseif flagret(k)
                cap(k)=Capacity;
                flagret(k)=false;
            else
                Ac=Customer(and(T(k,:)==0,Demand(Customer)<cap(k)));   % accessible customer
                if length(Customer)>50
                    [~,ai]=sort(Cost(Customer(curi(k)),Ac));
                    neighbor_size=ceil(length(Ac)*0.1);
                    ai=ai(1:neighbor_size);
                    Ac=Ac(ai);
                end
                iAc=[];
                for i=1:length(Ac)
                    iAc=[iAc find(Customer==Ac(i),1)];
                end
                Pr=(Tau(curi(k),iAc).^Alpha).*(Eta(curi(k),iAc).^Beta).*(Theta(curi(k),iAc).^Gamma);
%                 Pr=(Tau(curi(k),iAc).^Alpha).*(Eta(curi(k),iAc).^Beta);
                Pr=Pr/sum(Pr);
                Prcum=cumsum(Pr);
                seli=find(Prcum>rand,1);
                if rand<q0
                    seli=find(Pr==max(Pr),1);
                end
%                 if count==1
%                     seli=unidrnd(length(iAc));
%                 end
%               fprintf('%d %d\n',curpos(k),Customer(seli));
                L(k)=L(k)+Cost(Customer(curi(k)),Customer(iAc(seli)));
                curi(k)=iAc(seli);   % move
                if curi(k)==di
                    flagret(k)=true;
                    T(k,di)=1;
                    ii(k)=ii(k)+1;
                    ji(k)=1;
                else
                    T(k,curi(k))=(ii(k)-1)*N+ji(k);
                    ji(k)=ji(k)+1;
                    T(k,di)=0;
                    cap(k)=cap(k)-Demand(Customer(curi(k)));
                end
            end
        end
        if flag
            break;
        end
    end
    % colony of solutions have been constructed
    % pheromone evaporation
%     Tau=(1-Rho)*Tau;
    % end solution construction loop
    ii=ii-1;
     % update global best
    for k=1:NAnts
        rt=zeros(ii(k),N);     % route table
        for i=1:N
            if Customer(i)==depot
                continue;
            end
            vi=floor(T(k,i)/N)+1;   % vehicle index
            si=mod(T(k,i),N);       % sequence index within a vehicle's route
            rt(vi,si)=i;
        end
        S=[];
        for i=1:ii(k)
            sr=[depot Customer(rt(i,rt(i,:)~=0))];
            if strcmp(ls,'2opt')
                [ sr,L(k) ] = ls2opt( sr,L(k),Cost );
            elseif strcmp(ls,'3opt')
                [ sr,L(k) ] = ls3opt( sr,L(k),Cost );
            end
            sr=circshift(sr,[0 1-find(sr==depot,1)]);
            S=[S sr];
        end
        if L(k)<cost_best
            stag=0;
            cost_best=L(k);
            route_best=S;
        end
        % local pheromone update
        innerS=ones(1,length(S));
        for i=1:length(innerS)
            innerS(i)=find(Customer==S(i));
        end
        for i=1:length(innerS)
            in=circplus(i,1,length(innerS));
%                 Tau(S(i),S(in))=Tau(S(i),S(in))+1/L;
            Tau(innerS(i),innerS(in))=(1-Rho)*Tau(innerS(i),innerS(in))+Rho*Tau0;
            Tau(innerS(in),innerS(i))=Tau(innerS(i),innerS(in));    % symetric update
        end
    end
    innerSgb=ones(1,length(route_best));
    for i=1:length(innerSgb)
        innerSgb(i)=find(Customer==route_best(i));
    end
    for i=1:length(innerSgb)
        in=circplus(i,1,length(innerSgb));
        Tau(innerSgb(i),innerSgb(in))=(1-Rho)*Tau(innerSgb(i),innerSgb(in))+Rho/cost_best;
        Tau(innerSgb(in),innerSgb(i))=Tau(innerSgb(i),innerSgb(in));  % symetric update
    end
%     Tau(Tau<Tau_min)=Tau_min;
%     Tau(Tau>Tau_max)=Tau_max;
    if stag>=Stag_max||NC>=NC_max
        termination=true;
    end
    NC=NC+1;
%      disp(Lgb);
end
time=toc;
end