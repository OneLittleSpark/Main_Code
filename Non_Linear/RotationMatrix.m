function El=RotationMatrix(constants,dir,theta)

R=eye(3);

if dir==1
    
    R(2,2)=cosd(theta);R(2,3)=-sind(theta);
    R(3,2)=sind(theta);R(3,3)=cosd(theta);
    
elseif dir==2
    
    R(1,1)=cosd(theta);R(1,3)=sind(theta);
    R(3,1)=-sind(theta);R(3,3)=cosd(theta);
    
else
    
    R(1,1)=cosd(theta);R(1,2)=-sind(theta);
    R(2,1)=sind(theta);R(2,2)=cosd(theta);
    
end

El=R*constants.E0;

end

%E0=RotationMatrix(constants,dir,theta(ie))
