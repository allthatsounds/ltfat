function [g,info] = wilwin(g,M,L);
%WILWIN  Compute a Wilson/WMDCT window from text or cell array.
%   Usage: [g,info] = wilwin(g,M,L);
%
%   [g,info]=WILWIN(g,M,L) computes a window that fits well with the
%   specified number of channels M and transform length L. The window itself
%   is specified by a text description or a cell array containing additional
%   parameters.
%
%   The window can be specified directly as a vector of numerical
%   values. In this case, WILWIN only checks assumptions about transform
%   sizes etc.
%
%   [g,info]=WILWIN(g,a,M) does the same, but the window must be a FIR
%   window, as the transform length is unspecified.
%
%   The window can be specified as one of the following text strings:
%  
%-      'gauss'     - Gaussian window with optimal concentration
%
%-      'dualgauss' - Riesz dual of Gaussian window with optimal concentration.
%
%-      'tight'     - Window generating an ortonormal basis
%
%   In these cases, a long window is generated with a length of L.
%
%   It is also possible to specify one of the window names from FIRWIN. In
%   such a case, WILWIN will generate the speficied FIR window with a length
%   of M.
%
%   The window can also be specified as cell array. The possibilities are:
%
%-    {'gauss',...} - Additional parameters are passed to PGAUSS
%
%-    {'dual',...}  - Dual window of whatever follows. See the
%                   examples below.
%
%-    {'tight',...} - Ortonormal window of whatever follows.
%
%   It is also possible to specify one of the window names from FIRWIN as
%   the first field in the cell array. In this case, the remaining
%   entries of the cell array are passed directly to FIRWIN.
%
%   Some examples:
%
%C     g=wilwin('gauss',M,L);
%
%   This computes a Gaussian window of length L fitted for a system with M channels.
%
%C    g=wilwin({'gauss',1},M,L);
%
%   This computes a Gaussian window with equal time and frequency support
%   irrespective of M.
%
%C    gd=wilwin('gaussdual',M,L);
%
%   This computes the dual of a Gaussian window fitted for a system with M
%   channels.
%
%C    gd=wilwin({'tight','gauss'},M,L);
%
%   This computes the orthonormal window of the Gaussian window fitted for
%   the system.
%
%C    g=wilwin({'dual',{'hann',20}},M,L);
%
%   This computes the dual of a Hann window of length 20.  
%
%   The structure info provides some information about the computed
%   window:
%
%-     info.gauss   - True if the window is a Gaussian.
%
%-     info.tfr     - Time/frequency support ratio of the window. Set
%                     whenever it makes sense.
%
%-     info.wasrow  - Input was a row window
%
%-     info.isfir   - Input is a FIR window
%
%-     info.isdual  - Output is the dual window of the aux window.
%
%-     info.istight - Output is known to be a tight window.
%
%-     info.auxinfo - Info about auxiliary window.
%
%-     info.gl      - Length of window.
%
%   See also: pgauss, firwin, gabwin
  
% Assert correct input.
error(nargchk(2,3,nargin));

if nargin==2
  L=[];
end;

[g,info] = comp_window(g,M,2*M,L,1,'WILWIN');