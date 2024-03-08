function [ route_best,cost_best,time ] = solverVNS( Customer,Cost,depot,Capacity,Demand,param,ls )
%Variable Neighbourhood Search 
tic
if length(Customer)==1
    route_best=depot;
    cost_best=0;
    time=toc;
    return;
end

N=length(Customer);  % number of customers
NC_max=100;
NC=1;
yita=0.0;
s_max=5;

termination=false;
[ route_best,cost_best ] = CVRP_solver( 'greed+2opt',Customer,Cost,depot,Capacity,Demand,param);
[ ~,~,Load ] = CalculateRouteCost( route_best,Cost,Demand,param);
nv=0;
V=zeros(1,length(route_best));   % Vehicle number
for i=1:length(route_best)
    if route_best(i)==depot
        nv=nv+1;
    end
    V(i)=nv;
end
S=cell(1,nv);   % temporary
for i=1:nv
    S{i}=route_best(V==i);
end
while ~termination
   % shaking
   X=cell(s_max,nv);
   L=cost_best*ones(s_max,1);
   Ld=ones(s_max,nv);
   for i=1:s_max
       X(i,:)=S;
       Ld(i,:)=Load;
       % inter-route operation
       if rand<0.5
           counter=0;
           % inter-exchange
           k=unidrnd(nv);
           l=unidrnd(nv);
           while k==l
               if counter>=10
                   break;
               end
               counter=counter+1;
               k=unidrnd(nv);
               l=unidrnd(nv);
           end
           if length(X{i,k})==1||length(X{i,l})==1
               continue;
           end
           sizek=length(X{i,k});
           sizel=length(X{i,l});
           ii=unidrnd(sizek);
           ji=unidrnd(sizel);
           counter=0;
           while Ld(i,k)-Demand(X{i,k}(ii))+Demand(X{i,l}(ji))>Capacity||Ld(i,l)-Demand(X{i,l}(ji))+Demand(X{i,k}(ii))>Capacity||...
                 X{i,k}(ii)==depot||X{i,l}(ji)==depot
               if counter>=10
                   break;
               end
               counter=counter+1;
               ii=unidrnd(sizek);
               ji=unidrnd(sizel);
           end
           if counter>=10
               continue;
           end
           Ld(i,k)=Ld(i,k)-Demand(X{i,k}(ii))+Demand(X{i,l}(ji));
           Ld(i,l)=Ld(i,l)-Demand(X{i,l}(ji))+Demand(X{i,k}(ii));
           L(i)=L(i)-Cost(X{i,k}(circminus(ii,1,sizek)),X{i,k}(ii))-Cost(X{i,k}(ii),X{i,k}(circplus(ii,1,sizek)))...
                    -Cost(X{i,l}(circminus(ji,1,sizel)),X{i,l}(ji))-Cost(X{i,l}(ji),X{i,l}(circplus(ji,1,sizel)));
           ti=X{i,k}(ii);
           X{i,k}(ii)=X{i,l}(ji);
           X{i,l}(ji)=ti;
           L(i)=L(i)+Cost(X{i,k}(circminus(ii,1,sizek)),X{i,k}(ii))+Cost(X{i,k}(ii),X{i,k}(circplus(ii,1,sizek)))...
                    +Cost(X{i,l}(circminus(ji,1,sizel)),X{i,l}(ji))+Cost(X{i,l}(ji),X{i,l}(circplus(ji,1,sizel)));
       else
           % Relocate
           k=unidrnd(nv);   % decide which route to relocate
           counter=0;
           while k==find(Ld(i,:)==min(Ld(i,:)),1)   % the route with least loading is forbidden to relocate
               if counter>=10
                   break;
               end
               counter=counter+1;
               k=unidrnd(nv);
           end
           sizek=length(X{i,k});
           ii=unidrnd(sizek); % decide which cusotmer to relocate
           l=unidrnd(nv);  % decide which route to insert
           counter=0;
           while X{i,k}(ii)==depot||k==l||Ld(i,l)+Demand(X{i,k}(ii))>Capacity  % the route which exceeds capacity is forbidden
               if counter>=10
                   break;
               end
               counter=counter+1;
               ii=unidrnd(sizek); % decide which cusotmer to relocate
               l=unidrnd(nv);   % decide which route to insert 
           end
           if counter>=10
               continue;
           end
           cn=X{i,k}(ii);
           pcn=X{i,k}(circminus(ii,1,sizek));
           scn=X{i,k}(circplus(ii,1,sizek));
           Ld(i,k)=Ld(i,k)-Demand(X{i,k}(ii));
           Ld(i,l)=Ld(i,l)+Demand(X{i,k}(ii));
           L(i)=L(i)-Cost(pcn,cn)-Cost(cn,scn)+Cost(pcn,scn);
           [X{i,l},L(i)]=opInsert(X{i,l},L(i),Cost,cn,'greed');
           % remove node i
           X{i,k}(ii)=[];
           % insert node i to route 
       end 
   end
   % selection roulette
   F=1./L;
   Pr=F;
   Pr=Pr/sum(Pr);
   Prcum=cumsum(Pr);
%    seli=find(Prcum>=rand,1);
   seli=find(L==min(L),1);
   S1=X(seli,:);
   L1=L(seli);
   Ld1=Ld(seli,:);
   % jumping
   rmvC=[];    % removed customer
   for i=1:N
       if rand<yita&&Customer(i)~=depot
           rmvC=[rmvC Customer(i)];
       end
   end
   % remove customer
   for i=1:length(rmvC)
       for j=1:nv
           sel= find(S1{j}==rmvC(i),1);
           if ~isempty(sel)
               sizej=length(S1{j});
               Ld1(j)=Ld1(j)-Demand(S1{j}(sel));
               L1=L1-Cost(S1{j}(circminus(sel,1,sizej)),S1{j}(sel))-Cost(S1{j}(sel),S1{j}(circplus(sel,1,sizej)))...
                    +Cost(S1{j}(circminus(sel,1,sizej)),S1{j}(circplus(sel,1,sizej)));
               S1{j}(sel)=[];
           end
       end
   end
   % insert customer
   while rmvC
       dm=Demand(rmvC);
       ri=find(dm==max(dm),1);
       cn=rmvC(ri);    % customer number
       k=unidrnd(nv);
       while Ld1(k)+Demand(cn)>Capacity
           k=unidrnd(nv);
       end
       Ld1(k)=Ld1(k)+Demand(cn);
       [S1{k},L1]=opInsert(S1{k},L1,Cost,cn,'greed');
%        fprintf('%d %d %f\n',k,cn,L1);
       rmvC(ri)=[];
   end
%    local search
   if strcmp(ls,'2opt')
       for i=1:nv
           [S1{i},L1]=ls2opt(S1{i},L1,Cost);
       end
   elseif strcmp(ls,'3opt')
       for i=1:nv
           [S1{i},L1]=ls2opt(S1{i},L1,Cost);
       end
   end
   if L1<cost_best
       S=S1;
       cost_best=L1;
       Load=Ld1;
   end
   NC=NC+1;
   if NC>=NC_max
       termination=true;
   end
end
route_best=[];
for i=1:nv
    route_best=[route_best circshift(S{i},[0,1-find(S{i}==depot)])];
end
time=toc;
end


