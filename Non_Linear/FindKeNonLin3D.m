function [Ke] = FindKeNonLin3D(coords,dN,nip,intpoints,u,constants,E0)


Ke = zeros(24);
D=zeros(6);


%%

for ip=1:nip
    
    J	=	coords'*dN{ip};
    dNdX	=	dN{ip}*inv(J); %#ok<MINV> dNdX(1,2) = dN1 / dy
    
    F=u'*dNdX+eye(3);
    
    
    [De,~,~]=NonLinD(constants,F,E0); %Amir's original D
 
    
    D=D+De*intpoints.wgts(ip)*det(J);

    
end

for ip = 1 : nip

    J	=	coords'*dN{ip};
    dNdX	=	dN{ip}*inv(J); %#ok<MINV> dNdX(1,2) = dN1 / dy
    
    F=u'*dNdX+eye(3);

    
    

     [Bn,~]=NonLinB(dNdX,F);


    Ke = Ke + (Bn'*D*Bn)*intpoints.wgts(ip)*det(J);

end	% for each ip


%%
Ke = 0.5*(Ke + Ke');

if sum(sum(abs(Ke-Ke'))) > 1e-12
    error('Element Stiffness Matrix Not Symmetric');
end


Ke = Ke(:); % Convert to a column vector


end


