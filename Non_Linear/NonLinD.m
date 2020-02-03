function [D,S_PIOLA,STRESS]=NonLinD(constants,DFGRD1,E0) %(constants,F)

% % Based on Amir Hosein Sakhaei's Fortran code (04/APRIL/2018)



QQ_TENSOR=zeros(3,3,3,3);
C_SPATIAL_TAU=zeros(3,3,3,3); C_PRIME=zeros(3,3,3,3);
STRESS=zeros(6,1);



%% Material properties


NSHR=constants.NSHR;

%     E0 :=> THE FIBER DIRECTIONS

%         E0=constants.E0;


%     N0 :=> UNIT VECTOR NORMAL TO THE PLANE OF THE UNDEFORMED SHEET

N0=constants.N0;


%     RELATED TO TRANSVERSLY HYPERELASTIC MODEL

EK = constants.K;
EG = constants.G;
EES = constants.Es;
PHI_0 = constants.Vf0;
PHI_A = constants.Vfa;%  MAXIMUM POSSIBLE FIBER VOLUME FRACTION
A_S = constants.As;%   THE SPRING CONSTANT
EG_0 = constants.G0;%  A SMALL PORTION OF EG


AIDENT=eye(3);

E0_E0=E0*E0';

N0_N0=N0*N0';



%  ***********************************
%%     BEGIN MAIN LOOP COMPUTATION
%  ***********************************

%% INITIALIZE DEFORMATION GRADIENT

%     DEFORMATION GRADIENT AT CURRENT TIME

          F_TAU = DFGRD1;
% F_TAU(1,1) = DFGRD1(1,1);
% F_TAU(2,2) = DFGRD1(2,2);
% F_TAU(3,3) = DFGRD1(3,3);
% F_TAU(1,2) = DFGRD1(1,2);


if NSHR==1
    
    F_TAU(2,3) = 0;
    F_TAU(3,1) = 0;
    F_TAU(2,1) = DFGRD1(2,1);
    F_TAU(3,2) = 0;
    F_TAU(1,3) = 0;
    
else
    
    F_TAU(2,3) = DFGRD1(2,3);
    F_TAU(3,1) = DFGRD1(3,1);
    F_TAU(2,1) = DFGRD1(2,1);
    F_TAU(3,2) = DFGRD1(3,2);
    F_TAU(1,3) = DFGRD1(1,3);
    
end
%
%     DEFORMATION GRADIENT AT PREVIOUS TIME
%
%           F_T(1,1) = DFGRD0(1,1);
%           F_T(2,2) = DFGRD0(2,2);
%           F_T(3,3) = DFGRD0(3,3);
%           F_T(1,2) = DFGRD0(1,2);
% %

%         if NSHR == 1
%
% 			F_T(2,3) = 0;
% 			F_T(3,1) = 0;
% 			F_T(2,1) = DFGRD0(2,1);
% 			F_T(3,2) = 0;
% 			F_T(1,3) = 0;
%
%         else
%
% 			F_T(2,3) = DFGRD0(2,3);
% 			F_T(3,1) = DFGRD0(3,1);
% 			F_T(2,1) = DFGRD0(2,1);
% 			F_T(3,2) = DFGRD0(3,2);
% 			F_T(1,3) = DFGRD0(1,3);
%
%         end
%

%% CALCULATE MATRIX C



C=F_TAU'*F_TAU;

C_INV=inv(C); %Z3=det(C);


%%     CALCULATE DEFORMATION INVARIENTS: I1,I3 OR J, L_INVAR , LAPLAS_INVAR


I1_INVAR = C(1,1) + C(2,2) + C(3,3);

I3_INVAR=det(C);

J_INVAR = sqrt(I3_INVAR);

L1 = E0'*C*E0;

L2 = N0'*C_INV*N0;



%%     CALCULATE DERIVATIVE OF INVARIENTS WITH RESPECT TO C

DI1DC=AIDENT;

DI3DC=I3_INVAR*C_INV;
%
DJDC=0.5*J_INVAR*C_INV;

DLDC=E0_E0;

