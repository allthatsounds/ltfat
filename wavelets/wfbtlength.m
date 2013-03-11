function L=wfbtlength(Ls,wt,varargin);
%FWTLENGTH  WFBT length from signal
%   Usage: L=wfbtlength(Ls,wt);
%          L=wfbtlength(Ls,wt,...);
%
%   `fwtlength(Ls,wt)` returns the length of a Wavelet system that is long
%   enough to expand a signal of length *Ls*. Please see the help on
%   |wfbt|_ for an explanation of the parameter *wt*.
%
%   If the returned length is longer than the signal length, the signal
%   will be zero-padded by |wfbt|_ to length *L*.
%
%   See also: fwt


definput.import = {'fwt','wfbtcommon'};
[flags,kv]=ltfatarghelper({},definput,varargin);

% Initialize the wavelet filters structure
wt = wfbtinit(wt,'ana',flags.treetype,flags.forder);


if(flags.do_per)
   blocksize=max(treeSub(wt));
   L=ceil(Ls/blocksize)*blocksize;
else
   L = Ls;
end