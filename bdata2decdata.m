function decdata= bdata2decdata(bindata)
len=length(bindata);
decdata=[];
a=[];
j=1;
for i=1:(len/8)
    a=bindata(j:j+7);
    a=num2str(a,'%d');
    data=bin2dec(a);
    decdata=[decdata data];
    j=j+8;
end
end