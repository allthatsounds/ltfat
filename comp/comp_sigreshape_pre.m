function [f,fl,W,wasrow,remembershape]=comp_sigreshape_pre(f,callfun,do_ndim)
%COMP_SIGRESHAPE_PRE
%  

%   AUTHOR : Peter L. Søndergaard.
%   TESTING: OK
%   REFERENCE: OK
    
wasrow=0;

% Rember the shape if f is multidimensional.
remembershape=size(f);
fd=length(remembershape);


% Multi-dimensional mode, apply to first dimension.
if fd>2
	
  if (do_ndim>0) && (fd>do_ndim)
    error([callfun,': ','Cannot process multidimensional arrays.']);
  end;
  
  fl=size(f,1);
  W=prod(remembershape)/fl;

  % Reshape to matrix if multidimensional.
  f=reshape(f,fl,W);

else

  if size(f,1)==1
    wasrow=1;
    % Make f a column vector.
    f=f(:);
  end;
  
  fl=size(f,1);
  W=size(f,2);
  
end;





