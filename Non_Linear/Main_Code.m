
addpath('Core', 'Mesh', 'Non_Linear')

close all
clear

dir=3;

constants.Es=10e7;%200e9; %fibre axial stiffness
constants.G= 1e6; %shear modulus
constants.G0=constants.G*0.1;%3e5;   % consolidation to rigid load
constants.K=1e6; %bulk modulus
constants.Vf0=0.3; %initial fibre volume fraction
constants.Vfa=0.75; %maximum fibre volume fraction
constants.As=0.8e6; %Spring constant
constants.E0=[1,0,0]';
constants.N0=[0,0,0]'; constants.N0(dir)=1;
constants.NSHR=3;
constants.nu=0.4; % Poisson's Ratio

eps=1e-6;


d = linspace(0,0.2,50);

    fileID = fopen('Results/dfdu.txt','w');
    fprintf(fileID,'\r\n\r\n');
    fclose(fileID);

%% Set Up Mesh %%


filename = 'hexa_cube_2x2.msh';
% filename = 'singleElement.msh';

msh = readMesh(filename,'HEXAS');

msh = defineIPs(msh);

[msh.N,msh.dN] = ShapeFunctions(msh);

vindx_j = repmat(1:msh.nedof,msh.nedof,1); vindx_i = vindx_j';
sindx_j = repmat(1:msh.enode,msh.enode,1); sindx_i = sindx_j';


Kindx.i = msh.e2g(:,vindx_i(:)); Kindx.j = msh.e2g(:,vindx_j(:));
Hindx.i = msh.se2g(:,sindx_i(:)); Hindx.j = msh.se2g(:,sindx_j(:));

limits=zeros(2,3); %find outer dimensions of mesh
limits(1,:)=max(msh.coords,[],1);
limits(2,:)=min(msh.coords,[],1);

msh.x1 = find(msh.coords(:,1) < limits(2,1) + 1e-6);
msh.x2 = find(msh.coords(:,1) > limits(1,1) - 1e-6);

msh.y1 = find(msh.coords(:,2) < limits(2,2) + 1e-6);
msh.y2 = find(msh.coords(:,2) > limits(1,2) - 1e-6);

msh.z1 = find(msh.coords(:,3) < limits(2,3) + 1e-6);
msh.z2 = find(msh.coords(:,3) > limits(1,3) - 1e-6);

msh.f_face = find(msh.coords(:,dir) < limits(2,dir) + 1e-6);
msh.l_face = find(msh.coords(:,dir) > limits(1,dir) - 1e-6);


msh.stack=[0;90];

E0=BuildE0 (constants,msh,dir);

%%


u = zeros(msh.nnode,3);



val=msh.nnode*(dir-1);

maxcheck=200;

%%

% Boundary Conditions

% bnd_node = vertcat(msh.x1,msh.y1,msh.z1,msh.l_face);
% bnd_dof = vertcat(ones(length(msh.x1) ,1) ,2*ones(length(msh.y1) ,1) ,3*ones(length(msh.z1) ,1), dir*ones(length(msh.l_face) ,1));

bnd_node = vertcat(msh.f_face,msh.f_face,msh.f_face,msh.l_face);
bnd_dof = vertcat(ones(length(msh.f_face) ,1) ,2*ones(length(msh.f_face) ,1) ,3*ones(length(msh.f_face) ,1), dir*ones(length(msh.l_face) ,1));



%%

