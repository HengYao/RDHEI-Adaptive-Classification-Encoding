function [Iblock]=blockdivided(Ie,size1,size2)
%设置分块大小 
% size1=2; size2=2;
% 统计分块的数量
[m,n]=size(Ie); row=floor(m*n/size1/size2); cloumn=size1*size2;
% 对图片进行分块
Iblock=zeros(row,cloumn);
counter=0;
for b=1:m/size1
    for c=1:n/size2
        counter=counter+1;
        for d=1:size1
            Iblock(counter,size2*(d-1)+1:size2*d)=Ie(size1*(b-1)+d,size2*(c-1)+1:size2*c);
        end
    end
end
end