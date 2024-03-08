function [ best_r,best_l ] = ls3opt( R,L,D )
% ls3opt local search algorithm 3-opt for a given route for a symetric tsp
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
            for k=j:n-1
                delta=-D(cur_r(j),cur_r(j+1))-D(cur_r(k),cur_r(k+1))-D(cur_r(end),cur_r(1))...
                      +D(cur_r(j),cur_r(k+1))+D(cur_r(end),cur_r(k))+D(cur_r(j+1),cur_r(1));
                if delta<-0.001;
                    cur_r=[cur_r(1:j) cur_r(k+1:end) cur_r(k:-1:j+1)];
                    best_l=best_l+delta;
                    best_r=cur_r;
                    improved=true;
                end
            end
        end
    end
    gen=gen+1;
end
end

