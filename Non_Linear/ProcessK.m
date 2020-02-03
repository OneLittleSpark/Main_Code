function [K]=ProcessK(u,msh,constants,Kindx,E0)

Ke_all = zeros(msh.nedof^2,msh.nelem);

        for ie=1:msh.nelem
            
            
            u_loc=zeros(8,3);
            u_loc(:,1)=u(msh.e2g(ie,1:msh.enode));
            u_loc(:,2)=u(msh.e2g(ie,1:msh.enode)+msh.nnode);
            u_loc(:,3)=u(msh.e2g(ie,1:msh.enode)+2*msh.nnode);
%             
%             u_loc=zeros(8,3);
%             u_loc(:,1)=u(msh.e2g(ie,1:msh.enode));
%             u_loc(:,2)=u(msh.e2g(ie,1+msh.enode:2*msh.enode));
%             u_loc(:,3)=u(msh.e2g(ie,1+2*msh.enode:3*msh.enode));
%             
            
            [Ke_all(:,ie)] = FindKeNonLin3D(msh.coords(msh.se2g(ie,:),:),msh.dN,msh.nip,msh.ip,u_loc,constants,E0(:,ie));
            
        end
        
        K = sparse(Kindx.i',Kindx.j',Ke_all); K = 0.5 * (K + K');
        
end
        