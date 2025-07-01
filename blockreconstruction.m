function [Ie]=blockreconstruction(Iblockshape_enc,m,n,s)
size1=s; size2=s;
counter=0;
%对分块进行重组
for b=1:m/size1
    for c=1:n/size2
        counter=counter+1;
        for d=1:size1
            Ie(size1*(b-1)+d,size2*(c-1)+1:size2*c)=Iblockshape_enc(counter,size2*(d-1)+1:size2*d);
        end
    end
end
end