function [recover_I] = Recover_Image(stego_I,Image_key,Side_Info,PE_I,pa_1,pa_2)
% 函数说明：根据提取的辅助信息和密钥恢复图像
% 输入：stego_I（载密图像）,Image_key（图像加密密钥）,Side_Info（辅助信息）,PE_I（预测误差）,pa_1,pa_2（参数）
% 输出：recover_I（恢复图像）
%% 辅助量
[row,col] = size(stego_I); %统计stego_I的行列数
num_side = 0; %计数，记录辅助信息的个数
%% 求可嵌入数据的预测误差的范围
if pa_1 <= pa_2
    na = 2^pa_1 - 1;
else
    na = (2^pa_2-1)*(2^(pa_1-pa_2));
end
pe_min = ceil(-na/2);
pe_max = floor((na-1)/2);
%% 恢复特殊像素点的值
trans_I = stego_I; %构建部分恢复的过渡图像
bin2_8 = Side_Info(num_side+1:num_side+8); %特殊像素作为8位辅助信息
num_side = num_side + 8;
[value] = Binary_Decimalism(bin2_8); %将8位二进制转换成特殊像素值
trans_I(1,1) = value;
%% 恢复不可嵌入点的标记位
for i=2:row
    for j=2:col
        pe = PE_I(i,j); %当前像素点的预测误差
        if pe>=pe_min && pe<=pe_max  %可嵌入点
            continue;
        else %不可嵌入点，替换前pa_2位标记值
            value = trans_I(i,j); %当前解密像素值
            [bin2_8] = Decimalism_Binary(value); %当前解密像素值对应的8位二进制
            bin2_8 = fliplr(bin2_8); %将8位二进制bin2_8翻转
            bin2_8(1:pa_2) = Side_Info(num_side+1:num_side+pa_2);
            num_side = num_side + pa_2;
            bin2_8 = fliplr(bin2_8); %将bin2_8翻转回来
            [value] = Binary_Decimalism(bin2_8); %将替换后的8位二进制转换成像素值
            trans_I(i,j) = value;
        end   
    end
end
%% 对图像trans_I进行解密
[decrypt_I] = Encrypt_Image(trans_I,Image_key);

%% 恢复可嵌入点的像素值
recover_I = decrypt_I;
%subplot(111);imshow(recover_I,[]);title('恢复图像');
for i=2:row
    for j=2:col
        pe = PE_I(i,j); %当前像素点的预测误差
        if pe>=pe_min && pe<=pe_max  %可嵌入点
            %--先求预测值，再根据预测误差恢复像素值--%
            a = recover_I(i-1,j);
            b = recover_I(i-1,j-1);
            c = recover_I(i,j-1);
            if b <= min(a,c)
                pv = max(a,c);
            elseif b >= max(a,c)
                pv = min(a,c);
            else
                pv = a + c - b;
            end
            recover_I(i,j) = pv + pe;
        else %不可嵌入点
            continue;
        end   
    end
end
end