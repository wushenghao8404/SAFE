function [ TC,R ] = NeighborBestEvaluation( A,EM,Cost,Demand,param,nbC,nbA,nbR )
TC=nbC;
R=nbR;
depot=param('depot');
K=param('k');
N=param('n');
Capacity=param('capacity');
sp=param('solver_pool');
neighbor_size=N/10;
if strcmp(sp{EM},'vns+2opt')
    neighbor_size=N/5;
elseif strcmp(sp{EM},'acs+2opt')
    neighbor_size=N/2;
end
if sum(abs(A-nbA))<=neighbor_size % hamming distance metric
    rmvC=[];
    insC=[];
    for i=1:length(A)
        if A(i)==1&&nbA(i)==0
            insC=[insC i];
        elseif A(i)==0&&nbA(i)==1
            rmvC=[rmvC i];
        end
    end
    if ~isempty(find(rmvC==depot, 1))||~isempty(find(insC==depot, 1))
        disp('ILLEGAL OPERATION TO DEPOT');
    end
    rmvC=rmvC(randperm(length(rmvC)));
    insC=insC(randperm(length(insC)));
%     disp(insC);
    % customer removal PF->OC
    for i=1:length(rmvC)
        ii=find(R==rmvC(i),1);
        ip=circminus(ii,1,length(R));
        in=circplus(ii,1,length(R));
        TC=TC-Cost(R(ip),R(ii))-Cost(R(ii),R(in))+Cost(R(ip),R(in))+param('compensation_ratio')*Cost(depot,R(ii));
        R(ii)=[];
    end
    % calculate load
    R=circshift(R,[0 1-find(R==depot,1)]);
    di=find(R==depot);
    if length(di)>K
        K=length(di);
    elseif length(di)<K
        R=[R depot*ones(1,K-length(di))];
    end
    di=find(R==depot);
    L=zeros(1,K);
    for i=1:K-1
        L(i)=sum(Demand(R(di(i):di(i+1)-1)));
    end
    L(K)=sum(Demand(R(di(end):end)));
    eval=true;
    % customer insertion OC->PF
    for i=1:length(insC)
        veh=0;
        deltaCost=1e25;
        insveh=-1;
        inspos=-1;
        for ii=1:length(R)
            if R(ii)==depot
                veh=min(veh+1,K);
            end
            if Demand(insC(i))+L(veh)<Capacity
                in=circplus(ii,1,length(R));
                tDelta=Cost(R(ii),insC(i))+Cost(insC(i),R(in))-Cost(R(ii),R(in))-param('compensation_ratio')*Cost(depot,insC(i));
                if tDelta<deltaCost
                    deltaCost=tDelta;
                    inspos=ii;
                    insveh=veh;
                end
            end
        end
        if inspos==-1
            eval=false;
            break;
        else
            L(insveh)=L(insveh)+Demand(insC(i));
            R=[R(1:inspos) insC(i) R(inspos+1:end)];
            TC=TC+deltaCost;
        end
    end
    % 2opt
    R=circshift(R,[0 1-find(R==depot,1)]);
    di=find(R==depot);
    for i=1:K-1
        [ best_r,TC ] = ls2opt( R(di(i):di(i+1)-1),TC,Cost );
        best_r=circshift(best_r,[0 1-find(best_r==depot,1)]);
        R(di(i):di(i+1)-1)=best_r;
    end
    [ best_r,TC ] = ls2opt( R(di(K):end),TC,Cost );
    best_r=circshift(best_r,[0 1-find(best_r==depot,1)]);
    R(di(K):end)=best_r;
    if ~eval
        sp=param('solver_pool');
        [TC,R]=BasicEvaluation( sp{EM},A,Cost,Demand,param);
    end
else
    sp=param('solver_pool');
    [TC,R]=BasicEvaluation( sp{EM},A,Cost,Demand,param);
end
end

