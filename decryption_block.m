%decryption
function [Ide] = decryption_block(Imarked,s)
% 设定分块大小
% Imarked=Iemarked;%%11
size1=s;size2=s;
% 统计分块的数量
[m,n]=size(Imarked); row=floor(m*n/s/s); cloumn=s*s;
% 对图片进行分块
I_temp=zeros(row,cloumn);
counter=0;
for b=1:floor(m/s)
    for c=1:floor(n/s)
        counter=counter+1;
        for d=1:s
            I_temp(counter,s*(d-1)+1:s*d)=Imarked(s*(b-1)+d,s*(c-1)+1:s*c);
        end
    end
end


% 重新生成相同的伪随机数流
rand('state', 2020);
key_stream = randi([0, 255], [row, 1]);

% 初始化解密后的图像数据
I_stream= zeros(size(I_temp));

% 解密过程
for i = 1:row
    for j = 1:8
        % 提取加密后图像的每个像素的每个位
        a = bitget(I_temp(i, :), j);
        
        % 提取相同位置上的密钥流的位
        b = bitget(key_stream(i), j);
        
        % 使用异或操作进行解密
        c = xor(a, b);
        
        % 将解密后的位设置回原图像
        I_stream(i, :) = bitset(I_stream(i, :), j, c);
    end
end
% 置乱解密过程
I_shape=zeros(row,cloumn);
for i = 1:row
    % 重新设置相同的伪随机数生成器种子
    rand('state', 50*i);
    
    % 生成相同的随机排列
    key_shape = randperm(size1 * size2);
    
    for j = 1:size1 * size2
        % 恢复原始顺序，将加密后的图像数据还原为原始图像
         I_shape(i, key_shape(j)) = I_temp(i, j);
    end
end

% I_decrypted 中存储了解密后的图像数据

% 将加密后图片的分块组合成加密图像
Ide=zeros(floor(m/s)*s,floor(n/s)*s);
counter=0;
for b=1:floor(m/s)
    for c=1:floor(n/s)
        counter=counter+1;
        for d=1:s
            Ide(s*(b-1)+d,s*(c-1)+1:s*c)=I_stream(counter,s*(d-1)+1:s*d);
        end
    end
end
end


