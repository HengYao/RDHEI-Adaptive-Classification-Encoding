%2-00\3-01\4-10\5678-11,It\Itpro指第i块,返回的Itpro是一位数组
%au存储的是上面的00，01编码
function [s2,EC,au,Itpro,num_SG,num_SL] = new2(It,numi)
%  It=[55 51 54 53 51;55 50 51 50 50;1 63 51 49 59;249 54 62 62 60;21 51 48 54 49];
% It=[73 77 74 73 70;110 110 111 104 103;106 107 101 105 104;107 107 99 107 107;107 109 97 106 110];
% It=[224 223 220;221 226 220;225 225 222];
% [numi] = num_generation(It,5);
% numi_bin=bitget(numi,3:-1:1);
w=size(It,1)*size(It,2);
It_bin=zeros(w,8);
counter=0;
for i=1:size(It,1)
    for j=1:size(It,2)
        counter=counter+1;
        It_bin(counter,:)=bitget(It(i,j),8:-1:1);
    end
end

I2t_bin=zeros(w,8-numi);
for i=1:w
    I2t_bin(i,:)=It_bin(i,numi+1:8);
end

I2t=zeros(1,w);
for i=1:w
    for k=1:8-numi
        I2t(1,i)=I2t(1,i)+I2t_bin(i,k)*2^(8-numi-k);
    end
end

p1=[];%记录十进制数大于2^(8-numi-1)
p2=[];%记录十进制数小于2^(8-numi-1)
counter1=0;
counter2=0;
index1=[];index2=[];%记录索引，位置
for i=1:w
    if I2t(1,i)>=2^(8-numi-1)
        counter1=counter1+1;
        p1(counter1)=I2t(1,i);
        index1(counter1)=i;
    else
        counter2=counter2+1;
        p2(counter2)=I2t(1,i);
        index2(counter2)=i;
    end
end

%s2指示是否使用了新的压缩方式
%(SG,SL)
Itpro_bin=It_bin;
au=[];
counter=0;
if counter1<3 %(SG,SL)(1,8)(2,7)
    num_SG=0;
    [num_SL]=num22_generation(p2,counter2,numi);
%     numSL_bin=bitget(num_SL,3:-1:1);
    if num_SL<2
        s2=0;
        for i=1:counter2
            Itpro_bin(index2(i),:)=It_bin(index2(i),:);%SG组不做处理SL也不做处理
        end
        len_SL=0;
        len_SG=0;
    else%SG组不做处理 SL做处理
        s2=1;
        counter=0;
        if num_SL==2%2-00
           counter=counter+1;
           au(counter)=0;
           counter=counter+1;
           au(counter)=0;
        elseif num_SL==3
           counter=counter+1;
           au(counter)=0;
           counter=counter+1;
           au(counter)=1; 
        elseif num_SL==4
           counter=counter+1;
           au(counter)=1;
           counter=counter+1;
           au(counter)=0;
        else
           num_SL=5;
           counter=counter+1;
           au(counter)=1;
           counter=counter+1;
           au(counter)=1;
        end
        len_SG=0;
        len_SL=(counter2-1)*(num_SL-1);
    end
    
elseif counter2<3 %(7,2)(8,1)
    num_SL=0;
    [num_SG]=num22_generation(p1,counter1,numi);
%     numSG_bin=bitget(num_SG,3:-1:1);
    if num_SG<2
        s2=0;
        for i=1:counter2
            Itpro_bin(index1(i),:)=It_bin(index1(i),:);%SG组不做处理SL也不做处理
        end
        len_SL=0;
        len_SG=0;
    else%Sl组不做处理 SG做处理
        s2=1;
        counter=0;
        if num_SG==2%2-00
           counter=counter+1;
           au(counter)=0;
           
           counter=counter+1;
           au(counter)=0;
           
        elseif num_SG==3
           counter=counter+1;
           au(counter)=0;
           
           counter=counter+1;
           au(counter)=1;
           
        elseif num_SG==4
           counter=counter+1;
           au(counter)=1;
           
           counter=counter+1;
           au(counter)=0;
           
        else
           num_SG=5;
           counter=counter+1;
           au(counter)=1;
           
           counter=counter+1;
           au(counter)=1;

        end
        len_SL=0;
        len_SG=(counter1-1)*(num_SG-1);
    end

else%(3,6)(4,5)(5,4)(6,3)
    [num_SG]=num22_generation(p1,counter1,numi);
    if num_SG>4
        num_SG=5;       
    end
    len_SG=(counter1-1)*(num_SG-1);

    [num_SL]=num22_generation(p2,counter2,numi);
    if num_SL>4
        num_SL=5;
    end
    len_SL=(counter2-1)*(num_SL-1);
    %若只要有一组num=1，为了保持可逆性，当前块就视为不可嵌入
    if len_SG+len_SL>4 && num_SG~=1 && num_SL~=1
        s2=1;
        counter=0;
        numSG_bin=bitget(num_SG-2,2:-1:1);
        numSL_bin=bitget(num_SL-2,2:-1:1);
       for i=1:2
           counter=counter+1;
           au(counter)=numSG_bin(i);
       end
       for i=3:4
           counter=counter+1;
           au(counter)=numSL_bin(i-2);
       end

    else 
        s2=0;
        len_SL=0;
        len_SG=0;
    end
end
% counter=counter+1;%%%%
% au(counter)=s2;
EC=len_SL+len_SG;
Itpro=zeros(1,w);
for i=1:w
    for k=1:8
        Itpro(1,i)=Itpro(1,i)+Itpro_bin(i,k)*2^(8-k);
    end
end

