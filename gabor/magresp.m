function magresp(g,varargin);
%MAGRESP   Magnitude response plot of window
%   Usage:   magresp(g,...);
%            magresp(g,fs,...);
%            magresp(g,fs,L,....);
%
%   MAGRESP(g) will display the magnitude response of the window g.
%   This is the DFT of g shown on a log scale normalized such that
%   the peak is 0 db.
%
%   MAGRESP(g,fs) does the same, but extends the window to length L.
%   Always use this mode for FIR windows, and select an L somewhat
%   longer than the window to make an accurate plot.
%
%   MAGRESP(g,fs,L) MAGRESP(g,[],L) will do the same for a window
%   intended to be used with signals with sampling rate sr. The x-axis
%   will display Hz.
%
%   If the input window is real, only the positive frequencies will be
%   shown. Adding the option 'nf' as the last parameter will show the
%   negative frequencies anyway.

%   AUTHOR : Peter Soendergaard.
%   TESTING: NA
%   REFERENCE: NA

if nargin<1
  error('Too few input arguments.');
end;

L=[];
fs=[];
donf=0;

% Define initial value for flags and key/value pairs.

defnopos.flags.dynrange={'nodynrange','dynrange'};

if isreal(g)
  defnopos.flags.posfreq={'posfreq','nf'};
else
  defnopos.flags.posfreq={'nf','posfreq'};
end;

defnopos.keyvals.fs=[];
defnopos.keyvals.L=length(g);
defnopos.keyvals.dynrange=100;

[flags,keyvals,fs,L]=ltfatarghelper({'fs','L'},defnopos,varargin,mfilename);

g=fir2long(g,L);

% Perform unitaty DFT.
FF=abs(dft(g));

% Scale
FF=FF/max(max(abs(FF)));

% Convert to Db. Add eps to avoid log of zero.
FF=20*log10(FF+realmin);

ymin=max(-keyvals.dynrange,min(min(FF)));

donf=0;
if ~isreal(g)
  donf=1;
end;

if donf
  plotff=fftshift(FF);
  if isempty(fs)
    xrange=-floor(L/2):ceil(L/2)-1;
    axisvec=[-L/2 L/2 ymin 0];
  else
    xrange=linspace(-floor(fs/2),ceil(fs/2)-1,L).';
    axisvec=[-fs/2 fs/2 ymin 0];
  end;
else
  % Only plot positive frequencies for real-valued signals.
  if isempty(fs)
    xrange=0:floor(L/2);
    axisvec=[0 L/2 ymin 0];
  else
    xrange=linspace(0,floor(fs/2),L/2+1).';
    axisvec=[0 fs/2 ymin 0];
  end;
  plotff=FF(1:floor(L/2)+1);
end;

plot(xrange,plotff);
axis(axisvec);
ylabel('Magnitude response / Db');

if isempty(fs)
  xlabel('Frequency');
else
  xlabel('Frequency / Hz');
end;

legend('off');
