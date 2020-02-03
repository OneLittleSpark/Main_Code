function [u,K]=Boundary(u,K,bnd_node,bnd_dof,bnd_val,msh)


    for i = 1 : length(bnd_node*3) % for each force boundary conditions
        
        if(bnd_dof(i) == 1) % if boundary conditions to u degree of freedom
            row = bnd_node(i);
        elseif (bnd_dof(i) == 2) % else if boundary conditions to v degree of freedom
            row = msh.nnode+bnd_node(i);
        else % else boundary conditions to w degree of freedom
            row = 2*msh.nnode+bnd_node(i);
        end
        
        K(row,:) = zeros(1,3*msh.nnode);
        K(row,row) = 1;
        u(row) = bnd_val(i);  % Assign value to correct row.
        
    end
    
end

