function [IMatrix] = SeqintoMatrix(Iseq)
[~,colume]=size(Iseq);
s=colume^(0.5);
IMatrix=zeros(s,s);
counter=0;
 for i=1:s
     for j=1:s
         counter=counter+1;
         IMatrix(i,j)=Iseq(1,counter);
     end
 end
