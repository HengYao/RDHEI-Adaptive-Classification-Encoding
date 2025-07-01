function [recover_img,data] = recovery(Iemarked,Ie,s)

Markedimage=blockdivided(Iemarked,s,s);
w=size(Markedimage,1);
LM1=zeros(1,w);EC=zeros(1,w);

%先提取哈夫曼表3+3+码字
Huff_rule=[];
countrule=0;
blocki=Markedimage(1,:);
blocki_bin=zeros(s*s,8);
counter=0;
for i=1:s*s
    counter=counter+1;
    blocki_bin(counter,:)=bitget(blocki(i),8:-1:1); 
end

len_dict_bin=[blocki_bin(1,:)];
len_dict=8;%记录哈夫曼表长使用8bit记录，要把这部分加上。
for i=1:8 %提取哈夫曼表有多长
    len_dict=len_dict+len_dict_bin(i)*2^(8-i);
end
%提取dict哈夫曼rule
W1=ceil((9+len_dict)/(s*s*8));
dd=[];%中间变量
for t=1:W1
    blocki=Markedimage(t,:);
    blocki_bin=zeros(s*s,8);
    counter=0;
    for i=1:s*s
        counter=counter+1;
        blocki_bin(counter,:)=bitget(blocki(i),8:-1:1); 
    end

         for i=1:s*s
              for k=1:8
                   countrule=countrule+1;
                   if countrule<=len_dict
                        Huff_rule(countrule)=blocki_bin(i,k);%被替换的bit存储到original bit中
                   else 
                       break;
                   end
                  
              end
              if countrule>len_dict
                  break;
              end
        
         end

end
Huff_rule=Huff_rule(9:len_dict);
%表 
dict={};
countdict=0;
countrule=0;
while countrule<len_dict-8

    dd=[];
     countdd=0;
     leni=0;
     for i=1:3
         countrule=countrule+1;

         leni=leni+Huff_rule(countrule)*2^(3-i);
     end
     if countrule>len_dict
             break;
     end
     leni=leni+1;
     md=0; 
     for i=1:3
         countrule=countrule+1;
         md=md+Huff_rule(countrule)*2^(3-i);
     end
   
      for i=1:leni
         countrule=countrule+1;
         countdd=countdd+1;
         dd(countdd)=Huff_rule(countrule);
      end
      countdict=countdict+1;
      dict{1,countdict}=md;
      dict{2,countdict}=dd;

end
data=[];
countdata1=0;
counter00=0;%记录md=0且不可进一步压缩的块数量
%% 识别每个块的md
for t=107:size(Markedimage,1)
% for t=W1+1:size(Markedimage,1)
    blocki=Markedimage(t,:);
    blocki_bin=zeros(s*s,8);
    counter=0;
    for i=1:s*s
        counter=counter+1;
        blocki_bin(counter,:)=bitget(blocki(i),8:-1:1); 
    end
    dd=[];
    countdd=0;
    for i=1:size(dict,2)%识别当前块md具体值
        countdd=countdd+1;
        dd(countdd)=blocki_bin(countdd,8);
        for idx = 1:size(dict,2)
        % 检查尺寸是否一致
            if isequal(size(dd), size(dict{2,idx}))
                % 检查数值和数据类型是否完全一致
                if isequal(dd, dict{2,idx})
                  md=dict{1,idx};
                  break;
                end
            end
        end

        if isequal(dd, dict{2,idx})
            md=dict{1,idx};
        break;
        end

    end
    LM1(t)=md;
    countcap=0;
    %恢复块的原始信息
    if md>=3 
