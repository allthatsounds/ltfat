function gd=gabprojdual(gm,g,a,M,varargin);
%GABPROJDUAL   Gabor Dual window by projection
%   Usage:  gd=gabprojdual(gm,g,a,M)
%           gd=gabprojdual(gm,g,a,M,L)
%
%   Input parameters:
%         gm    : Window to project.
%         g     : Window function.
%         a     : Length of time shift.
%         M     : Number of modulations.
%         L     : Length of transform to consider
%   Output parameters:
%         gd    : Dual window.
%
%   `gabprojdual(gm,g,a,M)` calculates the dual window of the Gabor frame given
%   by *g*, *a* and *M* closest to *gm* measured in the $l^2$ norm. The
%   function projects the suggested window *gm* onto the subspace of
%   admissable dual windows, hence the name of the function.
%
%   `gabprojdual(gm,g,a,M,L)` first extends the windows *g* and *gm* to
%   length *L*.
%
%   `gabprojdual(...,'lt',lt)` does the same for a non-separable lattice
%   specified by *lt*. Please see the help of |matrix2latticetype|_ for a
%   precise description of the parameter *lt*.
%
%   See also:  gabdual, gabtight, gabdualnorm, fir2long

%   AUTHOR : Peter L. Søndergaard 

if nargin<4
  error('%s: Too few input parameters.',upper(mfilename));
end;

definput.keyvals.L=[];
definput.keyvals.lt=[0 1];
definput.flags.phase={'freqinv','timeinv'};
[flags,kv,L]=ltfatarghelper({'L'},definput,varargin);



%% ------ step 2: Verify a, M and L
if isempty(L)
    % Minimum transform length by default.
    Ls=1;
    
    % Use the window lengths, if any of them are numerical
    if isnumeric(g)
        Ls=max(length(g),Ls);
    end;

    if isnumeric(gm)
        Ls=max(length(gm),Ls);
    end;

    % ----- step 2b : Verify a, M and get L from the window length ----------
    L=dgtlength(Ls,a,M,kv.lt);

else

    % ----- step 2a : Verify a, M and get L

    Luser=dgtlength(L,a,M,kv.lt);
    if Luser~=L
        error(['%s: Incorrect transform length L=%i specified. Next valid length ' ...
               'is L=%i. See the help of DGTLENGTH for the requirements.'],...
              upper(mfilename),L,Luser)
    end;

end;

[g, info_g]  = gabwin(g, a,M,L,kv.lt,'callfun',upper(mfilename));
[gm,info_gm] = gabwin(gm,a,M,L,kv.lt,'callfun',upper(mfilename));
 
% gm must have the correct length, otherwise dgt will zero-extend it
% incorrectly using postpad instead of fir2long
gm=fir2long(gm,L);

% Calculate the canonical dual.
gamma0=gabdual(g,a,M,'lt',kv.lt);
  
% Get the residual
gres=gm-gamma0;

% Calculate parts that lives in span of adjoint lattice.
if isreal(gres) && isreal(gamma0) && isreal(g) && kv.lt(2)<=2
    gk=idgtreal(dgtreal(gres,gamma0,M,a,'lt',kv.lt),g,M,a,'lt',kv.lt)*M/a;    
else
    gk=idgt(dgt(gres,gamma0,M,a,'lt',kv.lt),g,M,'lt',kv.lt)*M/a;
end;
    
% Construct dual window
gd=gamma0+(gres-gk);
    
    
    
