function [numi] = num22_generation(Seq,len,num_block)
min=Seq(1);
max=Seq(1);
f=0;
numi=0;
%% 找块中最大值、最小值
for i=1:len
        %找块中最小值
        if Seq(i)<min 
            min=Seq(i);
        end
        %找块中最大值
         if Seq(i)>max
            max=Seq(i);
         end
end

%% 求numi
min_bin=bitget(min,8-num_block:-1:1);
max_bin=bitget(max,8-num_block:-1:1);

for k=1:8-num_block
    if min_bin(k)~=max_bin(k)
       f=k;
       numi=f-1;
       break;
    else
        numi=numi+1;
    end

    end
end







