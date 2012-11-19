function c=dstiii(f,L,dim)
%DSTIII  Discrete sine transform type III
%   Usage:  c=dstiii(f);
%           c=dstiii(f,L);
%           c=dstiii(f,[],dim);
%           c=dstiii(f,L,dim);
%
%   `dstiii(f)` computes the discrete sine transform of type III of the
%   input signal *f*. If *f* is multi-dimensional, the transformation is
%   applied along the first non-singleton dimension.
%
%   `dstiii(f,L)` zero-pads or truncates *f* to length *L* before doing the
%   transformation.
%
%   `dstiii(f,[],dim)` or `dstiii(f,L,dim)` applies the transformation along
%   dimension *dim*.
%
%   The transform is real (output is real if input is real) and orthonormal.
%
%   This is the inverse of |dstii|_.
%
%   Let f be a signal of length *L*, let `c=dstiii(f)` and define the vector
%   *w* of length *L* by  
%
%   ..  w = [1 1 1 1 ... 1/sqrt(2)]
%
%   .. math:: w\left(n\right)=\begin{cases}\frac{1}{\sqrt{2}} & \text{if }n=L-1\\1 & \text{otherwise}\end{cases}
%
%   Then 
%
%   ..                     L-1
%     c(n+1) = sqrt(2/L) * sum w(n+1)*f(m+1)*sin(pi*(n+.5)*m/L) 
%                          m=0 
%
%   .. math::  c\left(n+1\right)=\sqrt{\frac{2}{L}}\sum_{m=0}^{L-1}w\left(n\right)f\left(m+1\right)\sin\left(\frac{\pi}{L}\left(n+\frac{1}{2}\right)m\right)
%
%   See also:  dctii, dstii, dstiv
%
%   References: rayi90 wi94
  
%   AUTHOR: Peter L. Søndergaard
%   TESTING: TEST_PUREFREQ
%   REFERENCE: REF_DSTIII


error(nargchk(1,3,nargin));

if nargin<3
  dim=[];
end;

if nargin<2
  L=[];
end;

[f,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,L,dim,'DSTIII');

if ~isempty(L)
  f=postpad(f,L);
end;

c=zeros(2*L,W);
  
m1=1/sqrt(2)*exp((1:L)*pi*i/(2*L)).';
m1(L)=i;
  
m2=-1/sqrt(2)*exp(-(L-1:-1:1)*pi*i/(2*L)).';
  
for w=1:W
  c(:,w)=[0;m1.*f(:,w);m2.*f(L-1:-1:1,w)];
end;

c=-sqrt(L)*2*i*ifft(c);
c=c(1:L,:);

if isreal(f)
  c=real(c);
end;

c=assert_sigreshape_post(c,dim,permutedsize,order);

% This is a slow, but convenient way of expressing the above algorithm.
%R=1/sqrt(2)*[zeros(1,L); ...
%	     diag(exp((1:L)*pi*i/(2*L)));...	     
%	     [flipud(diag(-exp(-(1:L-1)*pi*i/(2*L)))),zeros(L-1,1)]];
%R(L+1,L)=i;
%
%c2=-sqrt(L)*2*i*ifft(R*f);
%
%c=c2(1:L,:);

