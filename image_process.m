%将每个块的哈夫曼码字嵌入至每一块的LSB中
%au是嵌入到每个块的部分:哈夫曼码字+（s2）+numi=012产生的au 被替换的LSB
function [Iepro,au,au00] =image_process(LM1,LM2,Iepro,au_block,s,dict)
% au_block=au_block;
bs=s*s;
w=size(Iepro,1);
countindex=0;
index=[];
for i=1:size(dict,2)
   countindex=countindex+1;
   index(countindex)=dict{1,i};
end
countau=0;
au={};
count00=0;
au00={};%% 存储num=0且不能进一步压缩的块存储码字+s2时候替换的LSB
counts=0;%s2的索引

for t=1:w
     blocki=Iepro(t,:);
     blocki_bin=zeros(s*s,8);
     counter=0;
      for i=1:s*s
            counter=counter+1;
            blocki_bin(counter,:)=bitget(blocki(i),8:-1:1); 
       end
    
     dex=find(LM1(t)==index);
     x=dict{2,dex};
     countx=0;
     LSB=[];%被替换的原始LSB

     %嵌入当前块对应的哈夫曼码字
     for j=1:length(x)
        countx=countx+1;
        LSB(countx)=blocki_bin(j,8);
        blocki_bin(j,8)=x(j);
     end
     
     %嵌入额外的numi=012生成的

     if LM1(t)>=3
         countau=countau+1;
         au{countau}=LSB;
     elseif LM1(t)==1||LM1(t)==2
         counts=counts+1;%LM2的索引,将s2嵌入进去
         countx=countx+1;
         LSB(countx)=blocki_bin(countx,8);
         blocki_bin(countx,8)=LM2(counts);
         if LM2(counts)==0%等价于LM2(counts)==0
            countau=countau+1;
            au{countau}=LSB;
         else
             Au=au_block{t};%%%利用中间数组变量将当前块的附加信息放在中间变量中。
             for k=1:length(Au)
                 countx=countx+1; 
                 if countx>s*s
                    dd=mod(countx,s*s);
                    LSB(countx)=blocki_bin(dd,7);
                    blocki_bin(dd,7)=Au(k);
                 else
                    LSB(countx)=blocki_bin(countx,8);
                    blocki_bin(countx,8)=Au(k); 
                 end
             end
              countau=countau+1;
              au{countau}=LSB;
         end
          
     else%LM(i)==0;
         
         counts=counts+1;%LM2的索引,将s2嵌入进去
         countx=countx+1;
         LSB(countx)=blocki_bin(countx,8);
         blocki_bin(countx,8)=LM2(counts);
         if LM2(counts)==0
             count00=count00+1;
             au00{count00}=LSB;
             countau=countau+1;
             au{countau}=[];
         else
              Au=au_block{t};%%%利用中间数组变量将当前块的附加信息放在中间变量中。
             for k=1:length(Au)
                 countx=countx+1; 
                 if countx>s*s
                    dd=mod(countx,s*s);
                    LSB(countx)=blocki_bin(dd,7);
                    blocki_bin(dd,7)=Au(k);
                 else
                    LSB(countx)=blocki_bin(countx,8);
                    blocki_bin(countx,8)=Au(k); 
                 end
             end
             countau=countau+1;
             au{countau}=LSB;
         end
     end 

     blocki=zeros(1,s*s);
     for i=1:s*s
        for k=1:8
            blocki(1,i)=blocki(1,i)+blocki_bin(i,k)*2^(8-k);
        end
     end
     Iepro(t,:)=blocki;
end


    





