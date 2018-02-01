
function [ RGBOUT ] = colourscale( varargin )
%COLOURSCALEPLOT Make colourful, nice-looking plots
%  This function takes the current figure and applies a series of colours
%  to each "line". These colours are a spectrum of saturations and intensities for
%  a given colour hue. 
%
% COLOURSCALE(...,'hue',H)
%  Use hue H for colour scheme. Since H is a standard "HSV" hue, it varies
%  from zero to one, where approximately:
%      H=0.0  - red
%      H=0.1  - orange
%      H=0.15 - yellow
%      H=0.35 - green
%      H=0.55 - light blue
%      H=0.6  - dark blue
%      H=0.75 - purple
%      H=0.85 - magenta
%      H=1.0  - red again
%
% COLOURSCALE(...,'chroma',C)
%  Use chroma C for colour scheme. Chroma appears to be a nonlinear
%  parameter with sensible maximum; values around 40 to 100 appear to be
%  best, although higher than this produces brighter colours they also
%  start clipping what is possible represent in RGB.
%
% COLOURSCALE(...,'linewidth',[LW1 LW2])
%  If not specified, the plots take on their "natural" linewidth as default
%  or as specified by the user. If set to a two-element vector, the
%  linewidths of the lines will be set to vary linearly from LW1 to LW2 as
%  the plots change colour from dark to light. (This is useful as lighter
%  lines often need to be slightly thicker to remain visible compared to
%  darker lines.)
%
% COLOURSCALE(...,'repeat',N)
%  An optional argument specifies the number of times to use the
%  colour space: e.g., colourplot(2) will turn, in a graph with 6 data
%  series, the first and fourth plot blue, the second and fifth
%  green, and the third and six red. The divisor of the number of
%  plots and the number of colour space repetitions must be an
%  integer.
%
% COLOURSCALE(...,'permute',P)
%  By default the lines are coloured in the order in which they
%  were plot. This order can be changed by specifying a permutation
%  of the order in the second argument, such as in a four-plot graph:
%      colourplot(1,[1 3 2 4])
%
%  If the 'UserData' for a data line is 'colourplot:ignore', then
%  it will not be included in the COLOURPLOT colouring.
%
%  RGBOUT = colourscale( ... ) will simply return the colours that
%  would be used, but it will NOT attempt to colour the plot.
%
%
% Please report bugs and feature requests for
% this package at the development repository:
%  <http://github.com/wspr/matlabpkg/>
%
% COLOURSCALEPLOT  v0.1  Will Robertson
% Licence appended.

p = inputParser;
p.addOptional('hue',0.2);
p.addOptional('chroma',70);
p.addOptional('repeat',1);
p.addOptional('permute',[]);
p.addOptional('lumin_min',[65 50 40 30]);
p.addOptional('lumin_max',[65 80 80 90]);
p.addOptional('linewidth',[]);

p.parse(varargin{:});

hue     = p.Results.hue;
chroma  = p.Results.chroma;
series  = p.Results.repeat;
permute = p.Results.permute;
lumin_min = p.Results.lumin_min;
lumin_max = p.Results.lumin_max;
lw_range = p.Results.linewidth;

if ~isempty(lw_range)
  if numel(lw_range) == 1
    lw_range = lw_range([1 1]);
  end
end

ch = findobj(gca,'Type','line','-not','UserData','colourplot:ignore');

Nch = length(ch);
Ncol = Nch/series;
if round(Ncol) ~= Ncol
  % Each set of data series must be the same length to avoid rounding problems!!
  disp(['There are ',num2str(Nch),' data series'])
  error('There must be an integer multiple of specified data series in the figure.')
end

hcl = ones(Ncol,3);
if mod(Ncol,2) == 1
  ncol1 = (Ncol+1)/2;
  ncol2 = (Ncol-1)/2;
else
  ncol1 = Ncol/2;
  ncol2 = Ncol/2;
end
v1 = hue/2; v2 = 1;

Nlum = numel(lumin_max);
if numel(lumin_min) ~= numel(lumin_max)
  error('Min and max luminance vectors must be equal size.')
end

lmin = lumin_min(min([Ncol,Nlum]));
lmax = lumin_max(min([Ncol,Nlum]));

