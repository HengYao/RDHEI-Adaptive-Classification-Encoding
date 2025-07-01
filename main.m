%main
clc; clear all; close all;
%parameter setting
bpp=zeros(1,100); De=zeros(1,1338); %ER
Dc=zeros(1,1338); %correlation
Dr=zeros(1,1338); %redundancy
SD=zeros(1,1338); %PSNR
SO=zeros(1,1338); %computation complexity
No=randperm(10000,1000);
sumbpp=0;encry_time=zeros(1,100);embedtime=zeros(1,100);recovertime=zeros(1,100);
bppchen=zeros(1,100);
bppgao=zeros(1,100);
for p=1:100
str = ['D:\haiqing\BOSSbase_1.01\',num2str(No(p)),'.pgm']; 
% str = ['D:\haiqing\BOWS2\BOWS2_\',num2str(No(p)),'.pgm']; 
% % str= sprintf('D:\\haiqing\\UCID\\%04d.tif', p);
% str = ['D:\haiqing\UCID\',num2str(p),'.tif'];
I=imread(str);
% I=imread('D:\Document\数据库\彩色\Splash.tiff');
% I=rgb2gray(I); 
rand('seed',1);
secret=round(rand(1,100000000));
% I=imread('D:\haiqing\fangzhen\Testimages\Airplane.bmp');
I=double(I);
[m,n]=size(I); 
[res1] = ImgEntropy(I);
s=3;%块的size3*3
tic;
[Ie1,Ie2,Ie] = encryption(I,s);

tic;
[LM1,LM2,EC,Iepro_block,au_block,numSG,numSL,bpp(p)] = Explore_correlation(Ie,s);%这里的au：012可以进一步压缩的代码00-2，01-3.。。，其他均为空
[MarkedIMage,pure_capacity,bpp(p)] =embedding(LM1,LM2,Iepro_block,secret,au_block,s,EC);
[Iemarked]=blockreconstruction(MarkedIMage,512,512,s);
embedtime(p)=toc;
tic;
[recover_img,data] = recovery(Iemarked,Ie,s);
recovertime(p)=toc

sumbpp=sumbpp+bpp(p);

end
average=sumbpp/100;

%% 计算原始图与加密图、含密图的相关系数、PNSR
% dPSNR_encry = psnr(I,Ie)
% dPSNR_marked= psnr(I,Iemarked)

% SSIM_encry=SSIM(I,Ie)
% SSIM_mark=SSIM(I,Iemarked)


%2025 3 11
% Ie=uint8(Ie)
% imwrite(Ie, 'D:\Users\Administrator\Desktop\大论文\实验图\work2\baboon加密.bmp'); 
% 
% Iemarked=uint8(Iemarked)
% imwrite(Iemarked, 'D:\Users\Administrator\Desktop\大论文\实验图\work2\baboonmarked.bmp');  % 保存为 BMP 格式
%% 显示图片，解密图和原始图对比
% subplot(1, 3, 1);
% imshow(I);
% title('original image I');
% 
% % 显示第二张图片
% subplot(1, 3, 2);
% imshow(Ie);
% title('encrypted image Ie');
% 
% % 显示第三张图片
% subplot(1, 3, 3);
% imshow(Ide);
% title('decrypted image Ide');
%% 绘制直方图Ie=double(Ie);
% % 将灰度图像转换为一维向量
% IVector = I(:);
% IeVector = Ie(:);
% IemVector = Iemarked(:);
% % IdeVector = Ide(:);
% % % 绘制直方图original image I
% % figure;
% % subplot(3,1,1),
% % figure;
% % hist(IVector, 0:255);
% % title('Histogram of the original image I');
% % % 绘制直方图encrtpted image Ie
% % % figure;
% % subplot(3,1,2),
% figure;
% hist(IeVector, 0:255);
% title('Histogram of the encrypted image Ie');
% figure;
% hist(IemVector, 0:255);
% title('Histogram of the encrypted image Iem');
% % 绘制直方图decrtpted image Ide
% % figure;
% subplot(3,1,3),hist(IdeVector, 0:255);
% title('Histogram of the decrypted image Ide');
% % 


