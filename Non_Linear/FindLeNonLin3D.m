function Le = FindLeNonLin3D(coords,dN,N,nip,intpoints,u)


Le = zeros(24,8);

for ip = 1 : nip
    J	=	coords'*dN{ip};
    
        dNdX	=	dN{ip}*inv(J);
        
        F=u'*dNdX+eye(3);
    
%         B = zeros(6,24);
% 
% 		B(1,1:8) = dNdX(:,1); % e_11 = u_1,1
% 		B(2,9:16) = dNdX(:,2); % e_22 = u_2,2 
% 		B(3,17:24) = dNdX(:,3); % e_33 = u_3,3
% 
% 		B(4,9:16) = dNdX(:,3);	B(4,17:24) = dNdX(:,2);	% e_23 = u_2,3 + u_3,2
% 		B(5,1:8) = dNdX(:,3);	B(5,17:24) = dNdX(:,1);	% e_13 = u_1,3 + u_3,1
% 		B(6,1:8) = dNdX(:,2);	B(6,9:16) = dNdX(:,1);	% e_12 = u_1,2 + u_2,1

    [B,~]=NonLinB(dNdX,F);

    Le = Le + B'*[1;1;1;0;0;0]*N{ip}'*intpoints.wgts(ip)*det(J);

    

end

 Le = - Le;

end