function [Bn,Bg] = NonLinB(dNdX,F)

Bn=zeros(6,24);


D=dNdX';

for a=1:3 %DoF
    for b=1:8 %node
        col=(8*a)-(8-b);
        Bn(:,col)=[D(1,b)*F(a,1);D(2,b)*F(a,2);D(3,b)*F(a,3);
            D(1,b)*F(a,2)+D(2,b)*F(a,1);
            D(2,b)*F(a,3)+D(3,b)*F(a,2);
            D(1,b)*F(a,3)+D(3,b)*F(a,1)];
    end
end

Bg=zeros(9,24);
Bg(1:3,1:8)=dNdX';Bg(4:6,9:16)=dNdX';Bg(7:9,17:24)=dNdX';
end
