function [MarkedIMage,pure_capacity,bpp] =embedding(LM1,LM2,Iepro,secret,au_block,s,EC)
% Iepro=Iepro_block;au=au_block;
MarkedIMage=Iepro;
counter2=0;%LM2的索引
Iepro=double(Iepro);
bs=s*s;
w=size(Iepro,1);
[dict,huff_rule]=uni_huffuman(LM1);
[Iepro,au,au00] =image_process(LM1,LM2,Iepro,au_block,s,dict);
% [Iepro,au,au00] =image_process(LM1,LM2,Iepro,au_block,s,dict,EC);
index=[];
countindex=0;
for i=1:size(dict,2)
   countindex=countindex+1;
   index(countindex)=dict{1,i};
end
% lenhuff=length(huff_rule);
% lenhuff_bin=zeros(1,8);
% for i=1:lenhuff_bin
%     lenhuff_bin(8-i+1)=bitget(lenhuff,i);

L=huff_rule;
originalbit=[];
countL=0;
W1=ceil(length(L)/(s*s*8));%嵌入LM1LM2大概需要多少块
for t=1:W1
     blocki=Iepro(t,:);
     blocki_bin=zeros(s*s,8);
     counter=0;
     for i=1:s*s
        counter=counter+1;
        blocki_bin(counter,:)=bitget(blocki(i),8:-1:1); 
     end

     for i=1:s*s
          for k=1:8
               countL=countL+1;
               if countL<=length(L)
                    originalbit(countL)=blocki_bin(i,k);%被替换的bit存储到original bit中
                    blocki_bin(i,k)=L(countL);
               else 
                   break;
               end
              
          end
          if countL>length(L)
              break;
          end

     end
     blocki=zeros(1,s*s);
     for i=1:s*s
        for k=1:8
            blocki(1,i)=blocki(1,i)+blocki_bin(i,k)*2^(8-k);
        end
     end
     MarkedIMage(t,:)= blocki;
end
%把au00转换为数组
au0=[];
count00=0;
for i=1:size(au00,2)
    count00=count00+1;
    a0=length(au00{i});
    au0(count00:count00+a0-1)=au00{i};
    count00=count00+a0-1;
end
%data将originalbit和secret拼接在一起，便于实现嵌入
data=[originalbit au0 secret];
countdata=0;
len_au=0;
counts=0;%LM2索引
lenau00=0;
count00=0;
for  t=1:W1
    if LM1(t)<3
        counts=counts+1;
    end
end

for t=W1+1:w
       blocki=Iepro(t,:);
