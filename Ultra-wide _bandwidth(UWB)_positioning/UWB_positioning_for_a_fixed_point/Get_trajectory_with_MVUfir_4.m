% 4����վ

clear;
clc;

global x_act
global y_act
global Vx  % ʵ���ٶ�
global Vy
% ��ȡtxt�ľ�����Ϣ��������C_txt{4}��
fid = fopen('2018-8-31-18-16-48.txt');

temp = fscanf(fid,'%f');  % ��ȡʵ��x����y����������temp
x_act = temp(1); y_act = temp(2);  % ʵ��λ��x0,y0
Vx = temp(3); Vy = temp(4);  % ʵ��λ��x0,y0
eq_tr = temp(5);  % ��վ���ȱ������Σ��ı߳�
C_txt = textscan(fid, '%s %s %s %s %s %f %d');
start = ismember(C_txt{4},'F1');  % 'F1'��Ϊÿ�����ݵĿ�ʼ��־,��Ϊ1��������Ϊ0
start_num = find(start==1);  % ��¼'F1'��λ�ã������еĴ���

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

% ------------------�˲�-------------------
g_t = 0.7;  % ʱ����
% Vx = 0;
% Vy = 0.135  ; % 0.14

Y = coordinate;  % YΪ�۲�ֵ,x��y��������ֵ
X(1,1) = Y(1,1);  % ��ʼ��״ֵ̬��X0����������������
X(2,1) = Vx;
X(3,1) = Y(2,1);
X(4,1) = Vy;
sum_error = 0;  % �������
sum_error_with_kf = 0;

n = 8;% n�ǳ���������horizon
Kn = Get_Kn(n);  % �õ�Kn

Ykl = Y(:,1)';
for k = 2:n
    Ykl = [Y(:,k)' Ykl];
    X(1,k) = Y(1,k);  % ��ʼ��״ֵ̬��X0����������������
    X(3,k) = Y(2,k);
    X(2,k) = Vx;
    X(4,k) = Vy;
    sum_error = sum_error + (Y(1,k) - x_act)^2 * (Vx == 0) + (Y(2,k) - y_act)^2 * (Vy == 0);
end

for k = (n+1):(i-void)
% for k = 2:(i-j)
    Ykl = [Y(:,k)' Ykl(:,1:2*n-2)];
    X(:,k) = Kn * Ykl';
    sum_error = sum_error + (Y(1,k) - x_act)^2 * (Vx == 0) + (Y(2,k) - y_act)^2 * (Vy == 0);
%     if k >= 10
        sum_error_with_kf = sum_error_with_kf + (X(1,k) - x_act)^2 * (Vx == 0) + (X(3,k) - y_act)^2 * (Vy == 0);
%     end
end
% ������������
rmse = (sum_error / (i - void))^0.5;
rmse_kf = (sum_error_with_kf / (i - void - n))^0.5;
rmse
rmse_kf
str_rmse = num2str(rmse);
str_rmse_kf = num2str(rmse_kf);

% --------------------��ͼ---------------------
% ��άͼ
plot(Y(1,:),Y(2,:),'ob',X(1,:),X(3,:),'*r');  % ԭʼ��λ-��ɫ������KF���-��ɫ
hold on;
plot(Y(1,:),Y(2,:),'b',X(1,:),X(3,:),'r');  % ����ͼ��������
plot([x_beacon x_beacon(1)], [y_beacon,y_beacon(1)], 'b');  % ���ƶ�λ������ɫ
axis([-2 12 -1 12]);
xlabel('x��');
ylabel('y��');
% grid minor;
grid on;
text(Y(1,1),Y(2,1),' s');  % ��Ƕ�λ����ʼλ�ã�
text(x_beacon(1),y_beacon(1),'  b1');  % ��ǻ�վλ�ã���ɫ
text(x_beacon(2),y_beacon(2),'  b2');
text(x_beacon(3),y_beacon(3),'  b3');
legend_1 = strcat('RMSE: ',str_rmse,'m');  % ���������
legend_2 = strcat('RMSE-MUV fir: ',str_rmse_kf,'m');
legend(legend_1,legend_2);
if Vx == 0
    x_act = [x_act x_act];  % ��y�᷽���˶�
    y_act = [0 11];
else
    x_act = [0 11];  % ��x�᷽���˶�
    y_act = [y_act y_act];
end
plot(x_act,y_act, 'g');  % ����ʵ��·������ɫ
hold off

% t = 1:i-j;
% plot(t,X(1,:),'ob',t,X(2,:),'*r');  % ԭʼ��λ-��ɫ������KF���-��
% hold on
% plot(t,X(1,:),'b',t,X(2,:),'r'); 
% grid minor;

% % ��άͼ����ʱ��仯
% hold off
% t = 1:(i-j);
% plot3(t,x0,y0,'k',t,Y(1,:),Y(2,:),'b',t,X(1,:),X(2,:),'r');  % ʵ��ֵ-��ɫ��ԭʼ��λ-��ɫ������KF��-��ɫ
% hold on;
% axis([0 (i-j) -1 2.5 0 3]);
% % axis([0 (i-j) 1 4 1 5.5]);  % Ϊƫ����׼����
% xlabel('t_ʱ��');
% ylabel('x��');
% zlabel('y��');
% % grid minor;
% grid on;
% text(1,Y(1,1),Y(2,1),'* s','color','b');  % ��Ƕ�λ����ʼλ�ã�'*'
% text(1,x0(1),y0(1),'o','color','k');  % ���ʵ��λ�ã���
% legend_1 = strcat('ԭʼ��λ��RMSE: ',str_rmse);
% legend_2 = strcat('����KF���RMSE: ',str_rmse_kf);
% legend('ʵ��λ��',legend_1,legend_2,1);
% plot3(t,Y(1,:),Y(2,:),'ob',t,X(1,:),X(2,:),'*r'); 
% hold off
