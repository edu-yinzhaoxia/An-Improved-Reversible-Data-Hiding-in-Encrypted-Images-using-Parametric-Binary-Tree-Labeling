function PSNR=PSNR(Img1,Img2)
%函数功能：查看均方差
%函数输入：两图像像素值
%函数输出：均方差
Img1=double(Img1(:));  %将数据转换为double型
Img2=double(Img2(:)); 
MSE=sum((Img1-Img2).*(Img1-Img2))/numel(Img1); %求均方差
if MSE==0
    fprintf('MSE = 0\n');
    PSNR=-1;
else
    PSNR=10*log10(255*255/MSE);
end