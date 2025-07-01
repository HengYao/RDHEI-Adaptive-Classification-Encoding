%% 包括recovery 计算时间开销
rand('seed',1);
secret=round(rand(1,100000000));
I=imread('D:\haiqing\fangzhen\Testimages\Airplane.bmp');
I=double(I);
[m,n]=size(I); 
[res1] = ImgEntropy(I);
s=3;%块的size3*3
tic;
[Ie1,Ie2,Ie] = encryption(I,s);
encry_time=toc;
% [Ie]=xor_permu(I,s);
[res2] = ImgEntropy(Ie);
%

[LM1,LM2,EC,Iepro_block,au_block,numSG,numSL] = Explore_correlation(Ie,s);%这里的au：012可以进一步压缩的代码00-2，01-3.。。，其他均为空
tic;
[MarkedIMage,pure_capacity,bpp] =embedding(LM1,LM2,Iepro_block,secret,au_block,s,EC);
[Iemarked]=blockreconstruction(MarkedIMage,512,512,s);
embedtime=toc;
[res3] = ImgEntropy(Iemarked);
tic;
[recover_img,data] = recovery(Iemarked,Ie,s);
recovertime=toc
imshow(uint8(recover_img))