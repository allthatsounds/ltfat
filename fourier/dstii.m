function c=dstii(f,L,dim)
%DSTII  Discrete Sine Transform type II
%   Usage:  c=dstii(f);
%           c=dstii(f,L);
%           c=dstii(f,[],dim);
%           c=dstii(f,L,dim);
%
%   DSTII(f) computes the discrete sine transform of type II of the
%   input signal f. If f is a matrix, then the transformation is applied to
%   each column. For N-D arrays, the transformation is applied to the first
%   dimension.
%
%   DSTII(f,L) zero-pads or truncates f to length L before doing the
%   transformation.
%
%   DSTII(f,[],dim) applies the transformation along dimension dim. 
%   DSTII(f,L,dim) does the same, but pads or truncates to length L.
%
%   The transform is real (output is real if input is real) and
%   it is orthonormal.
%
%   The inverse transform of DSTII is DSTIII.
%
%   Let f be a signal of length _L, let c=DSTII(f) and define the vector
%   _w of length _L by  
%N    w = [1 1 1 1 ... 1/sqrt(2)]
%L    \[w\left(n\right)=\begin{cases}\frac{1}{\sqrt{2}} & \text{if }n=L-1\\1 & \text{otherwise}\end{cases}\]
%   Then 
%M
%M                         L-1
%M    c(n+1) = sqrt(2/L) * sum w(n+1)*f(m+1)*sin(pi*n*(m+.5)/L) 
%M                         m=0 
%F  \[
%F  c\left(n+1\right)=\sqrt{\frac{2}{L}}\sum_{m=0}^{L-1}w\left(n\right)f\left(m+1\right)\sin\left(\frac{\pi}{L}n\left(m+\frac{1}{2}\right)\right)
%F  \]
%M
%   See also:  dctii, dstiii, dstiv
%M
%R  rayi90 wi94

%   AUTHOR: Peter Soendergaard
%   TESTING: TEST_PUREFREQ
%   REFERENCE: REF_DSTII

error(nargchk(1,3,nargin));

if nargin<3
  dim=[];
end;

if nargin<2
  L=[];
end;
   
[f,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,L,dim,'DSTII');
 
if ~isempty(L)
  f=postpad(f,L);
end;

c=zeros(L,W);

m1=1/sqrt(2)*exp(-(1:L)*pi*i/(2*L)).';
m1(L)=-i;
  
m2=-1/sqrt(2)*exp((1:L-1)*pi*i/(2*L)).';

s1=i*fft([f;-flipud(f)])/sqrt(L)/2;

% This could be done by a repmat instead.
for w=1:W
  c(:,w)=s1(2:L+1,w).*m1+[s1(2*L:-1:L+2,w).*m2;0];
end;

if isreal(f)
  c=real(c);
end;

c=assert_sigreshape_post(c,dim,permutedsize,order);

% This is a slow, but convenient way of expressing the above algorithm.
%R=1/sqrt(2)*[zeros(1,L); ...
%	     diag(exp((1:L)*pi*i/(2*L)));...	     
%	     [flipud(diag(-exp(-(1:L-1)*pi*i/(2*L)))),zeros(L-1,1)]];
%R(L+1,L)=i;

%c=i*(R'*fft([f;-flipud(f)])/sqrt(L)/2);