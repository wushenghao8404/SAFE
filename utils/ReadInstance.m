function [Cost,depot,Capacity,Demand,Location,NearestCustomerIds] = ReadInstance(filename)
fid = fopen(filename,'rt');
Demand=[];
weight_type=[];
weight_format=[];
Location=[];
depot=[];
Cost=[];
row=[];
col=[];
state='NONE';
tline = fgetl(fid);
n=0;
while ischar(tline)
    if strcmp(tline,'EOF')||strcmp(tline,'-1')
        break;
    end
    if length(tline)>=12&&strcmp(tline(1:12),'DIMENSION : ')
        dimension=tline(13:end);
        
        n=str2num(tline(13:end));
        Cost=ones(n);
    end
    if length(tline)>=16&&strcmp(tline(1:16),'EDGE_WEIGHT_TYPE')
        weight_type=tline(17:end);
        weight_type(or(weight_type==' ',weight_type==':'))=[];
    end
    if length(tline)>=18&&strcmp(tline(1:18),'EDGE_WEIGHT_FORMAT')
        weight_format=tline(19:end);
        weight_format(or(weight_format==' ',weight_format==':'))=[];
        if strcmp(weight_format,'LOWER_ROW')
            row=2;
            col=1;
        elseif strcmp(weight_format,'UPPER_ROW')
            row=1;
            col=2;
        end
    end
    if length(tline)>=11&&strcmp(tline(1:11),'CAPACITY : ')
        Capacity=str2num(tline(12:end));
    end
    if length(tline)>=19&&strcmp(tline(1:19),'EDGE_WEIGHT_SECTION')
        state='EDGE_WEIGHT_SECTION';
        tline = fgetl(fid); 
    end
    if length(tline)>=18&&strcmp(tline(1:18),'NODE_COORD_SECTION')
        Location=zeros(n,2);
        state='NODE_COORD_SECTION';
        tline = fgetl(fid); 
        continue;
    end
    if length(tline)>=14&&strcmp(tline(1:14),'DEMAND_SECTION')
        Demand=zeros(1,n);
        state='DEMAND_SECTION';
        tline = fgetl(fid); 
        continue;
    end
    if length(tline)>=13&&strcmp(tline(1:13),'DEPOT_SECTION')
        state='DEPOT_SECTION';
        tline = fgetl(fid); 
        continue;
    end
    if strcmp(state,'EDGE_WEIGHT_SECTION')&&strcmp(weight_type,'EXPLICIT')
        buff=strsplit(tline);
        deli=[];
        for i=1:length(buff)
            if strcmp(buff{i},'')
                deli=[deli i];
            end
        end
        buff(deli)=[];
        if strcmp(weight_format,'LOWER_ROW')
            for i=1:length(buff)
%                 fprintf('%d %d\n',row,col);
                Cost(row,col)=str2num(buff{i});
                Cost(col,row)=Cost(row,col);
                col=col+1;
                if row==col
                    row=row+1;
                    col=1;
                end
            end
        elseif strcmp(weight_format,'UPPER_ROW')
            for i=1:length(buff)
                Cost(row,col)=str2num(buff{i});
                Cost(col,row)=Cost(row,col);
                col=col+1;
                if col>n
                    row=row+1;
                    col=row+1;
                end
            end
        end
    end
    if strcmp(state,'NODE_COORD_SECTION')
        buff=strsplit(tline);
        deli=[];
        for i=1:length(buff)
            if strcmp(buff{i},'')
                deli=[deli i];
            end
        end
        buff(deli)=[];
        ci=str2num(buff{1});
        x=str2num(buff{2});
        y=str2num(buff{3});
        Location(ci,:)=[x y];
    end
    if strcmp(state,'DEMAND_SECTION')
        buff=strsplit(tline);
        deli=[];
        for i=1:length(buff)
            if strcmp(buff{i},'')
                deli=[deli i];
            end
        end
        buff(deli)=[];
        customer=str2num(buff{1});
        Demand(customer)=str2num(buff{2});
    end
    if strcmp(state,'DEPOT_SECTION')
        buff=strsplit(tline);
        deli=[];
        for i=1:length(buff)
            if strcmp(buff{i},'')
                deli=[deli i];
            end
        end
        buff(deli)=[];
        depot=str2num(buff{1});
        state='NONE';
        break
    end
    tline = fgetl(fid); 
end
% parameter initialization
for i=1:n
    for j=1:n
        if i==j
            Cost(i,j)=eps;
        end
    end
end
NearestCustomerIds=ones(n);
if ~strcmp(weight_type,'EXPLICIT')
    for i=1:n
        for j=1:n
            if i==j
                Cost(i,j)=eps;
            else
                Cost(i,j)=CalculateEdgeWeight(weight_type,Location(i,:),Location(j,:));
                if Cost(i,j)<eps
                    Cost(i,j)=eps;
                end
            end
        end
    end
end
for i=1:n
    [~,NearestCustomerIds(i,:)]=sort(Cost(i,:));
end
fclose(fid);
end