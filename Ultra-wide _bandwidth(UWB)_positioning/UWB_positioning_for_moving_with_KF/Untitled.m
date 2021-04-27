% 4����վ

clear;
clc;

global x_act
global y_act
global Vx  % ʵ���ٶ�
global Vy
% ��ȡtxt�ľ�����Ϣ��������C_txt{4}��
% fid = fopen('2020-4-22-4.txt');
fid = fopen('2018-8-31-18-12-56.txt');

temp = fscanf(fid,'%f');           % ��ȡʵ��x����y����������temp
x_act = temp(1); y_act = temp(2);  % ʵ��λ��x0,y0
Vx = temp(3); Vy = temp(4);        % ʵ��λ��x0,y0
C_txt = textscan(fid, '%s %s %s %s %s %f %d');
start = ismember(C_txt{4},'F1');   % 'F1'��Ϊÿ�����ݵĿ�ʼ��־,��Ϊ1��������Ϊ0
start_num = find(start==1);        % ��¼'F1'��λ�ã������еĴ���

fclose(fid);

% ------------------�������λ��---------------------
% LX = B ==> X = inv(L'L) * A'B������A��B
% �ɻ�վ����õ�����A
x_beacon = [0 6 0 6];   % �ֱ��Ӧ������վ�ĺ�����x1,x2,x3
y_beacon = [0 0 3.4 3.4];

L(:,1) = 2*[x_beacon(1)-x_beacon(3) x_beacon(2)-x_beacon(3) x_beacon(4)-x_beacon(3)]';
L(:,2) = 2*[y_beacon(1)-y_beacon(3) y_beacon(2)-y_beacon(3) y_beacon(4)-y_beacon(3)]';
b1 = x_beacon(1)^2 - x_beacon(3)^2 + y_beacon(1)^2 - y_beacon(3)^2;
b2 = x_beacon(2)^2 - x_beacon(3)^2 + y_beacon(2)^2 - y_beacon(3)^2;
b3 = x_beacon(4)^2 - x_beacon(3)^2 + y_beacon(4)^2 - y_beacon(3)^2;
% �ɾ���õ�����B
coordinate = [];
% (length(start_num)-1)Ϊuwb���ݵ�������һ�����ݣ��������룩���Լ���õ�һ��λ�õ�
% i����¼���ܵ������������
void = 0;  % ��¼��Ч��������ĸ���
% for i = 1 : 50
for i = 1 : (length(start_num)-1)
    d = C_txt{6}((start_num(i)+1):(start_num(i+1)-1));
    if (length(d) == 4)    % ȷ�������������ݸ���Ϊ3
        B(1) = b1 + d(3)^2 - d(1)^2;
        B(2) = b2 + d(3)^2 - d(2)^2;
        B(3) = b3 + d(3)^2 - d(4)^2;
        coordinate(:,i-void) = inv(L'*L) * (L'*B');  % ��С���˷�����õ���ǩ��λ��
        % coordinate(:,i-void) = A\B';  % ����õ���ǩ��λ��
        timetable(i-void) =  str2double( C_txt{1}{start_num(i)+2}(2:10) );  % ��¼ÿ���������Ӧ��ʱ��
    else
        void = void + 1;  % ��¼���������С��3�������������
    end
end

% ��άͼ
plot(coordinate(1,:),coordinate(2,:),'*r');  % ԭʼ��λ-��ɫ������KF���-��ɫ
hold on;
plot(coordinate(1,:),coordinate(2,:),'-r');  % ����ͼ��������
plot([x_beacon(1:2) x_beacon(4)  x_beacon(3) x_beacon(1)], [y_beacon(1:2) y_beacon(4)  y_beacon(3) y_beacon(1)], 'b');  % ���ƶ�λ������ɫ
axis([-5 10 -1 5]);
xlabel('x��');
ylabel('y��');
% grid minor;
grid on;
