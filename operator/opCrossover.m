function [ rA,rB ] = opCrossover( cs,A,B,CR,param )
% crossover
%   cs -- crossover scheme
%   PMX -- partial-mapped crossover
%   mpx -- multi-point crossover
%   spx -- single-point crossover
%   tpx -- two-point crossover
%   ux  -- uniform crossover
rA=A;
rB=B;
depot=param('depot');
if strcmp(cs,'pmx')
    if rand<CR
        L=length(A);
        c1=unidrnd(L);
        c2=unidrnd(L);
        while c1==c2
            c2=unidrnd(L);
        end
        i1=min(c1,c2);
        i2=max(c1,c2);
        segA=A(1,i1:i2);
        segB=B(1,i1:i2);
        A(1,i1:i2)=segB;
        B(1,i1:i2)=segA;
        restA=[A(1,1:i1-1) A(1,i2+1:L)];
        restB=[B(1,1:i1-1) B(1,i2+1:L)];
        conflict_gene=intersect(restA,A(1,i1:i2));
        while conflict_gene
            ia=find(restA==conflict_gene(1));
            sel_rep=find(A(1,i1:i2)==conflict_gene(1));
            seg=B(1,i1:i2);
            restA(ia)=seg(sel_rep);
            conflict_gene=intersect(restA,A(1,i1:i2));
        end
        conflict_gene=intersect(restB,B(1,i1:i2));
        while conflict_gene
            ia=find(restB==conflict_gene(1));
            sel_rep=find(B(1,i1:i2)==conflict_gene(1));
            seg=A(1,i1:i2);
            restB(ia)=seg(sel_rep);
            conflict_gene=intersect(restB,B(1,i1:i2));
        end
        A(1,:)=[restA(1:i1-1) A(1,i1:i2) restA(i1:end)];
        B(1,:)=[restB(1:i1-1) B(1,i1:i2) restB(i1:end)];
    end
    rA=A;
    rB=B;
elseif strcmp(cs,'mpx')
    if rand<CR
        L=length(A);
        c1=unidrnd(L);
        c2=unidrnd(L);
        while c1==c2||c1==depot||c2==depot
            c1=unidrnd(L);
            c2=unidrnd(L);
        end
        i1=min(c1,c2);
        i2=max(c1,c2);
        rA=A;
        rB=B;
        segA=rA(1,i1:i2);
        rA(1,i1:i2)=rB(1,i1:i2);
        rB(1,i1:i2)=segA;
    end
elseif strcmp(cs,'ux')
    L=length(A);
    for i=1:L
        if rand>CR
            t=rA(i);
            rA(i)=rB(i);
            rB(i)=t;
        end
    end
end
end

