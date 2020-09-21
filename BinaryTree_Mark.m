function [mark_I,Side_Info,pe_min,pe_max] = BinaryTree_Mark(PE_I,encrypt_I,pa_1,pa_2)
% 函数说明：对加密图像encrypt_I进行标记
% 输入：PE_I（预测误差）,encrypt_I（加密图像）,,pa_1,pa_2（参数）
% 输出：mark_I（标记图像）,Side_Info（辅助信息）,pe_min,pe_max（可嵌入预测误差范围）
[row,col] = size(encrypt_I); %计算encrypt_I的行列值
mark_I = encrypt_I;  %构建存储标记图像的容器
%% 求可嵌入数据的预测误差的范围
if pa_1 <= pa_2
    na = 2^pa_1 - 1;
else
    na = (2^pa_2-1)*(2^(pa_1-pa_2));
end
pe_min = ceil(-na/2);
pe_max = floor((na-1)/2);
%% 计算像素的标记比特值与其预测误差的差值
bin_max = ones(1,pa_1); %全为1的标记
[max] = Binary_Decimalism(bin_max);
dv = max - pe_max; %方便计算标记值
%% 辅助量
Side_Info = zeros(); %记录辅助信息
num_S = 0; %计数，统计辅助信息个数
%% 在特殊像素位置存储参数pa_1和pa_2
value = encrypt_I(1,1); %当前加密像素值
[bin2_8] = Decimalism_Binary(value); %当前加密像素值对应的8位二进制
Side_Info(num_S+1:num_S+8) = bin2_8; %记录参考像素值作为辅助信息
num_S = num_S + 8;
[bin_pa_1] = Decimalism_Binary(pa_1); %参数pa_1对应的8位二进制
[bin_pa_2] = Decimalism_Binary(pa_2); %参数pa_2对应的8位二进制
bin2_8(1:4) = bin_pa_1(5:8); %参数最多4位即可表示
bin2_8(5:8) = bin_pa_2(5:8);
[value] = Binary_Decimalism(bin2_8); %将参数二进制转换成标记像素值
mark_I(1,1) = value;
%% 根据预测误差对图像进行标记
for i=2:row
    for j=2:col
        pe = PE_I(i,j); %当前像素点的预测误差
        value = encrypt_I(i,j); %当前加密像素值
        [bin2_8] = Decimalism_Binary(value); %当前加密像素值对应的8位二进制
        bin2_8 = fliplr(bin2_8); %将8位二进制bin2_8翻转                 %%%%%%%%%为什么要翻转
        if pe>=pe_min && pe<=pe_max  %可嵌入加密像素，用pa_1比特标记
            mark = pe + dv; %mark表示标记比特转成十进制的值
            [bin_mark] = Decimalism_Binary(mark); %标记mark对应的8位二进制
            bin2_8(1:pa_1) = bin_mark(8-pa_1+1:8);%标记mark只用pa_1比特表示
        else %不可嵌入像素，用pa_2比特全0标记
            Side_Info(num_S+1:num_S+pa_2) = bin2_8(1:pa_2); %记录加密像素值的前pa_2比特MSB作为辅助信息
            num_S = num_S + pa_2;
            for k=1:pa_2
                bin2_8(k) = 0;
            end
        end
        bin2_8 = fliplr(bin2_8); %将bin2_8翻转回来
        [value] = Binary_Decimalism(bin2_8); %将标记后的二进制转换成标记像素值
        mark_I(i,j) = value; %记录标记像素 
    end
end
end