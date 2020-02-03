function [force,stresses,Btot] = NonLinForce(msh,coords,constants,u,E0)

force=zeros(24,1);
stresses=zeros(6,24);
Btot=zeros(6,24);

for ip = 1 : msh.nip
        
        
        
        % Compute F
        
        J	=	coords' * msh.dN{ip};
        dNdX	=	msh.dN{ip} * inv(J);
        
        F = u' * dNdX + eye(3);
        
        [~,S,~] = NonLinD(constants,F,E0);
        
        
        %%
        
        
        [Bn,~] = NonLinB(dNdX,F);
        
        Sv=[S(1,1);S(2,2);S(3,3);S(1,2);S(2,3);S(1,3)];
        
        Btot=Btot+Bn*det(J)*msh.ip.wgts(ip);
        
        force=force + Bn'*Sv*det(J)*msh.ip.wgts(ip);
        
        %%
        
        for loop=1:3
            
            loc=((loop-1)*msh.nip)+ip;
            
            stresses(loop,loc)=stresses(loop,loc)+Sv(loop);%*det(J)*msh.ip.wgts(ip);
            
        end
        
        stresses(4,ip)=Sv(4);stresses(4,ip+msh.nip)=Sv(4);
        stresses(5,ip+msh.nip)=Sv(5);stresses(5,ip+2*msh.nip)=Sv(5);
        stresses(6,ip)=Sv(6);stresses(6,ip+2*msh.nip)=Sv(6);
        
end



end