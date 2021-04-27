% ��ʼʱ������������У��
% ��������Ư�ƽ���һ�³�ʼУ��������


function Ins_get_trajectory_accurate(temp)

global t
global coordinate
global displacement_T
global v  % �ٶ�
global vv
global T1
global g  % �������ٶ�
global a_cor  % ���ٶ�У������
global w_cor  % ���ٶ�У������
global N_g_cor % У������
global w_record

global t1

T2 = hex_dec(temp(2)) * 0.001;
if t==1
    t1 = T2;
end
a = hex_dec(temp(3:5));  % ���ٶ�
w = hex_dec(temp(6:8));  % ���ٶ�
a = a * 0.0005981445;
w = w * 0.0076293945 * 0.0175;  % ���ٶ����̣����ȣ� 250��250/32768(7FFF) =  0.0076293945��pi/180 = 0.0175
a = a';

% T = 0.005;  % ʱ����Ϊ5ms
T = T2 - T1;
T1 = T2;
t = t + 1;

% ��ʼ��,У׼
 if t <= N_g_cor
        coordinate_ins = [0 0 0]';
        v = [0 0 0]';
        a_T = [0 0 0]';
        % ʵ���������ٶ�
        g = g + a/N_g_cor;
        % У�����ٶ�
        w_record(:,t) = w';
        if t == N_g_cor  % У׼���ٶ�
            norm_g =  (g(1)^2 + g(2)^2 + g(3)^2)^0.5;
            a_cor = 9.7966 / norm_g;  % ������ٶ�У������
            g = 9.7966 * (g/norm_g);
            % ��w������ֵ����������������������
            for i = 1:3
              w_cor(i) = mean(w_record(i,:));
            end
            'start-------------'    
        end
else
    w = w - w_cor;
    for i = 1:3
        if abs(w(i)) < 0.004
            w(i) = 0;
        end
    end
    w_record(:,t) = w';
    DCMg = Quaternion_without_m( T, a, w, t );
    
    % ���ٶ�ת����ȫ������ϵ�£�����ȥ����
    a_T = DCMg * (a*a_cor) - g;
    for i = 1:3
        if abs(a_T(i)) < 0.06
            a_T(i) = 0;
        end
    end
    
    % �õ��ٶ�<-���ٶȻ���
    v = v + a_T * T;  % ��ʵ�������µģ����ٶȵĻ��ּ�Ϊ��ʵ�������µģ��ٶ�
    
    % �õ�λ��<-�ٶȻ���
    displacement_T = v * T + 0.5 * a_T * T^2;  % Tʱ���µ�λ��
    
    coordinate = coordinate + displacement_T;
end
vv = [vv a_T];  % record v or a_T

if ~mod(t-1,15)
    Display_trajectory(coordinate);
end

end


% clear;
% clc;
% 
% % ��ȡtxt�ľ�����Ϣ��������C_txt{4}��
% fid = fopen('2018-8-6-10-49-7.plot(vv(2,:))txt');
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