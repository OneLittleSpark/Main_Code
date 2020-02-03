function E0=BuildE0 (constants,msh,dir)


stack=msh.stack;
layer=zeros(msh.nelem,1);
E0=zeros(3,msh.nelem);

for ie=1:msh.nelem
    
    layer(ie)=msh.elements{ie}.region;
    
end

num=max(layer);

n=ceil(num/length(stack));

stack=repmat(stack,n,1);

for ie=1:msh.nelem

    theta=stack(layer(ie));
    
    E0(:,ie)=RotationMatrix(constants,dir,theta);
    
end
end