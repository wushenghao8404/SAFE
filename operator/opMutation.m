function [ rA ] = opMutation( ms,A,pm,param )
% mutation
%   ms -- mutation scheme
%   ex -- exchange position
%   bin -- binary mutation
%   spm -- single point mutation
%   mpm -- multi-point mutation
rA=A;
L=size(A,2);
n=param('n');
k=param('k');
depot=param('depot');
if rand<pm
    if strcmp(ms,'ex')
        depot=[depot n+1:n+k-1];
        done=false;
        while ~done
            c1=unidrnd(L);
            c2=unidrnd(L);
            while c1==c2
                c2=unidrnd(L);
            end
            c1p=circminus(c1,1,L);
            c1n=circplus(c1,1,L);
            c2p=circminus(c2,1,L);
            c2n=circplus(c2,1,L);
            if find(depot==A(1,c1))
                if find(depot==A(1,c2p))
                    continue;
                end
                if find(depot==A(1,c2n))
                    continue;
                end
            end
            if find(depot==A(1,c2))
                if find(depot==A(1,c1p))
                    continue;
                end
                if find(depot==A(1,c1n))
                    continue;
                end
            end
            t=A(1,c1);
            A(1,c1)=A(1,c2);
            A(1,c2)=t;
            rA=A;
            done=true;
        end
    elseif strcmp(ms,'spm')
        c1=unidrnd(L);
        while c1==depot
            c1=unidrnd(L);
        end
        rA(c1)=1-rA(c1);
    end
end
end

