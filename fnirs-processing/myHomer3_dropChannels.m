function [outputImage] = myHomer3_dropChannels(inputImage,criteria)
%Crop selected measurements from a fNIRS neuroimage (snirfClass object)
%
% [outputImage] = myHomer3_dropChannels(inputImage,criteria)
%
%
% Create a new fNIRS neuroimage (snirfClass object) where some
% measurements have been eliminated.
%
% In contrast to hmrR_PruneChannels the prunning is not based on quality
% control criteria but on convenience criteria, e.g. for ROI selection
% before plotting. In practice this is merely a filtration of the
% snirfClass object's data.measurementList.
%
%% Remarks
%
% This functions creates a deep copy of the input fNIRS neuroimage
% (snirfClass object) so that te original parameter (which is a subclass)
% of handle does not get modified. The result is returne in output
% parameter outputImage
%
%
%
%% Input Parameters
%
% inputImage - A snirfClass or a DataClass object. The image to be manipulated.
%
% criteria - Struct. A struct of criteria. Current available criteria
%   include:
%     .sources - List of sources whose associated measurements will be
%       removed. For instance, if this is set to [1 3] all channels
%       for which the source is either 1 or 3 will be discarded.
%     .detectors - List of detectors whose associated measurements will be
%       removed. For instance, if this is set to [1 3] all measurements
%       for which the detector is either 1 or 3 will be discarded.
%     .measurements - Explicit list of measurements indexes to be
%        removed, e.g. if this is set to [21 45:47], measurements
%        21, 45, 46 and 47
%   More than one criteria can be used at a time.
%
%
%   +====================================================+
%   | NOTE: Only the measurement list and the            |
%   | dataTimeSeries are cropped. Other elements of the  |
%   | image are not altered, e.g. the probe will still   |
%   | contain any filtered source or detector.           |
%   +====================================================+
%
%   
%
%
%% Output Parameters
%
% outputImage - A snirfClass or DataClass object (same type as input). The cropped figure.
%
%
%
%
%
%
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also 
%

%% Log
%
% 10-May-2023: FOE
%   + File created. Supports SnirfClass only.
%
% 12-May-2023: FOE
%   + Added support for DataClass.
%


if isa(inputImage,'SnirfClass')
    tmpData = inputImage.data;
elseif isa(inputImage,'DataClass')
    %Do nothing
    tmpData = inputImage;
else
    error('Unexpected class for variable tmpData.');
end




%Create a mask of channels to keep
nMeasurements = length(tmpData.measurementList);
mask     = false(1,nMeasurements); %Measurements to drop;
                                   %if true - measurement matches some criteria and will drop
                                   %if false - measurement does not match any criteria and will be kept.
srcList  = zeros(1,nMeasurements);
detList  = zeros(1,nMeasurements);

for iMeas = 1:nMeasurements
    tmpMeas = tmpData.measurementList(iMeas);
    srcList(iMeas) = tmpMeas.sourceIndex;
    detList(iMeas) = tmpMeas.detectorIndex;
end

if isfield(criteria,'sources')
    tmp = ismember(srcList,criteria.sources);
    mask = or(mask,tmp);
end
if isfield(criteria,'detectors')
    tmp = ismember(detList,criteria.detectors);
    mask = or(mask,tmp);
end
if isfield(criteria,'measurements')
    mask(criteria.measurements) = true;
end


%Deep copy the object
err = 0;
if isa(inputImage,'SnirfClass')
    outputImage = SnirfClass();
    err = Copy(outputImage,inputImage);
    outData = outputImage.data;
elseif isa(inputImage,'DataClass')
    outputImage = DataClass();
    Copy(outputImage,inputImage);
    outData = outputImage;
else
    error('Unexpected class for variable tmpData.');
end
if err ~= 0
    error('Deep copy of input image failed.');
end



%Finally, manipulate the output object to drop the measurements matching
%the criteria.
outData.measurementList(mask) = [];
outData.dataTimeSeries(:,mask)  = [];


end