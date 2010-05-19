function [c,Ls]=dwilt(f,g,M,L)
%DWILT  Discrete Wilson transform.
%   Usage:  c=dwilt(f,g,M);
%           c=dwilt(f,g,M,L);
%           [c,Ls]=dwilt(f,g,M);
%           [c,Ls]=dwilt(f,g,M,L);
%
%   Input parameters:
%         f     : Input data
%         g     : Window function.
%         M     : Number of bands.
%         L     : Length of transform to do.
%   Output parameters:
%         c     : 2*M x N array of coefficients.
%         Ls    : Length of input signal.
%
%   DWILT(f,g,M) computes a discrete Wilson transform
%   with M bands and window g.
%
%   The length of the transform will be the smallest possible that is
%   larger than the signal. f will be zero-extended to the length of the 
%   transform. If f is a matrix, the transformation is applied to each column.
%
%   The window g may be a vector of numerical values, a text string or a
%   cell array. See the help of WILWIN for more detailts.
%
%   DWILT(f,g,M,L) computes the Wilson transform as above, but does
%   a transform of length L. f will be cut or zero-extended to length L before
%   the transform is done.
%
%   [c,Ls]=DWILT(f,g,M) or [c,Ls]=DWILT(f,g,M,L) additionally return the
%   length of the input signal f. This is handy for reconstruction:
%
%C               [c,Ls]=dwilt(f,g,M);
%C               fr=idwilt(c,gd,M,Ls);
%
%   will reconstruct the signal f no matter what the length of f is, provided
%   that _gd is a dual Wilson window of g.
%
%   A Wilson transform is also known as a maximally decimated, even-stacked
%   cosine modulated filter bank.
%
%   Use the function WIL2RECT to visualize the coefficients or to work
%   with the coefficients in the TF-plane.
%
%   Assume that the following code has been executed for a column vector f:
%
%C    c=dwilt(f,g,M);  % Compute a Wilson transform of f.
%C    N=size(c,2)*2;   % Number of translation coefficients.
%
%   The following holds for $m=0,...,M-1$ 
%   and $n=0,...,N/2-1$:
%
%   If $m=0$:
%
%M                   L-1 
%M    c(m+1,n+1)   = sum f(l+1)*g(l-2*n*M+1)
%M                   l=0  
%F  \begin{eqnarray*}
%F  c\left(1,n+1\right) & = & \sum_{l=0}^{L-1}f(l+1)g\left(l-2nM+1\right)
%F  \end{eqnarray*}
%
%   If $m$ is odd and less than M
%
%M                   L-1 
%M    c(m+1,n+1)   = sum f(l+1)*sqrt(2)*sin(pi*m/M*l)*g(k-2*n*M+1)
%M                   l=0  
%M
%M                   L-1 
%M    c(m+M+1,n+1) = sum f(l+1)*sqrt(2)*cos(pi*m/M*l)*g(k-(2*n+1)*M+1)
%M                   l=0  
%F  \begin{eqnarray*}
%F  c\left(m+1,n+1\right) & = & \sqrt{2}\sum_{l=0}^{L-1}f(l+1)\sin(\pi\frac{m}{M}l)g(l-2nM+1)\\
%F  c\left(m+M+1,n+1\right) & = & \sqrt{2}\sum_{l=0}^{L-1}f(l+1)\cos(\pi\frac{m}{M}l)g\left(l-\left(2n+1\right)M+1\right)\end{eqnarray*}
%
%   If $m$ is even and less than M
%
%M                   L-1 
%M    c(m+1,n+1)   = sum f(l+1)*sqrt(2)*cos(pi*m/M*l)*g(l-2*n*M+1)
%M                   l=0  
%M
%M                   L-1 
%M    c(m+M+1,n+1) = sum f(l+1)*sqrt(2)*sin(pi*m/M*l)*g(l-(2*n+1)*M+1)
%M                   l=0  
%F  \begin{eqnarray*}
%F  c\left(m+1,n+1\right) & = & \sqrt{2}\sum_{l=0}^{L-1}f(l+1)\cos(\pi\frac{m}{M}l)g(l-2nM+1)\\
%F  c\left(m+M+1,n+1\right) & = & \sqrt{2}\sum_{l=0}^{L-1}f(l+1)\sin(\pi\frac{m}{M}l)g\left(l-\left(2n+1\right)M+1\right)\end{eqnarray*}
%
%   if $m=M$ and M is even:
%
%M                   L-1 
%M    c(m+1,n+1)   = sum f(l+1)*(-1)^(l)*g(l-2*n*M+1)
%M                   l=0
%F  \begin{eqnarray*}
%F  c\left(M+1,n+1\right) & = & \sum_{l=0}^{L-1}f(l+1)(-1)^{l}g(l-2nM+1)
%F  \end{eqnarray*}
%
%   else if $m=M$ and M is odd
%
%M                   L-1 
%M    c(m+1,n+1)   = sum f(l+1)*(-1)^l*g(l-(2*n+1)*M+1)
%M                   l=0
%F  \begin{eqnarray*}
%F  c\left(M+1,n+1\right) & = & \sum_{k=0}^{L-1}f(l+1)(-1)^{l}g\left(l-\left(2n+1\right)M+1\right)
%F  \end{eqnarray*}
%
%   See also:  idwilt, wilwin, wil2rect, dgt, wmdct, wilorth
%
%R  bofegrhl96-1 liva95

%   AUTHOR : Peter Soendergaard.
%   TESTING: TEST_DWILT
%   REFERENCE: REF_DWILT

error(nargchk(3,4,nargin));

if nargin<4
  L=[];
end;

[f,g,L,Ls,W,info] = gabpars_from_windowsignal(f,g,M,2*M,L,'DWILT');

% Call the computational subroutines.
c=comp_dwilt(f,g,M,L);