if ~isempty(lw_range)
  lw = linspace(lw_range(1),lw_range(2),Ncol);
end

hcl(:,1) = hue*360;
hcl(:,2) = chroma;
hcl(:,3) = linspace(lmin,lmax,Ncol)';

rgb = nan(size(hcl));
for ii = 1:Ncol
  rgb(ii,:) = hcl2rgb(hcl(ii,1),hcl(ii,2),hcl(ii,3))';
end
rgb = rgb/255;

if isempty(permute)
  permute = 1:Nch;
else
  if ~isequal(sort(permute),1:Nch)
    error('2nd argument must be a permutation of 1:N where N is the number of colours.');
  end
end

if nargout == 0
  for ii = 1:Nch
    ind = mod(ii-1,Ncol)+1;
    if isequal(get(ch(ii),'type'),'line')
      if isempty(lw_range)
        set(ch(permute(ii)),...
          'Color',rgb(ind,:),...
          'UserData','colourplot:ignore')
      else
        set(ch(permute(ii)),...
          'Color',rgb(ind,:),...
          'LineWidth',lw(ind),...
          'UserData','colourplot:ignore')
      end
    end
    if isequal(get(ch(ii),'type'),'surface')
      set(ch(permute(ii)),...
        'FaceColor',rgb(ind,:),...
        'EdgeColor',rgb(ind,:),...
        'UserData','colourplot:ignore')
    end
  end
else
  RGBOUT = rgb;
end

return

% Copyright (c) 2015-2016, Will Robertson, will at wspr dot io
% All rights reserved.
%
% Distributed under the BSD licence in accordance with the wishes of the
% Matlab File Exchange.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in the
%       documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ''AS IS'' AND ANY
% EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
% THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.




function rgb = hcl2rgb(h, c, l)
%HCL2RGB Convert a HCL (i.e., CIELUV) color space value to one
%   in sRGB space.
%   RGB = HCL2RGB(H, C, L) will convert the color (H, C, L) in
%   HCL color space to RGB = [R, G, B] in sRGB color space.
%   Values that lie outside sRGB space will be silently corrected.

% Code written by Nicholas J. Hughes, 2014, released under the following
% licence.
%
% Some minor alternations by Will Robertson, 2018.
%
% The MIT License (MIT)
%
% Copyright (c) 2014 Nicholas J. Hughes
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

% D65 White Point
WHITE_Y = 100.000;
WHITE_u = 0.1978398;
WHITE_v = 0.4683363;

if l < 0 || l > WHITE_Y || c < 0
    error('Invalid CIE-HCL color.');
end

% First convert to CIELUV (just a polar to Cartesian coordinate transformation)
L = l;
U = c * cosd(h);
V = c * sind(h);

% Now convert to CIEXYZ
if L <= 0 && U == 0 && V == 0
    X = 0;
    Y = 0;
    Z = 0;
else
    Y = WHITE_Y;
    if L > 7.999592
        Y = Y*((L + 16)/116)^3;
    else
        Y = Y*L/903.3;
    end
    u = U/(13*L) + WHITE_u;
    v = V/(13*L) + WHITE_v;
    X = (9.0*Y*u)/(4*v);
    Z = -X/3 - 5*Y + 3*Y/v;
end

% Now convert to sRGB
r = gamma_correct((3.240479*X - 1.537150*Y - 0.498535*Z)/WHITE_Y);
g = gamma_correct((-0.969256*X + 1.875992*Y + 0.041556*Z)/WHITE_Y);
b = gamma_correct((0.055648*X - 0.204043*Y + 1.057311*Z)/WHITE_Y);

% Round to integers and correct
rgb = [r, g, b];
rgb = round(255 * rgb);

% if any(rgb(:) > 255)
%   warning('Colour outside RGB range; clipping.')
% end
% if any(rgb(:) < 0)
%   warning('Colour less than zero in RGB; clipping.')
% end

rgb(rgb(:) > 255) = 255;
rgb(rgb(:) < 0)   = 0;


function u = gamma_correct(u)

% Standard CRT Gamma
GAMMA = 2.4;

if u > 0.00304
	u = 1.055*u^(1/GAMMA) - 0.055;
else
	u = 12.92*u;
end
