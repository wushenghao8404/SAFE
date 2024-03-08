function [ ArA,ArF,ArR ] = ArchiveReduction( ArA,ArF,ArR,Arsize )
len=size(ArA,1);
F=zeros(1,len);
for i=1:len
    F(i)=max(ArF(i,:));
end
[~,index]=sort(F);
ArA(index(1:len-Arsize),:)=[];
ArF(index(1:len-Arsize),:)=[];
ArR(index(1:len-Arsize),:)=[];
end