%      blocki=SeqintoMatrix(blocki); 
       blocki_bin=zeros(s*s,8);
       counter=0;
       for i=1:s*s
            counter=counter+1;
            blocki_bin(counter,:)=bitget(blocki(i),8:-1:1); 
       end
       
       if EC(t)==0 %numi=0且对应LM2==0；           
           count00=count00+1;
           counts=counts+1;
           lenau00=lenau00+length(au00{count00});
           continue;
       end
       count_cap=0;
       capacity=zeros(1,EC(t));
       
       Au=au{t};
       capacity(1,1:length(Au))=Au;
       a=EC(t)-length(au{t});
       countdata=countdata+1;
       capacity(1,length(Au)+1:EC(t))=data(countdata:countdata+a-1);
       countdata=countdata+a-1;
       if LM1(t)>=3
           for i=2:s*s
               for k=1:LM1(t)
                    count_cap=count_cap+1;
                    blocki_bin(i,k)=capacity(count_cap);
               end
           end
       else %md=1，2可不可嵌，md=0可嵌
             counts=counts+1;
             dex=find(LM1(t)==index);
             x=dict{2,dex};%当前块对应的哈夫曼码字
             if LM2(counts)==0 %md=1，2且不可进一步压缩
                   for i=2:s*s
                       for k=1:LM1(t)
                            count_cap=count_cap+1;
                            blocki_bin(i,k)=capacity(count_cap);
                       end
                   end               
             else  %md=1，2,0且可以进一步压缩
                   len_block=length(Au)-length(x)-1;%Lenblock就是存储的进一步压缩压缩的SG\SL的长度
                   countSG=0;countSL=0;
                   indexSG=[];indexSL=[];

                   for  i=1:bs   %存储sg组的索引 存储sL组的索引
                       if blocki_bin(i,LM1(t)+1)==1
                           countSG=countSG+1;
                           indexSG(countSG)=i;
                       else 
                           countSL=countSL+1;
                           indexSL(countSL)=i;
                       end
                   end
                   start=length(x)+2;%SG\SL码字开始的索引
                   if  len_block<4  %获取numSG、numSL的值
                       if countSG<countSL
                          numSL_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                          numSL=0;
                          for k=1:2
                              numSL=numSL+numSL_bin(k)*2^(2-k);
                          end
                          numSL=numSL+2;
                          numSG=0;
                       elseif countSG>countSL
                          numSG_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                          numSG=0;
                          for k=1:2
                              numSG=numSG+numSG_bin(k)*2^(2-k);
                          end
                          numSG=numSG+2;
                          numSL=0;
                       end
                   else
                      
                       if start+1>bs
                            numSG_bin=[blocki_bin(start,8) blocki_bin(mod(start+1,bs),7)];
                            numSL_bin=[blocki_bin(mod(start+2,bs),7) blocki_bin(mod(start+3,bs),7)];
                       elseif start+1==bs
                            numSG_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                            numSL_bin=[blocki_bin(mod(start+2,bs),7) blocki_bin(mod(start+3,bs),7)];
                      elseif start+2==bs 
                            numSG_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                            numSL_bin=[blocki_bin(start+2,8) blocki_bin(mod(start+3,bs),7)]; 
                       else
                           numSG_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                           numSL_bin=[blocki_bin(start+2,8) blocki_bin(start+3,8)]; 
                       end

                       numSG=0;
                       for k=1:2
                              numSG=numSG+numSG_bin(k)*2^(2-k);
                       end
                      numSG=numSG+2;
                      numSL=0;
                      for k=1:2
                          numSL=numSL+numSL_bin(k)*2^(2-k);
                      end
                      numSL=numSL+2;
                   end
                %嵌入
               for i=2:bs
                  if blocki_bin(i,LM1(t)+1)==1  %SG组
                      if  i==indexSG(1)
                           continue;
                      else 
                          if LM1(t)~=0  %1、2
                             for k=1:LM1(t)
                                count_cap=count_cap+1;
                                blocki_bin(i,k)=capacity(count_cap);
                             end 
                             if numSG==0
                                continue;
                             else
                                 for k=LM1(t)+2:LM1(t)+numSG
                                    count_cap=count_cap+1;
                                    blocki_bin(i,k)=capacity(count_cap);
                                 end 
                             end
                         else
                             if numSG==0
                                 continue;
                             else
                                  for k=LM1(t)+2:LM1(t)+numSG
                                    count_cap=count_cap+1;
                                    blocki_bin(i,k)=capacity(count_cap);
                                  end
                              end 
                          end
                      end 
                  else%SL组
                       if  i==indexSL(1)
                           continue;
                       else 
                            if LM1(t)~=0 %1、2
                                 for k=1:LM1(t)
                                    count_cap=count_cap+1;
                                    blocki_bin(i,k)=capacity(count_cap);
                                 end
                                 if numSL==0
                                    continue;
                                 else
                                     for k=LM1(t)+2:LM1(t)+numSL
                                        count_cap=count_cap+1;
                                        blocki_bin(i,k)=capacity(count_cap);
                                     end
                                 end
                            else 
                                if numSL==0
                                    continue;
                                else
                                    for k=LM1(t)+2:LM1(t)+numSL
                                        count_cap=count_cap+1;
                                        blocki_bin(i,k)=capacity(count_cap);
                                    end
                                end
                            end
                       end
                  end
               end
             end
       end
       blocki=zeros(1,s*s);
       for i=1:s*s
            for k=1:8
                blocki(1,i)=blocki(1,i)+blocki_bin(i,k)*2^(8-k);
            end
       end
       MarkedIMage(t,:)= blocki;
       len_au=len_au+length(au{t});
end

pure_capacity=countdata-length(originalbit)-lenau00-15-8-15;
bpp=pure_capacity/512/512;


