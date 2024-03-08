function [ r ] = circminus( a,b,c )
r=mod(a+c-b-1,c)+1;
end

