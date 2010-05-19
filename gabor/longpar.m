function [L,tfr]=longpar(varargin)
%LONGPAR  Parameters for LONG windows
%   Usage:  [L,tfr]=longpar(Ls,a,M);
%           [L,tfr]=longpar('dgt',Ls,a,M);
%           [L,tfr]=longpar('dwilt',Ls,M);
%           [L,tfr]=longpar('wmdct',Ls,M);
%
%   [L,tfr]=LONGPAR(Ls,a,M) or [L,tfr]=LONGPAR('dgt',Ls,a,M) calculates the 
%   mimumal transform length L for a DGT of a signal of length Ls with
%   parameters _a and M. L is always larger than Ls. The parameters tfr
%   describes the time-to-frequency ratio of the choosen lattice.
%
%   An example can most easily describe the use of LONGPAR. Assume that
%   with wish to perform Gabor analysis of an input signal _f with a 
%   suitable Gaussian window and lattice given by _a and M. The following
%   code will always work:
%
%C     Ls=length(f);
%C     [L,tfr]=longpar(Ls,a,M);
%C     g=pgauss(L,tfr);
%C     c=dgt(f,g,a,M);
%
%   [L,tfr]=LONGPAR('dwilt',Ls,M) and [L,tfr]=LONGPAR('wmdct',Ls,M) will
%   do the same for a Wilson/WMDCT basis with M channels.
%
%   See also:  dgt, dwilt, pgauss, psech, pherm

error(nargchk(3,4,nargin));

if ischar(varargin{1})
    ttype=varargin{1};
    pstart=2;
else
    ttype='dgt';
    pstart=1;
end;

Ls=varargin{pstart};

if (numel(Ls)~=1 || ~isnumeric(Ls))
  error('Ls must be a scalar.');
end;
if rem(Ls,1)~=0
  error('Ls must be an integer.');
end;


switch(lower(ttype))
    case 'dgt'
        if nargin<pstart+2
            error('Too few input parameters for DGT type.');
        end;
        
        a=varargin{pstart+1};
        M=varargin{pstart+2};
        
        smallest_transform=lcm(a,M);
        L=ceil(Ls/smallest_transform)*smallest_transform;
        b=L/M;
        tfr=a/b;
    case {'dwilt','wmdct'}
        if nargin<pstart+1
            error('Too few input parameters for DWILT/WMDCT type.');
        end;
        M=varargin{pstart+1};

        smallest_transform=2*M;
        L=ceil(Ls/smallest_transform)*smallest_transform;
        b=L/(2*M);
        tfr=M/b;
    otherwise
        error('Unknown transform type.');
end;