for i = 1 : length(d)
    

    
    
    Vf=(constants.Vf0*limits(1,dir))/(limits(1,dir)-d(i)); %current fibre volume
    
    if Vf>constants.Vfa
        error('Fibre-bed over compressed');
    end
    
    f_ap = zeros(3*msh.nnode,1);
    
    bnd_val=vertcat(zeros(3*length(msh.f_face) ,1), -d(i)*ones(length(msh.l_face) ,1)); %only for cubes!!!!!!
    
    
    for loop = 1 : length(bnd_node) % for each force boundary conditions
        
        u(bnd_node(loop),bnd_dof(loop)) = bnd_val(loop);  % Assign value to correct row.
        
    end
    
    %
    
    u0=reshape(u,3*msh.nnode,1);
    
    %%
    
    ApplyBound = @(u,K)Boundary(u,K,bnd_node,bnd_dof,bnd_val,msh);
    
    %% Newton %%
    
    check=0;
    r=ones(3*msh.nnode,1);
    r1=r;
    
    
    
    while check<maxcheck %sqrt(norm(r,2)^2)>1e-3
        
        
        check=check+1;
        
        r2=r1;
        r1=r;

        
        %% Stiffness Matrix %%
        
        
        FindK=@(u)ProcessK(u,msh,constants,Kindx,E0);
        
        K=FindK(u0);
        
        
        %% Boundary Conditions %%
        
        [f_ap,K]=ApplyBound(f_ap,K);
        
        
        
        
        %% Iterative Calculation %%
        
        r=f_ap-K*u0;
        
        if norm(r)<1e-6
            break
        end
        
        dif = K \ r;
        
        u0 = u0 + dif;
        
    end
    
    %% Find Force %%
    
            f = zeros(3*msh.nnode,1);
        
        for ie = 1 : msh.nelem
            
            l2g = msh.e2g(ie,:)'; % mapping
            e2g=msh.e2g(ie,1:8)';
            
            u_loc=zeros(8,3);
            u_loc(:,1)=u0(msh.e2g(ie,1:msh.enode));
            u_loc(:,2)=u0(msh.e2g(ie,1:msh.enode)+msh.nnode);
            u_loc(:,3)=u0(msh.e2g(ie,1:msh.enode)+2*msh.nnode);
            
            [fe,~,~] = NonLinForce(msh,msh.coords(msh.elements{ie}.connectivity,:),constants,u_loc,E0(:,ie));
            
            %
            
            f(l2g,1)=f(l2g,1)+fe;

            
        end
    
    
    
    
    %% Test K %%
    
    dfdu=zeros(3*msh.nnode,3*msh.nnode);
    
    f_eps=zeros(3*msh.nnode,3*msh.nnode);
    
    for loop=1:3*msh.nnode
        
        
        
        u_eps=u0;
        u_eps(loop)=u0(loop)+eps;
        
        
        
        for ie = 1 : msh.nelem
            
            u_loc=zeros(8,3);
            u_loc(:,1)=u_eps(msh.e2g(ie,1:msh.enode));
            u_loc(:,2)=u_eps(msh.e2g(ie,1:msh.enode)+msh.nnode);
            u_loc(:,3)=u_eps(msh.e2g(ie,1:msh.enode)+2*msh.nnode);

            l2g = msh.e2g(ie,:)'; % mapping
            
            [fet,~,~] = NonLinForce(msh,msh.coords(msh.elements{ie}.connectivity,:),constants,u_loc,E0(:,ie));
            f_eps(l2g,loop)=f_eps(l2g,loop)+fet;
            %
            %
            
        end
        
        
    end
    
    
    
    for j=1:3*msh.nnode
        for k=1:3*msh.nnode
            
            dfdu(k,j)=(f_eps(k,j)-f(k))/eps;
        end
    end

    Ktemp=FindK(u0);
    
    diff=Ktemp-dfdu;
    
    figure(2)
    hold on
    
    xlabel('Displacement')
    ylabel('Force')
    plot(d(i),max(max(abs(f))),'*b');
    plot(d(i),max(max(abs(f_eps))),'or');
    
    figure(3)
    hold on
    
    xlabel('Displacement')
    ylabel('Norm Values')
    plot(d(i),norm(diff),'*g');
    plot(d(i),norm(dfdu),'*r');
    plot(d(i),norm(full(Ktemp)),'*b');

    
    
    fileID = fopen('Results/dfdu.txt','a');
    fprintf(fileID,'\r\nLoop %3d \r\n\r\n',i);
    
    fprintf(fileID,'\r\nMax Force %3d \r\n\r\n',max(max(abs(f))));
    
    fprintf(fileID,'\r\nMax F Epsilon %3d \r\n\r\n',max(max(abs(f_eps))));
    
    fprintf(fileID,'\r\nMax Difference in K %3d \r\n\r\n',max(max(diff)));
    
    fprintf(fileID,'\r\n\r\n');
    
    fclose(fileID);
    
    %% Reshape u %%
    
    u=reshape(u0,msh.nnode,3);

    
    
    %% Output Data %%
    %
    %     figure(8)
    %     hold on
    %
    %     xlabel('Displacement')
    %     ylabel('Force')
    %     plot(d(i),f(55),'ob');%bottom face
    %     plot(d(i),f(71),'og');%midplane
    %     plot(d(i),f(59),'or');%top face
    %     plot(d(i),f(80),'ok');%midpoint top
    %     legend({'Bottom Corner','Midplane Corner','Top Corner','Top Midpoint'},'Location','southwest')
    %
    
    %
    %     msh.connectivity = msh.e2g(:,1:8);
    %
    %     vector.name = 'Displacements';
    %     vector.data=u;
    %
    %     matlab2vtk (strcat('Results/','Nonlinfibre_a_', date, '_', int2str(i),'.vtk'),'NonLinear', msh, 'hex',[], vector, [],length(msh.coords(1,:)));
    
end





