function plotfft(coef,varargin)
%PLOTFFT  Plot the output from FFT
%   Usage: plotfft(coef);
%          plotfft(coef,fs);
%
%   `plotfft(coef)` plots the output from the `fft` function. The
%   frequency axis will use normalized frequencies between 0 and 1 (the
%   Nyquist frequency).
%
%   `plotfft(coef,fs)` does the same for the FFT of a signal sampled at
%   a sampling rate of *fs* Hz.
%
%   `plotfft(coef,fs,dynrange)` additionally limits the dynamic range of the
%   plot. See the description of the `'dynrange'` parameter below.
%
%   `plotfft` accepts the following optional arguments:
%
%     'dynrange',r Limit the dynamical range to `r` by using a colormap in
%                  the interval `[chigh-r,chigh]`, where `chigh` is the highest
%                  value in the plot. The default value of `[]` means to not
%                  limit the dynamical range. 
%
%     'db'         Apply $20\cdot \log_{10}$ to the coefficients. This makes 
%                  it possible to see very weak phenomena, but it might show 
%                  too much noise. This is the default.
%
%     'dbsq'       Apply $10\cdot \log_{10}$ to the coefficients. Same as the
%                  `'db'` option, but assumes that the input is already squared.  
%
%     'lin'        Show the coefficients on a linear scale. This will
%                  display the raw input without any modifications. Only works for
%                  real-valued input.
%                 
%     'linsq'      Show the square of the coefficients on a linear scale.
%                 
%     'linabs'     Show the absolute value of the coefficients on a linear
%                  scale.
%
%     'nf'         Display negative frequencies, with the zero-frequency
%                  centered in the middle. This is the default.
%
%     'posfreq'    Display only the positive frequencies.
%
%     'dim',dim  If `coef` is multidimensional, `dim` indicates the 
%                dimension along which are the individual channels oriented.
%                Value 1 indicates columns, value 2 rows.
%
%
%   In addition to these parameters, `plotfft` accepts any of the flags
%   from |normalize|. The coefficients will be normalized as specified
%   before plotting.
%
%   See also: plotfftreal
  
if nargin<1
  error('%s: Too few input parameters.',upper(mfilename));
end;

% if ~isvector(coef)
%   error('%s: Can only plot vectors.',upper(mfilename));
% end;

definput.import={'ltfattranslate','normalize'};
definput.importdefaults={'null'};

definput.flags.log={'db','dbsq','lin','linsq','linabs'};
definput.flags.posfreq={'nf','posfreq'};

definput.keyvals.fs=[];
definput.keyvals.dynrange=[];

definput.keyvals.opts={};
definput.keyvals.dim=[];
[flags,kv,fs]=ltfatarghelper({'fs','dynrange'},definput,varargin);

[coef,~,N]=assert_sigreshape_pre(coef,[],kv.dim,upper(mfilename));

coef=normalize(coef,flags.norm);

% Apply transformation to coefficients.
if flags.do_db
  coef=20*log10(abs(coef)+realmin);
end;

if flags.do_dbsq
  coef=10*log10(abs(coef)+realmin);
end;

if flags.do_linsq
  coef=abs(coef).^2;
end;

if flags.do_linabs
  coef=abs(coef);
end;

if flags.do_lin
  if ~isreal(coef)
    error(['Complex valued input cannot be plotted using the "lin" flag.',...
           'Please use the "linsq" or "linabs" flag.']);
  end;
end;
  
% 'dynrange' parameter is handled by thresholding the coefficients.
if ~isempty(kv.dynrange)
  maxclim=max(coef(:));
  coef(coef<maxclim-kv.dynrange)=maxclim-kv.dynrange;
end;

if flags.do_nf
  if rem(N,2)==0
    xr=(-N/2+1:N/2)*2/N;  
    % Subtract 1 in order to place the Nyquist frequency following the
    % positive frequencies. That is why we do not use fftshift.
    coef=circshift(coef,N/2-1);
  else
    xr=(-floor(N/2):floor(N/2))*2/N;  
    coef=fftshift(coef);
  end;
else

  N2=floor(N/2)+1;
  coef=coef(1:N2,:);
  xr=(0:N2-1)*2/N;  
end;

if ~isempty(kv.fs)
  xr=xr*kv.fs/2;
end;

plot(xr,coef,kv.opts{:});
xlim([xr(1) xr(end)]);

if flags.do_db || flags.do_dbsq
  ylabel(sprintf('%s (dB)',kv.magnitude));
else
  ylabel(sprintf('%s',kv.magnitude));
end;

if ~isempty(kv.fs)
  xlabel(sprintf('%s (Hz)',kv.frequency));
else
  xlabel(sprintf('%s (%s)',kv.frequency,kv.normalized));
end;

