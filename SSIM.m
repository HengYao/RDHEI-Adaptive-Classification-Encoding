%衡量两幅图像之间相似度的指标 范围[0,1],1就是完全相同的两幅图像
function SSIM=SSIM(x,y)
L=255;
X1=mean2(x);
Y1=mean2(y);
X2=std2(x);
Y2=std2(y);
X2=X2^2;
Y2=Y2^2;
XY=cov(x,y);
xy=XY(2,1);
A=(2*X1*Y1+(0.01*L)^2)*(2*xy+(0.03*L)^2);
B=(X1^2+Y1^2+(0.01*L)^2)*(X2+Y2+(0.03*L)^2);
SSIM=A/B;
end