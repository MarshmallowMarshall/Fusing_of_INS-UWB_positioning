% clear;
% clc;
% 
% % ��ȡtxt�ľ�����Ϣ��������C_txt{4}��
% fid = fopen('2018-8-1-15-40-22.txt');
% C_txt = textscan(fid, '%s %s %s %s %s %s %s %s %s');
% fclose(fid);
% 
% T = 0.005;  % ʱ����Ϊ5ms
% a_x = hex_dec(C_txt{3});
% a_y = hex_dec(C_txt{4});
% a_z = hex_dec(C_txt{5});
% g_x = hex_dec(C_txt{6});  % x�᷽����ٶ�
% g_y = hex_dec(C_txt{7});
% g_z = hex_dec(C_txt{8});
% 
% a_x = a_x * 0.0005981445 + a_x_correction;  % ���ٶ����� 9.8*2��9.8*2/32768(7FFF) = 0.0005981445
% a_y = a_y * 0.0005981445 + a_y_correction;
% a_z = a_z * 0.0005981445;
% g_x = pi * g_x * 0.0076293945 / 180;  % ���ٶ����� 250��250/32768(7FFF) =  0.0076293945
% g_y = pi * g_y * 0.0076293945 / 180;
% g_z = pi * g_z * 0.0076293945 / 180 - 0.0124;
% 
% % ��ʼ��DCMg =[ig jg kg] = (DCMb)t��DCMb��Ϊ������ϵ�£�[I J K]������
% norm_a = (a_x^2 + a_y^2 + a_z^2)^0.5;
% a = [a_x a_y a_x]'/norm;  % ��һ�����������ٶ�
% Kb0 = -a ;  % ������ϵ�µ�zenith����ĵ�λ����������
% Ib0 = cross(Kb0,[0 ay 0]);
% Jb0 = cross(Kb0,Ib0);
% Ib0 = cross(Kb0,Jb0);
% %��һ��!!!!!!
% 
% w = [g_x g_y g_z];  % ���ٶ�
% theta_g = T * w;  % ���ٶȵĻ���Ϊ�Ƕ�
% Kb1a = -a;  % �µ��������ٶ�
% theta_a = cross(Kb0,(Kb1a - Kb0));
% theta = weight * theta_a + (1 - weight) * theta_g;
% Kb1 = Kb0 + cross(theta,Kb0);
% Ib1 = Ib0 + cross(theta,Ib0);
% Jb1 = cross(Kb1,Ib1);
% 
% DCMb = [Ib1' Jb1' Kb1'];
% DCMg = [Ib1;Jb1;Kb1];
% ig = DCMg * [1 0 0]';  % ������ϵ�Ļ�����ȫ������ϵ�е�����
% jg = DCMg * [0 1 0]';
% kg = DCMg * [0 0 1]';



function Ins_get_trajectory(temp)

global t
global X  % ����
global Y
global v  % �ٶ�
global vv
global T1
global angle_z

T2 = hex_dec(temp(2)) * 0.001;
a = hex_dec(temp(3:5));  % ���ٶ�
w = hex_dec(temp(6:8));  % ���ٶ�
a = a * 0.0005981445;
w = w * 0.0076293945 * 0.0175;  % ���ٶ����� 250��250/32768(7FFF) =  0.0076293945��pi/180 = 0.0175

% T = 0.005;  % ʱ����Ϊ5ms
T = T2 - T1;
T1 = T2;
t = t + 1;

% ��ʼ��
if t == 1
    X = 0;
    Y = 0;
    v = [0 0 0];
    angle_z = 0;
else 
    % ����
    angle_z = angle_z + w(3) * T;
      
    a_x_T = a(1) * cos(angle_z) - a(2) * sin(angle_z);  % �ȼ���Tʱ����ڣ�ʸ�����ٶ�a��imu�ο����굽ʵ�������ת��
    a_y_T = a(2) * cos(angle_z) + a(1) * sin(angle_z);  % a���ο�������-->ʵ��������
     
    v(1) = v(1) + a_x_T * T;  % ��ʵ�������µģ����ٶȵĻ��ּ�Ϊ��ʵ�������µģ��ٶ�
    v(2) = v(2) + a_y_T * T;
    
    x_T = v(1) * T + 0.5 * a_x_T * T^2;  % Tʱ���µ�λ��
    y_T = v(2) * T + 0.5 * a_y_T * T^2;
        
    X = X + x_T;
    Y = Y + y_T;
end
vv = [vv v'];

if ~mod(t-1,20)
    Display_trajectory(X,Y);
end

end


% clear;
% clc;
% 
% % ��ȡtxt�ľ�����Ϣ��������C_txt{4}��
% fid = fopen('2018-8-6-10-49-7.txt');
% C_txt = textscan(fid, '%s %s %s %s %s %s %s %s %s');
% fclose(fid)
% 
% a_x_correction = 0; a_y_correction = 0;  % ����
% x(1) = 0; y(1) = 0; z(1) = 0;  % ��ʼ��ԣ���imuΪ�ο��ģ�λ��
% X(1) = 0; Y(1) = 0; Z(1) = 0;  % ��ʼ���ԣ�ѡ�����Դ��Ϊ�ο���λ��
% T = 0.005;  % ʱ����Ϊ5ms
% v_x(1) = 0; v_y(1) = 0; v_z(1) = 0;  % ���ٶ�Ϊ��
% or_z(1) = 0;  % z�᷽���ʼ�Ƕȣ���ʼ��λ�������λ�������λ�ã�Ϊ��
% a_x = hex_dec(C_txt{3});
% a_y = hex_dec(C_txt{4});
% a_z = hex_dec(C_txt{5});
% g_x = hex_dec(C_txt{6});  % x�᷽����ٶ�
% g_y = hex_dec(C_txt{7});
% g_z = hex_dec(C_txt{8});
% 
% a_x = a_x * 0.0005981445 + a_x_correction;  % ���ٶ����� 9.8*2��9.8*2/32768(7FFF) = 0.0005981445
% a_y = a_y * 0.0005981445 + a_y_correction;
% a_z = a_z * 0.0005981445;
% g_x = pi * g_x * 0.0076293945 / 180;  % ���ٶ����� 250��250/32768(7FFF) =  0.0076293945
% g_y = pi * g_y * 0.0076293945 / 180;
% g_z = pi * g_z * 0.0076293945 / 180 - 0.0124;
% 
% % ��ÿ��ʱ���T�ڣ�
% % �ɽ����ʣ���֪�����õ���������ϵ�ĽǶ� -> �ɸýǶȣ���ʸ�����ٶ�a����֪������ת�� -
% % -> ��ת�����a���֣������ٶ� -> ���ٶȣ������ʱ����ڵ�λ�� -> �Ը�λ�ƻ��֣��õ�ʵ������.
% for t = 2:length(C_txt{1})
%     if ismember(C_txt{1}(t),'$IMU')
%         % ���ٶȵĻ����ǽǶȣ�����λorientation
%         or_z(t) = or_z(t-1) + g_z(t) * T;
%         
%         a_x_T = a_x(t-1) * cos(or_z(t-1)) - a_y(t-1) * sin(or_z(t-1));  % �ȼ���Tʱ����ڣ�ʸ�����ٶ�a��imu�ο����굽ʵ�������ת��
%         a_y_T = a_y(t-1) * cos(or_z(t-1)) + a_x(t-1) * sin(or_z(t-1));  % a���ο�������-->ʵ��������
%         
%         v_x(t) = v_x(t-1) + a_x_T * T;  % ��ʵ�������µģ����ٶȵĻ��ּ�Ϊ��ʵ�������µģ��ٶ�
%         v_y(t) = v_y(t-1) + a_y_T * T;
%         
%         x_T = v_x(t-1) * T + 0.5 * a_x_T * T^2;
%         y_T = v_y(t-1) * T + 0.5 * a_y_T * T^2;
%         
%         X(t) = X(t-1) + x_T;
%         Y(t) = Y(t-1) + y_T;
%          
%     end
% end
% plot(X,Y,'g');
% axis equal;
% xlabel('x��');
% ylabel('y��');
% text(x(1),y(1),'o','color','b');  % �����ʼλ��