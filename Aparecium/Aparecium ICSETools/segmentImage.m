%% Source code for:
%% Article title: An automatic method for robust and fast cell detection in bright field images from high-throughput microscopy
%% MS ID        : 7277230959453875
%% Authors      : Felix Buggenthin, Carsten Marr, Michael Schwarzfischer, Philipp S Hoppe, Oliver Hilsenbeck, Timm Schroeder and Fabian J Theis
%% Journal      : BMC Bioinformatics, September 2013
%% When using this code in your publication, please cite accordingly
% Copyright (C) 2013 Felix Buggenthin
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.



% Example call:
% I = im2double(imread('Demo1.png'));
% bw = segmentImage(I,1);

% This method requires the image processing toolbox




%% load an image that was acquired in out-of-focus settings
function [bw2] = segmentImage(I_org,varargin)


%%parse the parameters
p = inputParser;
p.StructExpand=true; % if we allow parameter  structure expanding
p.addRequired('I_org', @(x) isa(x,'uint8'));
p.addParamValue('tiledim', 30, @isnumeric); %Background correction. Overlap of 15 px, MinPts = 6 and eps = 0.1 are determined automatically
p.addParamValue('lambda', 5, @isnumeric); %Segmentation
p.addParamValue('minSizeMSER', 30, @isnumeric); %Segmentation
p.addParamValue('maxSizeMSER', 4000, @isnumeric); %Segmentation
p.addParamValue('maxVariation', 1, @isnumeric); %Segmentation
p.addParamValue('maxEcc', .7, @isnumeric); %Cell Splitting
p.addParamValue('minSizeSplit', 30, @isnumeric); %Cell Splitting
p.addParamValue('maxSizeSplit', 1000, @isnumeric); %Cell Splitting
p.addParamValue('visualize', false, @islogical); %Visualization
p.addParamValue('doMerge', 1, @isnumeric); %Merging

p.parse(I_org,varargin{:});
r = p.Results;

I_org = im2double(I_org);
%% compute the background
bg = bgest(I_org,r.tiledim);

%% correct the image
I = I_org./bg;
I(I>1) = 1;
I(I<0) = 0;

I=im2uint8(I);

%% segment the image
msers = linearMser(imcomplement(I),r.lambda,r.minSizeMSER,r.maxSizeMSER,r.maxVariation,0);
bw = zeros(size(I));
bw(cell2mat(msers)) = 1;
bw = logical(bw);

%% split clumped cells
[L,bw2] = splitCells(I,bw,r.minSizeSplit,r.maxSizeSplit,r.maxEcc,1,r.doMerge);

%% visualize it
if r.visualize
    s1 = subplot(2,2,1);
    imagesc(I_org)
    colormap gray
    title('Raw Image')
    axis off
    
    s2 = subplot(2,2,2);
    imagesc(I)
    colormap gray
    title('Background corrected')
    axis off
    
    s3 = subplot(2,2,3);
    imagesc(bw)
    colormap gray
    title('Segmented')
    axis off
    
    s4 = subplot(2,2,4);
    imagesc(bw2)
    colormap gray
    title('Final result after split/merge')
    axis off
    
    linkaxes([s1 s2 s3 s4])
end