DW0DLAPLAS = (A_S/2)*((L2-sqrt(L2))/((1/PHI_0 - sqrt(L2)/PHI_A)^4) ) + ((EG-EG_0)/2)*(1/(L2^2) - 1/L2);

D2W0DLAPLAS2 = (A_S/2)*(( (1-0.5/sqrt(L2))*(1/PHI_0 - sqrt(L2)/PHI_A) - (2/PHI_A)*(sqrt(L2)-1) )/   ( (1/PHI_0 - sqrt(L2)/PHI_A)^5 ) ) + 0.5*(EG-EG_0)*( -2/(L2^3) + 1/(L2^2) )  ;



DLAPLASDC=zeros(3,3);

for k=1:3
    for l=1:3
        for i=1:3
            for j=1:3
                DLAPLASDC(k,l)=DLAPLASDC(k,l)-(N0(i,1)*N0(j,1)*(C_INV(i,k)*C_INV(l,j)));
            end
        end
    end
end



E_VEC = (E0'*F_TAU'/(sqrt(L1)))';



%%     CALCULATE N_VEC = N0*F_INV/sqrt(LAPLAS_INVAR)


%     N0 :=> UNIT VECTOR NORMAL TO THE PLANE OF THE UNDEFORMED SHEET


F_TAU_INV=inv(F_TAU);

