function [ ArA,ArF,ArR ] = ArchiveInsertion( A,F,R,ArA,ArF,ArR,param)
N=param('n');
nbi=[];
for j=1:size(ArA,1)
    if sum(abs(A-ArA(j,:)))<N/10
        nbi=[nbi j];
    end
end
if isempty(nbi)
    ArA=[ArA;A];
    ArF=[ArF;F];
    ArR=[ArR;R];
else
    if F>max(ArF(nbi))
        ArA(nbi,:)=[];
        ArF(nbi,:)=[];
        ArR(nbi)=[];
        ArA=[ArA;A];
        ArF=[ArF;F];
        ArR=[ArR;R];
    end
end
end