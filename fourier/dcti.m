function c=dcti(f,L,dim)
%DCTI  Discrete Cosine Transform type I
%   Usage:  c=dcti(f);
%           c=dcti(f,L);
%           c=dcti(f,[],dim);
%           c=dcti(f,L,dim);
%
%   DCTI(f) computes the discrete cosine transform of type I of the
%   input signal f. If f is a matrix, then the transformation is applied to
%   each column. For N-D arrays, the transformation is applied to the first
%   dimension.
%
%   DCTI(f,L) zero-pads or truncates f to length L before doing the
%   transformation.
%
%   DCTI(f,[],dim) applies the transformation along dimension dim. 
%   DCTI(f,L,dim) does the same, but pads or truncates to length L.
%   
%   The transform is real (output is real if input is real) and
%   it is orthonormal.
%
%   This transform is its own inverse.
%
%   Let f be a signal of length _L, let c=DCTI(f) and define the vector
%   _w of length _L by  
%N    w = [1/sqrt(2) 1 1 1 1 ...1/sqrt(2)]
%L    \[w\left(n\right)=\begin{cases}\frac{1}{\sqrt{2}} & \text{if }n=0\text{ or }n=L-1\\1 & \text{otherwise}\end{cases}\]
%   Then 
%M
%M                             L-1
%M    c(n+1) = sqrt(2/(L-1)) * sum w(n+1)*w(m+1)*f(m+1)*cos(pi*n*m/(L-1)) 
%M                             m=0 
%F  \[
%F  c\left(n+1\right)=\sqrt{\frac{2}{L-1}}\sum_{m=0}^{L-1}w\left(n\right)w\left(m\right)f\left(m+1\right)\cos\left(\frac{\pi nm}{L-1}\right)
%F  \]
%M
%   The implementation of this functions uses a simple algorithm that require
%   an FFT of length 2L-2, which might potentially be the product of a large
%   prime number. This may cause the function to sometimes execute slowly.
%   If guaranteed high speed is a concern, please consider using one of the
%   other DCT transforms.
%M
%   See also:  dctii, dctiv, dsti
%M
%R  rayi90 wi94

%   AUTHOR: Peter Soendergaard
%   TESTING: TEST_PUREFREQ
%   REFERENCE: REF_DCTI
  
error(nargchk(1,3,nargin));

if nargin<3
  dim=[];
end;

if nargin<2
  L=[];
end;

[f,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,L,dim,'DCTI');
    
if ~isempty(L)
  f=postpad(f,L);
end;

if L==1
  c=f;
 
else

  c=zeros(L,W);
  
  f2=[f;flipud(f(2:L-1,:))]/sqrt(2);
  f2(1,:)=f2(1,:)*sqrt(2);
  f2(L,:)=f2(L,:)*sqrt(2);
  
  % Do DFT.
  s1=fft(f2)/sqrt(2*L-2);

  % This could be done by a repmat instead.
  for w=1:W
    c(:,w)=s1(1:L,w)+[0;s1(2*L-2:-1:L+1,w);0];
  end;

  c(2:L-1,:)=c(2:L-1,:)/sqrt(2);
  
  if isreal(f)
    c=real(c);
  end;

end;

c=assert_sigreshape_post(c,dim,permutedsize,order);