N_VEC = (N0'*F_TAU_INV /sqrt(L2))';




%%     CALCULATE THE SECOND PIOLA-KIRCHHOF STRESS: S



S_PIOLA = 2*DW0DLAPLAS*DLAPLASDC + 0.5*EES*PHI_0*(1 - 1/L1)*E0_E0 +EG*(AIDENT-C_INV) + EK*log(J_INVAR)*C_INV;



%%      CACLULATE SIGMA_CAUCHY(I,J) := (1/J)F*S_PIOLA*F_TRANS


SIGMA_CAUCHY =(1/J_INVAR)*F_TAU*S_PIOLA*F_TAU'; %(see Kim ch3, 41)





%%     CALCULATE THE "SPATIAL" ELASTICITY TENSOR ::  C_SPATIAL_TAU


for I = 1:3
    for J = 1:3
        for K = 1:3
            for L = 1:3
                QQ_TENSOR(I,J,K,L) = N_VEC(I,1)*N_VEC(K,1)*AIDENT(J,L) + ...
                    N_VEC(I,1)*N_VEC(L,1)*AIDENT(J,K) + N_VEC(J,1)*N_VEC(K,1)*AIDENT(I,L) ...
                    + N_VEC(J,1)*N_VEC(L,1)*AIDENT(I,K) ; %Li & Tucker appendix
            end
        end
    end
end



for I = 1:3
    for J = 1:3
        for K = 1:3
            for L = 1:3
                C_SPATIAL_TAU(I,J,K,L) = 4*D2W0DLAPLAS2*(L2^2)*(1/J_INVAR)*...
                    N_VEC(I,1)*N_VEC(J,1)*N_VEC(K,1)*N_VEC(L,1) + 2*DW0DLAPLAS*L2*(1/J_INVAR)*...
                    QQ_TENSOR(I,J,K,L) + EES*PHI_0*(L1^2)*(1/J_INVAR)* ...
                    E_VEC(I,1)*E_VEC(J,1)* E_VEC(K,1)*E_VEC(L,1) +...
                    EK*(1/J_INVAR)*AIDENT(I,J)*AIDENT(K,L) +...
                    ( EG - EK*log(J_INVAR) )*(1/J_INVAR)* ...
                    ( AIDENT(I,K)*AIDENT(J,L) + AIDENT(I,L)*AIDENT(J,K) ); %Li & Tucker appendix Eq. 53
            end
        end
    end
end




%%     CALCULATE THE "ABAQUS" ELASTICITY TENSOR : C_ABAQUS(I,J,K,L) = C_SPATIAL_TAU(I,J,K,L)+C_PRIME(I,J,K,L)



%         CALCULATE C_PRIME(I,J,K,L)



for I = 1:3
    for J = 1:3
        for K = 1:3
            for L = 1:3
                C_PRIME(I,J,K,L) = 0.5*(AIDENT(I,K)*SIGMA_CAUCHY(J,L)+ ...
                    AIDENT(I,L)*SIGMA_CAUCHY(J,K)+AIDENT(J,K)*...
                    SIGMA_CAUCHY(I,L)+ AIDENT(J,L)*SIGMA_CAUCHY(I,K) );
            end
        end
    end
end


%         CACLULATE C_ABAQUS(I,J,K,L) = C_SPATIAL_TAU(I,J,K,L)+C_PRIME(I,J,K,L)




C_ABAQUS = C_SPATIAL_TAU + C_PRIME;


%*****************************
%%	      Update the stress and state variables
%*****************************



%%     UPDATE THE STRESS TENSOR : SIGMA_CAUCHY(I,J)  --> STRESS(NTENS)




STRESS(1) = SIGMA_CAUCHY(1,1);
STRESS(2) = SIGMA_CAUCHY(2,2);
STRESS(3) = SIGMA_CAUCHY(3,3);
STRESS(4) = SIGMA_CAUCHY(1,2);
STRESS(5) = SIGMA_CAUCHY(2,3);
STRESS(6) = SIGMA_CAUCHY(3,1);


%%    UPDATE THE STIFFNESS TENSOR : C_ABAQUS(I,J,K,L)  --> DDSDDE(NTENS,NTENS)


DDSDDE = zeros(6,6);

DDSDDE(1,1) = C_ABAQUS(1,1,1,1);
DDSDDE(1,2) = C_ABAQUS(1,1,2,2);
DDSDDE(1,3) = C_ABAQUS(1,1,3,3);
DDSDDE(1,4) = C_ABAQUS(1,1,1,2);
DDSDDE(1,5) = C_ABAQUS(1,1,2,3);
DDSDDE(1,6) = C_ABAQUS(1,1,3,1);

DDSDDE(2,1) = C_ABAQUS(2,2,1,1);
DDSDDE(2,2) = C_ABAQUS(2,2,2,2);
DDSDDE(2,3) = C_ABAQUS(2,2,3,3);
DDSDDE(2,4) = C_ABAQUS(2,2,1,2);
DDSDDE(2,5) = C_ABAQUS(2,2,2,3);
DDSDDE(2,6) = C_ABAQUS(2,2,3,1);

DDSDDE(3,1) = C_ABAQUS(3,3,1,1);
DDSDDE(3,2) = C_ABAQUS(3,3,2,2);
DDSDDE(3,3) = C_ABAQUS(3,3,3,3);
DDSDDE(3,4) = C_ABAQUS(3,3,1,2);
DDSDDE(3,5) = C_ABAQUS(3,3,2,3);
DDSDDE(3,6) = C_ABAQUS(3,3,3,1);

DDSDDE(4,1) = C_ABAQUS(1,2,1,1);
DDSDDE(4,2) = C_ABAQUS(1,2,2,2);
DDSDDE(4,3) = C_ABAQUS(1,2,3,3);
DDSDDE(4,4) = C_ABAQUS(1,2,1,2);
DDSDDE(4,5) = C_ABAQUS(1,2,2,3);
DDSDDE(4,6) = C_ABAQUS(1,2,3,1);

DDSDDE(5,1) = C_ABAQUS(2,3,1,1);
DDSDDE(5,2) = C_ABAQUS(2,3,2,2);
DDSDDE(5,3) = C_ABAQUS(2,3,3,3);
DDSDDE(5,4) = C_ABAQUS(2,3,1,2);
DDSDDE(5,5) = C_ABAQUS(2,3,2,3);
DDSDDE(5,6) = C_ABAQUS(2,3,3,1);

DDSDDE(6,1) = C_ABAQUS(3,1,1,1);
DDSDDE(6,2) = C_ABAQUS(3,1,2,2);
DDSDDE(6,3) = C_ABAQUS(3,1,3,3);
DDSDDE(6,4) = C_ABAQUS(3,1,1,2);
DDSDDE(6,5) = C_ABAQUS(3,1,2,3);
DDSDDE(6,6) = C_ABAQUS(3,1,3,1);

D=DDSDDE;

end



