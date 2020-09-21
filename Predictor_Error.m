function [PE_I] = Predictor_Error(origin_I)  
% 函数说明：计算origin_I的预测误差
% 输入：origin_I（原始图像）
% 输出：PE_I（原始图像的预测误差）
[row,col] = size(origin_I); %计算origin_I的行列值
PE_I = origin_I;  %构建存储origin_I预测值的容器
for i=2:row  %第一行作为参考像素，不用预测
    for j=2:col  %第一行作为参考像素，不用预测
        a = origin_I(i-1,j);
        b = origin_I(i-1,j-1);
        c = origin_I(i,j-1);
        if b <= min(a,c)
            pv = max(a,c);
        elseif b >= max(a,c)
            pv = min(a,c);
        else
            pv = a + c - b;
        end
        PE_I(i,j) = origin_I(i,j) - pv;
    end
end