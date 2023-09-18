% ml = myHomer3_unfoldMeasurementList(data)
% ml = myHomer3_unfoldMeasurementList(measurementList)
%
%Unfold the measurement list of the snirf data into a table for quicker
% access of certain operations.
%
%
%% Remark
%
% In the snirf format, and in particular in Homer3 Snirf dataClass object
%the measurement list is a list of Homer3 Snirf MeasListClass objects.
%
% Everytime one needs to access the information about the source and
%detectors involved in a channel. this list has to be navigated, which
%is tedious and costly.
%
% This functions, unfolds the list for quicker access.
%
%
%% Input Parameters
%
% data - A Homer3 Snirf dataClass object. This class is expected
%   to have at least the following 3 attributes;
%   .dataTimeSeries - A matrix of double sized <nSamples,2/3>
%       This is a 2D or 3D array.
%       If it's 3D then: <DATA TIME POINTS> x <DATA TYPES x CHANNELS> 
%           where data types can be wavelengths or chromophores.
%       If it's 2D then: <DATA TIME POINTS> x <Num OF MEASUREMENTS>
%   .time - A matrix of double sized <nSamples,1>
%       This is the vector of timestamps
%   .measurementList - A list of Homer3 Snirf MeasListClass objects
%       Each MeasListClass object contains information about the
%       corresponding source, detector, wavelength or chromophore, etc
%
% OR
%
% measurementList - A list of Homer3 Snirf MeasListClass objects
%       Each MeasListClass object contains information about the
%       corresponding source, detector, wavelength or chromophore, etc
%       e.g. data.measurementList
% 
%
%% Output Parameters
%
% ml - A table of measurements in data.
%   Each column represents an original attribute of the Homer3 Snirf
%   MeasListClass objects composing the data.measurementList.
%   Each row represents one Homer3 Snirf MeasListClass object unfolded.
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
% 10-Apr-2023: FOE
%   + File created.
%

function ml = myHomer3_unfoldMeasurementList(data)

tmpList = data; %Default; the measurement list has been passed directly.
if isa(data,'DataClass')
    tmpList = data.measurementList;
end


%Unfold measurement list for quicker access of some operations below.
nMeasurements = length(tmpList);
tmpSourceIndex     = nan(nMeasurements,1);
tmpDetectorIndex   = nan(nMeasurements,1);
tmpWavelengthIndex = nan(nMeasurements,1);
tmpDataType        = nan(nMeasurements,1);
tmpDataTypeLabel   = cell(nMeasurements,1);
tmpDataTypeIndex   = nan(nMeasurements,1);
tmpSourcePower     = nan(nMeasurements,1);
tmpDetectorGain    = nan(nMeasurements,1);
tmpModuleIndex     = nan(nMeasurements,1);
for iMeas = 1:nMeasurements
    tmpSourceIndex(iMeas)     = tmpList(iMeas).sourceIndex;
    tmpDetectorIndex(iMeas)   = tmpList(iMeas).detectorIndex;
    tmpWavelengthIndex(iMeas) = tmpList(iMeas).wavelengthIndex;
    tmpDataType(iMeas)        = tmpList(iMeas).dataType;
    tmpDataTypeLabel(iMeas)   = {tmpList(iMeas).dataTypeLabel};
    tmpDataTypeIndex(iMeas)   = tmpList(iMeas).dataTypeIndex;
    tmpSourcePower(iMeas)     = tmpList(iMeas).sourcePower;
    tmpDetectorGain(iMeas) = tmpList(iMeas).detectorGain;
    tmpModuleIndex(iMeas) = tmpList(iMeas).moduleIndex;
end
ml = table(tmpSourceIndex,tmpDetectorIndex,...
           tmpWavelengthIndex,tmpDataType,tmpDataTypeLabel,...
           tmpDataTypeIndex,tmpSourcePower,tmpDetectorGain,...
           tmpModuleIndex, ...
           'VariableNames',{'sourceIndex', 'detectorIndex',...
           'wavelengthIndex','dataType','dataTypeLabel',...
           'dataTypeIndex','sourcePower','detectorGain',...
           'moduleIndex'});


end
