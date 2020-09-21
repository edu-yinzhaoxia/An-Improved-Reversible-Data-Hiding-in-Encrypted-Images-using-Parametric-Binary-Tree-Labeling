clear
clc
%% 产生二进制秘密数据
num = 10000000;
rand('seed',0); %设置种子
D = round(rand(1,num)*1); %产生稳定随机数
%% 图像数据集信息(BOWS2OrigEp3),格式:PGM,数量:10000；
I_file_path = 'C:\Users\pw\Desktop\多媒体信息安全\标准图像库——濮阳义\BOWS2OrigEp3\'; %测试图像数据集文件夹路径
I_path_list = dir(strcat(I_file_path,'*.pgm')); %获取该文件夹中所有pgm格式的图像
img_num = length(I_path_list); %获取图像总数量
%% 记录每张图像的嵌入量和嵌入率
num_BOWS2OrigEp3 = zeros(1,img_num); %记录每张图像的嵌入量 
bpp_BOWS2OrigEp3 = zeros(1,img_num); %记录每张图像的嵌入率
%% 设置参数
Image_key = 1;%图像加密密钥
Data_key = 2; %数据加密密钥
pa_1 = 5; %论文中的α，用来标记可嵌入块的bit数
pa_2 = 2; %论文中的β，用来标记不可嵌入块的bit数
%% 图像数据集测试
for i=1:img_num%5
    %----------------读取图像----------------%
    I_name = I_path_list(i).name; %图像名
    I = imread(strcat(I_file_path,I_name));%读取图像
    origin_I = double(I);
   %---------------%% 图像加密及数据嵌入----------------%
   [stego_I,encrypt_I,emD,num_emD] = Encrypt_Embed(origin_I,Image_key,D,Data_key,pa_1,pa_2);
   
    if num_emD > 0
        %--------在加密标记图像中提取信息--------%
        [Side_Info,Encrypt_exD,PE_I,pa_1,pa_2] = Extract_Data(stego_I,num_emD);
        %---------------解密数据----------------%
        [exD] = Encrypt_Data(Encrypt_exD,Data_key);
        %---------------图像恢复----------------%
        [recover_I] = Recover_Image(stego_I,Image_key,Side_Info,PE_I,pa_1,pa_2);
        %---------------结果记录----------------%
        [m,n] = size(origin_I);
        num_BOWS2OrigEp3(i) = num_emD;
        bpp_BOWS2OrigEp3(i) = num_emD/(m*n);
        %---------------结果判断----------------%
        check1 = isequal(emD,exD);
        check2 = isequal(origin_I,recover_I);
        if check1 == 1  
            disp('提取数据与嵌入数据完全相同！')
        else
            disp('Warning！数据提取错误！')
        end
        if check2 == 1
            disp('重构图像与原始图像完全相同！')
        else
            disp('Warning！图像重构错误！')
        end
        %---------------结果输出----------------%
        if check1 == 1 && check2 == 1
            bpp = bpp_BOWS2OrigEp3(i);
            disp(['Embedding capacity equal to : ' num2str(num_emD)])
            disp(['Embedding rate equal to : ' num2str(bpp)])
            fprintf(['第 ',num2str(i),' 幅图像-------- OK','\n\n']);
        else
            if check1 ~= 1 && check2 == 1
                bpp_BOWS2OrigEp3(i) = -2; %表示提取数据不正确
            elseif check1 == 1 && check2 ~= 1
                bpp_BOWS2OrigEp3(i) = -3; %表示图像恢复不正确
            else
                bpp_BOWS2OrigEp3(i) = -4; %表示提取数据和恢复图像都不正确
            end
            fprintf(['第 ',num2str(i),' 幅图像-------- ERROR','\n\n']);
        end  
    else
        num_BOWS2OrigEp3(i) = -1; %表示不能嵌入信息  
        disp('辅助信息大于总嵌入量，导致无法存储数据！') 
        fprintf(['第 ',num2str(i),' 幅图像-------- ERROR','\n\n']);
    end
end
%% 保存数据
save('num_BOWS2OrigEp3')
save('bpp_BOWS2OrigEp3')