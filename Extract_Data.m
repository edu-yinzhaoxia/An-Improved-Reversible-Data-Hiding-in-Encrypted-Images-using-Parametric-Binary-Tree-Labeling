function [Side_Info,Encrypt_exD,PE_I,pa_1,pa_2] = Extract_Data(stego_I,num_emD)
% 函数说明：在加密标记图像中提取信息
% 输入：stego_I（加密标记图像）,num_emD（秘密信息的长度）
% 输出：Side_Info（辅助信息）,Encrypt_exD（加密的秘密信息）,PE_I（预测误差）,pa_1,pa_2（参数）
%% 提取参数
pa_value = stego_I(1,1); %存储参数的像素位于第一个分块的第一个位置
[bin_pa] = Decimalism_Binary(pa_value); %当前像素值对应的8位二进制
bin_pa_1(1:4) = bin_pa(1:4); %前4位记录参数pa_1
bin_pa_2(1:4) = bin_pa(5:8); %后4位记录参数pa_2
[pa_1] = Binary_Decimalism(bin_pa_1);
[pa_2] = Binary_Decimalism(bin_pa_2);
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
dv = max - pe_max;
%% 辅助量
[row,col] = size(stego_I); %统计stego_I的行列数
num_side = 0; %计数，记录辅助信息的个数
Info = zeros(); %记录提取的信息（包括辅助信息和秘密数据）
t = 0; %计数,统计提取信息的个数
PE_I = stego_I;
%% 提取嵌入的信息
for i=2:row
    for j=2:col
        sign = 0; %标记信息，判断是嵌入点还是不可嵌入点
        value = stego_I(i,j); %当前载密像素值
        [bin2_8] = Decimalism_Binary(value); %当前载密像素值对应的8位二进制
        bin2_8 = fliplr(bin2_8); %将8位二进制bin2_8翻转
        for k=1:pa_2
            if bin2_8(k) ~= 0
                sign = 1; %表示前pa_2位不全为0，即为可嵌入点
            end
        end
        if sign == 1 %可嵌入点
            bin_mark = bin2_8(1:pa_1); %提取标记值
            [mark] = Binary_Decimalism(bin_mark); %将表机制转换成十进制
            PE_I(i,j) = mark - dv; %预测误差与标记值相差dv
            Info(t+1:t+8-pa_1) = bin2_8(pa_1+1:8); %标记位之外的记为嵌入的信息
            t = t + 8-pa_1;
        else %不可嵌入点
            num_side = num_side + pa_2; %前pa_2位作为辅助信息
            PE_I(i,j) = pe_min - 1; %将其测误差设为嵌入预范围之外
        end 
    end
end
%% 记录辅助信息和加密的秘密数据
num_side = num_side + 8; %特殊像素8位也作为辅助信息
Side_Info = Info(1:num_side);
Encrypt_exD = Info(num_side+1:num_side+num_emD);
end