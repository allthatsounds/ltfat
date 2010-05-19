function c=comp_dgt(f,g,a,M,L)
%COMP_DGT  Compute a DGT
%   Usage:  c=comp_dgt(f,g,a,M,L);
%
%   Input parameters:
%         f     : Input data
%         g     : Window function.
%         a     : Length of time shift.
%         M     : Number of modulations.
%         L     : Length of transform to do.
%   Output parameters:
%         c     : M*N array of coefficients.
%

%   AUTHOR : Peter Soendergaard.
%   TESTING: OK
%   REFERENCE: OK

Lwindow=size(g,1);

W=size(f,2);
N=L/a;

if Lwindow<L
  % Do the filter bank algorithm
  % Periodic boundary conditions
  c=comp_dgt_fb(f,g,a,M,0);

else
  % Do the factorization algorithm
  c=comp_dgt_long(f,g,a,M);

end;

c=reshape(c,M,N,W);