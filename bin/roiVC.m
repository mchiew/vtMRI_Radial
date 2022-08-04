function V = roiVC(z, mask_A, mask_B)

% Region-Optimised Virtual Coils from Kim et al., ISMRM 2021 #0064
%
% Input z is a 4D image [Nx,Ny,Nz,Nc]
% mask_A and mask_B are the signal and interference region masks [Nx,Ny,Nz]
%
% Output V is a [Nc,Nc] coil transform

nc      =   size(z,4);

A       =   reshape(z.*mask_A,[],nc)'*reshape(z.*mask_A,[],nc);
B       =   reshape(z.*mask_B,[],nc)'*reshape(z.*mask_B,[],nc);
[V,D]   =   eig(A,B);

[~,ii]  =   sort(diag(D),'descend');
V       =   V(:,ii);