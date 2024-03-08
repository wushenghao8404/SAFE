function [ best_r,best_l ] = ls2opt( R,L,D )
% LS_2_opt local search algorithm 2-opt for a given route for a symetric tsp
n=length(R);
if ~find(size(R)==1)
    error('ERROR');
end
offset=ones(1,2);
offset(size(R)==1)=0;
improved=true;
best_r=R;
best_l=L;
gen=1;
while improved
    improved=false;
    cur_r=best_r;
    cur_l=best_l;
    for i=1:n
        if improved
            break;
        end
        cur_r=circshift(cur_r,offset);
        for j=1:n-1
            if improved
                break;
            end
            delta=-D(cur_r(end),cur_r(1))-D(cur_r(j),cur_r(j+1))+D(cur_r(end),cur_r(j))+D(cur_r(1),cur_r(j+1));
            if delta<-1e-12
                cur_r(1:j)=cur_r(j:-1:1);
                best_l=best_l+delta;
                best_r=cur_r;
                improved=true;
            end
        end
    end
    gen=gen+1;
end
end

