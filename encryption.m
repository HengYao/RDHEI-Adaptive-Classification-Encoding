%encryption
function [Ie1,Ie2,Ie] = encryption(I,s)
% I=imread("Lena.bmp");
[m,n]=size(I);
I=double(I);
% s=4;
[Ie1]=encryption_block(I,s);
% [Iblock]=blockdivided(I,s,s);
ax=floor(m/s);ay=floor(n/s);
% I2=I;
% I2=I-I1;
rand('state',2020); key_stream=randi([0,255],[m,n]);
I_bin =zeros(m,n,8);
Ie_bin =zeros(m,n,8);
for i=1:m
    for j=1:n
        for k=1:8
            I_bin(i,j,k) =bitget(I(i,j), 9-k);
            b=bitget(key_stream(i,j),9-k);
            Ie_bin(i,j,k) = xor(I_bin(i,j,k),b);
        end
    end
end

Ie=zeros(m,n);
for i=1:m
    for j=1:n
        for k=1:8
           Ie(i,j)=Ie(i,j)+Ie_bin(i,j,k)*2^(8-k);
        end
    end
end
Ie2=Ie;

Ie(1:s*ax,1:s*ay)=Ie1;

