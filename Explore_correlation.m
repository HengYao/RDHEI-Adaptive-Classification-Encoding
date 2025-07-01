%注：这里的EC不是pure，里面包括需要嵌入附加信息的空间。Iepro_block是size=w,s*s
%LM2存储的是num=012能否进一步压缩的指示位，0-不能压缩，1-能压缩
function [LM1,LM2,EC,Iepro_block,au_block,numSG,numSL,bpp] = Explore_correlation(Ie,s)
% clc; clear all; close all;
% I=imread("Lake.bmp");
% I=double(I);
% s=3;%块大小3*3
% [Ie]=encryption(I,s);
Ie=double(Ie);
[m,n]=size(Ie);
w=floor(m/s)*floor(n/s);
Iepro_block=zeros(w,s*s);
[Ieblock]=blockdivided(Ie,s,s);
num0SG=[];num0SL=[];index0=[];
numSG=[];numSL=[];
num1SG=[];num1SL=[];index1=[];
num2SG=[]; num2SL=[];index2=[];
sum0=0;sum_0=0;ECAD0=0;len_au0=0;
sum1=0;sum_1=0;ECad1=0;ECAD1=0;EC_pvr1=0;len_au1=0;
sum2=0;sum_2=0;ECad2=0;ECAD2=0;EC_pvr2=0;len_au2=0;
sum3=0; EC_pvr3=0;
sum4=0;EC_pvr4=0;
sum5=0;EC_pvr5=0;
sum6=0;EC_pvr6=0;
sum7=0;EC_pvr7=0;
counter=0;LM1=zeros(1,w);%存储每个块的num或者说md
counters2=0;LM2=[];
EC=zeros(1,w);au_block={};countecode=0;
counternum=0;
%% 分析加密图像块的相关性 
for t=1:w
       It=Ieblock(t,:);
       Iepro_block(t,:)=Ieblock(t,:);
       It=SeqintoMatrix(It); 
       %计算对应块的num
       [md] = num_generation(It,s);
       if md==8%8按照7处理
           md=7;
       end
       LM1(1,t)=md;
        if md==0
          sum0=sum0+1;
          [s2,EC0,code0,Itpro,num_SG,num_SL] = new2(It,md);
          Iepro_block(t,:)=Itpro;
          counters2=counters2+1;
          LM2(counters2)=s2;                                           
          len_au0=len_au0+length(code0);
          if  s2==1 
             sum_0=sum_0+1;%统计进一步压缩的块的数量
             counternum=counternum+1;
%              index0(sum_0)=t;%记录进一步压缩的块的索引
             numSG(counternum)=num_SG; numSL(counternum)=num_SL;
           end
             ECAD0=ECAD0+EC0;
             EC(1,t)=EC0;
             countecode=countecode+1;
             au_block{countecode}=code0;
       elseif  md==1
           sum1=sum1+1;
           [s2,EC1,code1,Itpro,num_SG,num_SL] = new2(It,md);
           Iepro_block(t,:)=Itpro;
          counters2=counters2+1;
          LM2(counters2)=s2;
          len_au1=len_au1+length(code1);
          if s2==1
            sum_1=sum_1+1; 
%             index1(sum_1)=t;
%             num1SG(sum_1)=num_SG; num1SL(sum_1)=num_SL;
            counternum=counternum+1;
            numSG(counternum)=num_SG; numSL(counternum)=num_SL;
            ECad1=ECad1+EC1;
            ECAD1=ECAD1+EC1+md*(s*s-1);%Pvr+newad
          else
             EC_pvr1=EC_pvr1+md*(s*s-1);%只用PVR编码
          end
            EC(1,t)=EC1+md*(s*s-1);
            countecode=countecode+1;
            au_block{countecode}=code1;
        elseif md==2 
           sum2=sum2+1;
          [s2,EC2,code2,Itpro,num_SG,num_SL] = new2(It,md);
          Iepro_block(t,:)=Itpro;
          counters2=counters2+1;
          LM2(counters2)=s2;
          len_au2=len_au2+length(code2);
          if s2==1
            sum_2=sum_2+1; 
%             index2(sum_2)=t;
%             num2SG(sum_2)=num_SG; num2SL(sum_2)=num_SL;
            ECad2=ECad2+EC2;
            ECAD2=ECAD2+EC2+2*(s*s-1);%Pvr+newad
            counternum=counternum+1;
            numSG(counternum)=num_SG; numSL(counternum)=num_SL;
          else
             EC_pvr2=EC_pvr2+2*(s*s-1);%只用PVR编码
          end
             EC(1,t)=EC2+md*(s*s-1);
             countecode=countecode+1;
             au_block{countecode}=code2;
        elseif md==3 
            sum3=sum3+1;
           EC_pvr3=EC_pvr3+md*(s*s-1);
           EC(1,t)=md*(s*s-1);
           au=[];
           countecode=countecode+1;
           au_block{countecode}=au;
        elseif md==4 
            sum4=sum4+1;
           EC_pvr4=EC_pvr4+md*(s*s-1);
           EC(1,t)=md*(s*s-1);
           au=[];
           countecode=countecode+1;
           au_block{countecode}=au;
       elseif md==5 
           sum5=sum5+1;
           EC_pvr5=EC_pvr5+md*(s*s-1);
           EC(1,t)=md*(s*s-1);
           au=[];
           countecode=countecode+1;
           au_block{countecode}=au;
        elseif md==6 
           sum6=sum6+1;
           EC_pvr6=EC_pvr6+md*(s*s-1);
           EC(1,t)=md*(s*s-1);
           au=[];
           countecode=countecode+1;
           au_block{countecode}=au;
        else
           sum7=sum7+1;
           EC_pvr7=EC_pvr7+7*(s*s-1);
           EC(1,t)=md*(s*s-1);
           au=[];
           countecode=countecode+1;
           au_block{countecode}=au;
        end   
 end
pure0=ECAD0-len_au0;
pure1=EC_pvr1+ECAD1-len_au1;
pure2=EC_pvr2+ECAD2-len_au2;
cap=pure0+pure1+pure2+EC_pvr3+EC_pvr4+EC_pvr5+EC_pvr6+EC_pvr7;
bpp=cap/512/512;