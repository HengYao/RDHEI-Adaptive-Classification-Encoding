% classification
function [numi] = num_generation(block,Block_s)
min=block(1,1);
max=block(1,1);
f=0;
numi=0;
%% 找块中最大值、最小值
for i=1:Block_s
   for j=1:Block_s
        %找块中最小值
        if block(i,j)<min
            min=block(i,j);
        end
        %找块中最大值
         if block(i,j)>max
            max=block(i,j);
        end
   end
end

%% 求numi
min_bin=bitget(min,8:-1:1);
max_bin=bitget(max,8:-1:1);

for k=1:8
    if min_bin(k)~=max_bin(k)
       f=k;
       numi=f-1;
       break;
    else
       numi=numi+1;
    end
end