%         EC(t)=md*(s*s-1)-length(dd);
        EC(t)=md*(s*s-1);
        information=zeros(1,EC(t));
        countcap=0;
        for i=2:s*s
            for k=1:md
              countcap=countcap+1;
              information(countcap)=blocki_bin(i,k);
              blocki_bin(i,k)=blocki_bin(1,k);%恢复前md位
            end
        end
        len_au=length(dd);
    elseif md==0&&blocki_bin(length(dd)+1,8)==0
        EC(t)=0;
        counter00=counter00+1;
        continue;
    else %md=1，2可不可嵌，md=0可嵌
        if blocki_bin(length(dd)+1,8)==0 %md==1||md==2不可进一步嵌入
              EC(t)=md*(s*s-1);    
              len_au=length(dd)+1;
              information=zeros(1,EC(t));
              countcap=0;
              for i=2:s*s
                for k=1:md
                  countcap=countcap+1;
                  information(countcap)=blocki_bin(i,k);
                  blocki_bin(i,k)=blocki_bin(1,k);% 解压
                end
              end

       elseif  blocki_bin(length(dd)+1,8)==1%md==1||md==2||md=0可以进一步嵌入
              %判别num是只有一个还是有两个 
              countSG=0;countSL=0;
               indexSG=[];indexSL=[];
    
               for  i=1:9   %存储sg组的索引 存储sL组的索引
                   if blocki_bin(i,md+1)==1
                       countSG=countSG+1;
                       indexSG(countSG)=i;
                   else 
                       countSL=countSL+1;
                       indexSL(countSL)=i;
                   end
               end
               start=length(dd)+2;%SG\SL码字开始的索引
               %获得numSG、numSL具体数值
               if countSG<3
                  numSG=0;
                  len_au=length(dd)+1+2;
                  numSL_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                  numSL=0;
                  for k=1:2
                      numSL=numSL+numSL_bin(k)*2^(2-k);
                  end
                  numSL=numSL+2;
               elseif countSL<3
                   numSL=0;
                   len_au=length(dd)+1+2;
                   numSG_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                   numSG=0;
                   for k=1:2
                      numSG=numSG+numSG_bin(k)*2^(2-k);
                   end
                   numSG=numSG+2;

               else 
                   len_au=length(dd)+1+2+2;
                   if start+1>9
                        numSG_bin=[blocki_bin(start,8) blocki_bin(mod(start+1,9),7)];
                        numSL_bin=[blocki_bin(mod(start+2,9),7) blocki_bin(mod(start+3,9),7)];
                   elseif start+1==9
                        numSG_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                        numSL_bin=[blocki_bin(mod(start+2,9),7) blocki_bin(mod(start+3,9),7)];
                  elseif start+2==9 
                        numSG_bin=[blocki_bin(start,8) blocki_bin(start+1,8)];
                        numSL_bin=[blocki_bin(start+2,8) blocki_bin(mod(start+3,9),7)]; 
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

               if numSL~=0 && numSG~=0 
                    EC(t)=(numSG-1)*(length(indexSG)-1)+(numSL-1)*(length(indexSL)-1);
               elseif numSL==0 && numSG~=0
                    EC(t)=(numSG-1)*(length(indexSG)-1);
               elseif numSL~=0 && numSG==0
                    EC(t)=(numSL-1)*(length(indexSL)-1);
               end

               %嵌入
               for i=2:9
                  if blocki_bin(i,md+1)==1  %SG组
                      if  i==indexSG(1)
                          for k=1:md
                                countcap=countcap+1;
                                blocki_bin(i,k)=blocki_bin(1,k);
                          end  
                          continue;
                      else 
                          if md~=0  %1、2
                             for k=1:md
                                countcap=countcap+1;
                                information(countcap)=blocki_bin(i,k);
                                blocki_bin(i,k)=blocki_bin(1,k);
                             end 
                             if numSG==0
                                continue;
                             else
                                 for k=md+2:md+numSG
                                    countcap=countcap+1;
                                    information(countcap)=blocki_bin(i,k);
                                    blocki_bin(i,k)=blocki_bin(indexSG(1),k);
                                 end 
                             end
                         else
                             if numSG==0
                                 continue;
                             else
                                  for k=md+2:md+numSG
                                    countcap=countcap+1;
                                    information(countcap)=blocki_bin(i,k);
                                    blocki_bin(i,k)=blocki_bin(indexSG(1),k);
                                  end
                              end 
                          end
                      end 
                  else%SL组
                       if  i==indexSL(1)
                           for k=1:md
                                blocki_bin(i,k)=blocki_bin(1,k);
                           end 
                           continue;
                       else 
                            if md~=0 %1、2
                                 for k=1:md
                                    countcap=countcap+1;
                                    information(countcap)=blocki_bin(i,k);
                                    blocki_bin(i,k)=blocki_bin(1,k);%恢复
                                 end
                                 if numSL==0
                                    continue;
                                 else
                                     for k=md+2:md+numSL
                                        countcap=countcap+1;
                                        information(countcap)=blocki_bin(i,k);
                                        blocki_bin(i,k)=blocki_bin(indexSL(1),k);
                                     end
                                 end
                            else 
                                if numSL==0
                                    continue;
                                else
                                    for k=md+2:md+numSL
                                        countcap=countcap+1;
                                        information(countcap)=blocki_bin(i,k);
                                        blocki_bin(i,k)=blocki_bin(indexSL(1),k);
                                    end
                                end
                            end
                       end
                  end
               end
             end
    end
     au_block=information(1:len_au);
     for i=1:len_au
         if i<=s*s 
            blocki_bin(i,8)=au_block(i);
         else
             blocki_bin(mod(i,9),7)=au_block(i);
         end
     end
    a=EC(t)-length(au_block);
    countdata1=countdata1+1;
    data(countdata1:countdata1+a-1)=information(len_au+1:EC(t));
    countdata1=countdata1+a-1;
    blocki=zeros(1,s*s);      
    for i=1:s*s
        for k=1:8
            blocki(1,i)=blocki(1,i)+blocki_bin(i,k)*2^(8-k);
        end
    end
    MarkedIMage(t,:)= blocki;
end
%这里可以粗算一个数据提取时间

%% 恢复前面几个块的data
original_data=data(1:len_dict);
counterori=0;
for i=1:W1
    blocki=MarkedIMage(t,:);
    blocki_bin=zeros(s*s,8);
    counter=0;
    for i=1:s*s
        counter=counter+1;
        for k=1:8
            counterori=counterori+1;
            if counterori>len_dict
                break;
            else    
                blocki_bin(counter,k)=data(counterori);
            end
        end
        if counterori>len_dict
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

    
if s==3 || s==5
    [Iemarked]=blockreconstruction(MarkedIMage,510,510,s);
    ax=floor(512/3);ay=floor(512/3);
    Ie(1:3*ax,1:3*ay)=Iemarked;
    Iemarked=Ie;
    [recover_img] = decryption(Ie,s);
elseif s==4
    [Iemarked]=blockreconstruction(MarkedIMage,512,512,s);
    [recover_img] = decryption_block(Iemarked,s);
    
end








