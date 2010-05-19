function []=resgram(f,varargin)
%RESGRAM  Reassigned spectrogram plot
%   Usage: resgram(f,op1,op2, ... );
%          resgram(f,fs,op1,op2, ... );
%
%   RESGRAM(f) plots a reassigned spectrogram of f.
%
%   RESGRAM(f,fs) does the same for a signal with sampling rate fs (sampled
%   with fs samples per second);
%
%   Because reassigned spectrograms can have an extreme dynamical range,
%   consider using the 'dynrange' or 'clim' options (see below) in
%   conjunction with the 'db' option (on by default). An example:
%
%C    resgram(greasy,16000,'dynrange',40);
%
%   This will produce a reassigned spectrogram of the 'greasy' signal
%   without drowning the interesting features in noise.
%
%   Additional arguments can be supplied like this:
%   RESGRAM(f,'nf','tfr',2,'log'). The arguments must be character
%   strings possibly followed by an argument:
%
%-  'tfr',v   - Set the ratio of frequency resolution to time resolution.
%               A value v=1 is the default. Setting v>1 will give better
%               frequency resolution at the expense of a worse time
%               resolution. A value of 0<v<1 will do the opposite.
%
%-  'thr',r   - Keep only the largest fraction r of the coefficients, and
%               set the rest to zero.
%
%-  'sharp',alpha - Set the sharpness of the plot. If alpha=0 the regular
%               spectrogram is obtained. alpha=1 means full
%               reassignment. Anything inbetween will produce a partially
%               sharpened picture. Default is alpha=1
%
%-  'nf'      - Display negative frequencies, with the zero-frequency
%               centered in the middle. For real signals, this will just
%               mirror the upper half plane. This is standard for complex
%               signals.
%
%-  'tc'      - Time centering. Move the beginning of the signal to the
%               middle of the plot. This is useful for visualizing the
%               window functions of the toolbox.
%
%-  'db'      - Apply 20*log10 to the coefficients. This makes it possible to
%               see very weak phenomena, but it might show to much noise. A
%               logarithmic scale is more adapted to perception of sound.
%
%-  'lin'     - Show the energy of the coefficients on a linear scale.
%
%-  'image'   - Use 'imagesc' to display the spectrogram. This is the
%               default.
%
%-  'clim',[clow,chigh] - Use a colormap ranging from clow to chigh. These
%               values are passed to IMAGESC. See the help on IMAGESC.
%
%-  'dynrange',range - Use a colormap in the interval [chigh-range,chigh], where
%               chigh is the highest value in the plot.
%
%-  'fmax',y  - Display y as the highest frequency.
%
%-  'contour' - Do a contour plot
%          
%-  'surf'    - Do a surf plot
%
%-  'mesh'    - Do a mesh plot
%
%   In Octave, the default colormap is greyscale. Change it to _colormap(jet)
%   for something prettier.

%   AUTHOR : Peter Soendergaard.
%   TESTING: NA
%   REFERENCE: NA

% BUG: Setting the sharpness different from 1 produces a black line in the
% middle of the plot.
  
if nargin<1
  error('Too few input arguments.');
end;

if sum(size(f)>1)>1
  error('Input must be a vector.');
end;




% Define initial value for flags and key/value pairs.
defnopos.flags.wlen={'nowlen','wlen'};
defnopos.flags.thr={'nothr','thr'};
defnopos.flags.tc={'notc','tc'};
defnopos.flags.plottype={'image','contour','mesh','pcolor'};

defnopos.flags.clim={'noclim','clim'};
defnopos.flags.fmax={'nofmax','fmax'};
defnopos.flags.log={'db','lin'};
defnopos.flags.dynrange={'nodynrange','dynrange'};
defnopos.flags.colorbar={'colorbar','nocolorbar'};

if isreal(f)
  defnopos.flags.posfreq={'posfreq','nf'};
else
  defnopos.flags.posfreq={'nf','posfreq'};
end;

defnopos.keyvals.fs=[];
defnopos.keyvals.sharp=1;
defnopos.keyvals.tfr=1;
defnopos.keyvals.wlen=0;
defnopos.keyvals.thr=0;
defnopos.keyvals.clim=[0,1];
defnopos.keyvals.climsym=1;
defnopos.keyvals.fmax=0;
defnopos.keyvals.dynrange=100;
defnopos.keyvals.xres=800;
defnopos.keyvals.yres=600;

[flags,keyvals,fs]=ltfatarghelper({'fs'},defnopos,varargin,mfilename);

if (keyvals.sharp<0 || keyvals.sharp >1)
  error(['RESGRAM: Sharpness parameter must be between (including) ' ...
	 '0 and 1']);
end;

% Downsample
resamp=1;
if flags.do_fmax
  if dofs
    resamp=fmax*2/fs;
  else
    resamp=fmax*2/length(f);
  end;

  f=fftresample(f,round(length(f)*resamp));
end;

Ls=length(f);

if flags.do_posfreq
   keyvals.yres=2*keyvals.yres;
end;

[a,M,L,N,Ndisp]=gabimagepars(Ls,keyvals.xres,keyvals.yres);

% Set an explicit window length, if this was specified.
if flags.do_wlen
  keyvals.tfr=keyvals.wlen^2/L;
end;

g={'gauss',keyvals.tfr};

[tgrad,fgrad,c]=gabphasegrad('dgt',f,g,a,M);          
coef=gabreassign(abs(c).^2,keyvals.sharp*tgrad,keyvals.sharp*fgrad,a);

if flags.do_posfreq
  coef=coef(1:floor(M/2)+1,:);
end;

% Cut away zero-extension.
coef=coef(:,1:Ndisp);

if flags.do_thr
  % keep only the largest coefficients.
  coef=largestr(coef,keyvals.thr);
end

tfplot(coef,a,M,L,resamp,keyvals,flags);

if nargout>0
  varargout={coef};
end;
