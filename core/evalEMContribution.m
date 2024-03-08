function [ conf,P,F,R ] = evalEMContribution( metric,pA,pF,ArA,ArF,ArR,Cost,Demand,es,param )
conf=0;
tc1=1./pF;
tc2=tc1;
tmpR=cell(param('pop_size'),1);
for i=1:param('pop_size')
    nbi=-1;
    mind=1e25;
    for j=1:size(ArA,1)
        td=sum(abs(pA(i,:)-ArA(j,:)));
        if td<mind
            mind=td;
            nbi=j;
        end
    end
    nbA=ArA(nbi,:);
    nbC=1/ArF(nbi,1);
    nbR=ArR{nbi};
    [tc2(i),tmpR{i}]=NeighborBestEvaluation( pA(i,:),es,Cost,Demand,param,nbC,nbA,nbR );
end
P=pA;
F=1./tc2;
R=tmpR;
if strcmp(metric,'alignment')
    ncomb=0;
    for i=1:param('pop_size')
        for j=i+1:param('pop_size')
            ncomb=ncomb+1;
            if (tc1(i)-tc1(j))*(tc2(i)-tc2(j))>=0
                conf=conf+1;
            end
        end
    end
    conf=conf/ncomb;
elseif strcmp(metric,'best-improvement')
    conf=max(F)-max(pF);
end
end

