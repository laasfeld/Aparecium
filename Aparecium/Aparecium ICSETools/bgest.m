%% Source code for:
%% Article title: An automatic method for robust and fast cell detection in bright field images from high-throughput microscopy
%% MS ID        : 7277230959453875 
%% Authors      : Felix Buggenthin, Carsten Marr, Michael Schwarzfischer,
%% Philipp S Hoppe, Oliver Hilsenbeck, Timm Schroeder and Fabian J Theis,
%% modified by Tõnis Laasfeld
%% Journal      : BMC Bioinformatics, September 2013
%% When using this code in your publication, please cite accordingly
%% Copyright (C) 2013 Felix Buggenthin
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


function [ZI,interp]=bgest(I,binsize)


%#codegen
%% init
%fprintf('init...\n')
imgsize=size(I);

x = nan(floor((imgsize(1)-binsize)/binsize*2*(imgsize(2)-binsize)/binsize*2),1);
y = nan(floor((imgsize(1)-binsize)/binsize*2*(imgsize(2)-binsize)/binsize*2),1);
z = nan(floor((imgsize(1)-binsize)/binsize*2*(imgsize(2)-binsize)/binsize*2),1);
featuremat = nan(floor((imgsize(1)-binsize)/binsize*2*(imgsize(2)-binsize)/binsize*2),5);


imgwidth=size(I,2);
imghight=size(I,1);

counter=0;
%fprintf('getting tiling features...\n')

for i = 1:binsize/2:imgsize(1)-binsize  
    for j = 1:binsize/2:imgsize(2)-binsize        
        sub = I(i:i+binsize, j:j+binsize);
        counter=counter+1;
        y(counter) = i+binsize/2;
        x(counter) = j+binsize/2;
        z(counter) = mean(sub(:));
        [skewness kurtosis] = skewnessAndKurtosis(sub(:));
        variation = var(sub(:));       
        featuremat(counter,:)=([sqrt(variation) skewness max(sub(:))/min(sub(:)) kurtosis variation/z(counter)  ]); % new faster version      
        %Original slower version 
        %featuremat(counter,:)=([std(sub(:)) skewness(sub(:)) max(sub(:))/min(sub(:)) kurtosis(sub(:)) var(sub(:))/mean(sub(:))  ]); 
    end
end


%% cluster it
%fprintf('clustering %d points...\n',counter)

[classes,type]=dbscan(featuremat,size(featuremat,2)+1,[]);

if numel(unique(classes))==1
    daclass = unique(classes);
else
    
    classStdIndex = 0;
    uniqueClasses = unique(classes);
    classstd = zeros(1, numel(uniqueClasses));
    for c = uniqueClasses
        classStdIndex = classStdIndex + 1;
        if numel(featuremat(classes == c & type == 1,1))>200
            classstd(classStdIndex) = mean(featuremat(classes == c,1));
        else
            classstd(classStdIndex) = inf;
        end
    end
    [throwawayVariable,daclass] = min(classstd(2:end));
    daclass = daclass+1;
    daclasstemp  = unique(classes);
    daclass = daclasstemp(daclass);
end
interp=sum(classes == daclass& type == 1);

%fprintf('using %d interpolation points...\n',interp)

%% interpolate

[XI YI] = meshgrid(1:imgwidth,1:imghight);
% Tri Scattered Interp seems to give different outputs in different
% versions of matlab. The differences do not significantly alter the
% results
F=TriScatteredInterp(x(classes == daclass& type == 1),y(classes ==daclass& type == 1) ,z(classes ==daclass& type == 1),'natural');% using linear or even nearest here for ICSE does not dramatically affect results but makes the algorithm faster
ZI=F(XI,YI);

%% extrapolate
for i=find(sum(~isnan(ZI(1:imghight,:)))>1)
    ZI(:,i)=interp1(find(~isnan(ZI(:,i))),ZI(~isnan(ZI(:,i)),i), 1:imghight,'linear','extrap');
end
%%
for i=find(sum(~isnan(ZI(:,1:imgwidth))')>1)
    ZI(i,:)=interp1(find(~isnan(ZI(i,:))),ZI(i,~isnan(ZI(i,:))), 1:imgwidth,'linear','extrap');
end


%% fix strange extrapolations
ZI(ZI<min(I(:)))=min(I(:));
ZI(ZI>max(I(:)))=max(I(:));


%fprintf('done\n')
end