function coef=spreadfun(T)
%SPREADFUN  Spreading function.
%   Usage:  c=spreadfun(T);
%
%   SPREADFUN(T) computes the spreading function of the operator T. The
%   spreading function represent the operator T as a weighted sum of
%   time-frequency shifts. See the help text for SPREADOP for the exact
%   definition.
%
%   See also:  spreadop, tconv, spreadinv, spreadadj


error(nargchk(1,1,nargin));

if ndims(T)>2 || size(T,1)~=size(T,2)
    error('Input symbol T must be a square matrix.');
end;

L=size(T,1);

% The 'full' appearing on the next line is to guard the mex file.
coef=comp_col2diag(full(T));

coef=fft(coef)/L;
