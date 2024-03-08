function [ w ] = CalculateEdgeWeight( scheme,A,B )
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
if strcmp('EUC_2D',scheme)
    w=sqrt(sum((A-B).^2));
elseif strcmp('GEO',scheme)
    EARTH_RADIUS=6378.137;
    RAD=pi/180;
    w=distance(A,B)*EARTH_RADIUS*RAD;
%     EARTH_RADIUS=6378.137;
%     radLat1 = A(2) * RAD;
%     radLat2 = B(2) * RAD;
%     a = radLat1 - radLat2;
%     b = (A(1) - B(1)) * RAD;
%     w=2*asin(sqrt((sin(a/2))^2))+cos(radLat1)*cos(radLat2)*(sin(b / 2))^ 2;
%     w=w*EARTH_RADIUS;
%     w=round(w*1000)/1000;
end