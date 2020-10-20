function [output] = roi2data(BR, atlas, rois)
% ROI2DATA Convert ROI values to vertex values
% For the generating of atlas index, do 'roi_index=unique(atlas)'
% Made by Seun Jeon; modified by Katie Lavigne

original_size = size(atlas,1); 
%     rois=unique(atlas); 
roinum = size(rois,1); 
%     subjnum=size(BR,1); 
subjnum = 1;
output = zeros(subjnum,original_size);

for j = 1:subjnum
    for i = 1:original_size
        try
            output(j,i) = BR(rois==atlas(i),j);
        catch
            output(j,i) = 0;
        end
    end
end