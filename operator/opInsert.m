function [ rb,lb ] = opInsert( R,L,D,ci,scheme )
nc=length(R); %number of cities in route R
rb=R;
if strcmp(scheme,'greed')
    min_ins_cost=1e25;
    for i=1:nc
        in=circplus(i,1,nc);
        ins_cost=D(R(i),ci)+D(ci,R(in))-D(R(i),R(in));
        if ins_cost<min_ins_cost
            min_ins_cost=ins_cost;
            rb=[R(1:i) ci R(i+1:end)];
        end
    end
    lb=L+min_ins_cost;
end
end