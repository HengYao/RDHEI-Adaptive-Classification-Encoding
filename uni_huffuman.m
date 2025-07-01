%% 生成哈夫曼表抬头
%huff_len_and_rule输出：表头长度（8bit）+哈夫曼表
function [dict,huff_len_and_rule]=uni_huffuman(LM1)
c=tabulate(LM1);
p=c(:,3)/100;
N = length(p);

symbols = cell(1,N);
for i=1:N         % i表示第几个符号
    symbols{i} = [c(i,1)];
end
[dict,L_ave] = huffmandict(symbols,p);
dict = dict.';
H = sum(-p.*log2(p));% 计算信源信息熵
yita = H/L_ave;      % 计算编码效率

CODE = strings(1,N); % 初始化对应码字
for i=1:N            % i表示第几个符号
    CODE(i) = num2str(dict{2,i});
end

huff_rule=[];
counterrule=0;
% max_md=c(size(c,1),1);
% max_md_bin=bitget(max_md,3:-1:1);
% huff_rule(1:3)=max_md_bin;
% counterrule=3;
for  i=1:size(dict,2)
    amount0=length(dict{2,i});
    amount0_bin=bitget(amount0-1,3:-1:1);
    for j=1:3%多长
        counterrule=counterrule+1;
        huff_rule(counterrule)=amount0_bin(j);
    end   
    md=c(i,1);
    md_bin=bitget(md,3:-1:1);
    for j=1:3%嵌md
        counterrule=counterrule+1;
        huff_rule(counterrule)=md_bin(j);
    end


    for j=1:length(dict{2,i})%码字
      counterrule=counterrule+1;
      huff_rule(counterrule)=dict{2,i}(j);
    end
end

huff_len_and_rule=[];
huff_len=length(huff_rule);
huff_len_bin=bitget(huff_len,8:-1:1);
huff_len_and_rule=[huff_len_bin huff_rule];





