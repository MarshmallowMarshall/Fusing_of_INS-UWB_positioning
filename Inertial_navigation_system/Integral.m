function [ intofarray ] = Integral( array )
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   ������array�Ļ���

[row, colume] = size( array );
for i = 1:row
    intofarray(i,1) = array(i,1);
    for j = 2 : colume
        intofarray(i,j) = intofarray(i,j-1) + array(i,j);
    end
    figure;
    plot(0.005*intofarray(i,:));
    grid on
end

end

