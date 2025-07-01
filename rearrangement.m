%rearrangement
function [Ire] = rearrangement(I,s,LM_num)

[m,n]=size(I);
w=floor(m/s)*floor(n/s);%图像一共分为多少块
[Ieblock]=blockdivided(I,s,s);
Ire=zeros(w,s*s);
Ire_012=zeros(w,s*s);
counter=0;counter2=0;
for i=1:w
    if LM_num(i)>=3
        counter=counter+1;
        Ire(counter,:)=Ieblock(i,:);%大于等于3的排在前面
    else
        counter2=counter2+1;
        Ire_012(counter2,:)=Ieblock(i,:);
    end
end
counter=counter+1;
Ire(counter:w,:)=Ire_012(1:counter2,:);







