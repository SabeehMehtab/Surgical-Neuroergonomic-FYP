% Set all paths

baseDir = ['C:' filesep 'Users' filesep 'Lenovo' filesep 'Downloads' filesep 'MSc Project 2023'];
workingDir = [baseDir filesep 'fnirs-processing'];
srcDir = [baseDir filesep 'snirf_converted_raw' filesep];
homerPath = [baseDir filesep 'Homer3-1.80.2'];
preResultsDir = [workingDir filesep 'pre_results'];
postResultsDir = [workingDir filesep 'post_results'];
retResultsDir = [workingDir filesep 'retention_results'];
saveSteps = {'COV'; 'OD'; 'MAcorrection'; 'BPfilter'; 'Conc'; 'Average'};

% Add homer-toolbox, if it is not added to paths already
if ~contains(path,'Homer3')
    addpath(homerPath);
    %call Homer's own path setting
    cd(homerPath);
    setpaths;
    cd(workingDir);
end
  
% Create the results directory if they do not exist
if ~exist(preResultsDir,'dir')
    mkdir(preResultsDir);
    for x=1:length(saveSteps)
        mkdir([preResultsDir filesep saveSteps{x}])
    end
end

if ~exist(postResultsDir,'dir')
    mkdir(postResultsDir);
    for x=1:length(saveSteps)
        mkdir([postResultsDir filesep saveSteps{x}])
    end
end

if ~exist(retResultsDir,'dir')
    mkdir(retResultsDir);
    for x=1:length(saveSteps)
        mkdir([retResultsDir filesep saveSteps{x}])
    end
end

%% Load a subjects data and view its info

% Select session from : '01_Pre','02_Post','03_Retention'
sess = '01_Pre';
% Select Subject
n=12;

if n<10
    fileName = [sess filesep 'Subj00' int2str(n) '_Sess001.snirf'];
    if (strcmp(sess,'01_Pre') == 1) && n==2
        fileName = [sess filesep 'Subj00' int2str(n) '_Sess001b.snirf'];
    end
else
    fileName = [sess filesep 'Subj0' int2str(n) '_Sess001.snirf'];
end

rawData = SnirfClass([srcDir filesep fileName]);
rawData.Info();

%% Plot the data on probe

plotOptions.shortChannelDistance = 15; 
plotOptions.stim = rawData.stim;
[hfig,hBGAxis,hChAxis] = myHomer3_plotSnirfData(rawData.data, rawData.probe, plotOptions);

%% Create a copy of data to work on

tmpData = copy(rawData);
tmpData.stim(:,2) = [];

%% Set the results save folder according to session

if strcmp(sess,'01_Pre') == 1
    resultsDir = preResultsDir;
elseif strcmp(sess,'02_Post') == 1
    resultsDir = postResultsDir;
elseif strcmp(sess,'03_Retention') == 1
    resultsDir = retResultsDir;
else
    error('Choose a valid session')
end

%% Preprocessing Step 1   :   COV Channel Exclusion

% Coefficient of Variation (COV) of each channel
stdData = std(tmpData.data.dataTimeSeries);
meanData = mean(tmpData.data.dataTimeSeries);
covData = 100 * (stdData./meanData);

covMean = mean(covData);
covStd = std(covData);
covMedian = median(covData);

% Threshold calculation
covThresh = ceil(covMean + covStd);
if covThresh > 30
    covThresh = 30;
end

% Check for channels greater than threshold and add them to list
param.measurements = [];
for channel = 1:length(tmpData.data.measurementList)
    if floor(covData(channel)) > covThresh
        param.measurements(end+1) = channel;
    end
end

for x = 1: length(param.measurements)
    ch = param.measurements(x);
    if ch<=62 && ismember(ch+62,param.measurements) == 0
        param.measurements(end+1) = ch+62;
    end
    if ch>62 && ismember(ch-62,param.measurements) == 0
        param.measurements(end+1) = ch-62;
    end
end
param.measurements = sort(param.measurements);

% Drop the channels
tmpData = myHomer3_dropChannels(tmpData, param);

% Plot the output on probe
[hfig,hBGAxis,hChAxis] = myHomer3_plotSnirfData(tmpData.data, tmpData.probe, plotOptions);

% Save output
savePath = [resultsDir filesep 'COV' filesep];
saveFile = strcat(savePath, 'Subject', int2str(n),'_Session1.snirf');
tmpData.Save(saveFile);

%% Preprocessing Step 2    :   Conversion to Optical Densities

output.dod = hmrR_Intensity2OD(tmpData.data);

tmpData.data = copy(output.dod);

% Save output
savePath = [resultsDir filesep 'OD' filesep];
saveFile = strcat(savePath, 'Subject', int2str(n),'_Session1.snirf');
tmpData.Save(saveFile);

%% Preprocessing Step 3   :   Motion Artefact Detection

param.mlActMan = [];
param.mlActAuto = [];
param.tIncMan = [];
param.tMotion = 0.5;
param.tMask = 1; 
param.STDEVthresh = 30; 
param.AMPthresh = 5;
[param.tIncAuto,param.tIncAutoCh] = hmrR_MotionArtifactByChannel(output.dod,tmpData.probe, ...
    param.mlActMan,param.mlActAuto,param.tIncMan,param.tMotion,param.tMask,param.STDEVthresh,param.AMPthresh);
param.tIncAutoCh{1,1} = param.tIncAutoCh{1,1}(1:length(param.tIncAuto{1,1}),:);

% Selecting the channels with motion artefact to be corrected
motionCorCh = find(all(param.tIncAutoCh{1,1} ~= 0));
param.mlActAuto = cell(1,length(tmpData.data.measurementList));
for x = 1: length(tmpData.data.measurementList)
    if ismember(x,motionCorCh) == 1
        param.mlActAuto{1,x} = 1;
    else 
        param.mlActAuto{1,x} = 0;
    end
end

%% Preprocessing Step 4     :    Wavelet Filtering for motion correction
% Takes a while to run (Max 4-5 min)
param.iqr = 1.5;
param.turnon = 1;
output.dodWl = hmrR_MotionCorrectWavelet(output.dod, param.mlActMan, ...
    param.mlActAuto, param.iqr, param.turnon);

%% Plot before and after comparison of wavelet filter 

% Select column
col = 2;
figure;
plot(tmpData.data.time,tmpData.data.dataTimeSeries(:,col))%, 'blue', ...
   % output.dodWl.time,output.dodWl.dataTimeSeries(:,col),'red')
title(['Before Wavelet Correction | Subject ' int2str(n)])
ylabel(sprintf('S%d:D%d Optical Density', ...
    tmpData.data.measurementList(col).sourceIndex, ...
    tmpData.data.measurementList(col).detectorIndex))
xlabel('time')

figure;
plot(output.dodWl.time,output.dodWl.dataTimeSeries(:,col))
title(['After Wavelet Correction | Subject ' int2str(n)])
ylabel(sprintf('S%d:D%d Optical Density', ...
    tmpData.data.measurementList(col).sourceIndex, ...
    tmpData.data.measurementList(col).detectorIndex))
xlabel('time')

%% Save output of Motion Correction
tmpData.data = output.dodWl;
savePath = [resultsDir filesep 'MAcorrection' filesep];
saveFile = strcat(savePath, 'Subject', int2str(n),'_Session1.snirf');
tmpData.Save(saveFile);

%% Preprocessing Step 5    :    Bandpass filter

output.dodBpf = hmrR_BandpassFilt(output.dodWl, 0.00, 0.5);

% Save output
tmpData.data = output.dodBpf;
savePath = [resultsDir filesep 'BPfilter' filesep];
saveFile = strcat(savePath, 'Subject', int2str(n),'_Session1.snirf');
tmpData.Save(saveFile);

%% Plot frequency band before and after BP filter

% Select column
col=3;

L = length(output.dodWl.time);
Fs = 1/output.dodWl.time(2);
f = (Fs/L)*(0:(L/2));

% Before plot
figure;
bw = fft(output.dodWl.dataTimeSeries);
P2 = abs(bw(:,col)/L);
P1 = P2(1:(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f, P1)
title(sprintf('Frequency Band for S%d:D%d | Subject %d', ...
    output.dodWl.measurementList(col).sourceIndex, ...
    output.dodWl.measurementList(col).detectorIndex,n))
ylabel('Amplitude')
xlabel('Frequency')

% After plot
figure;
bw = fft(output.dodBpf.dataTimeSeries);
P2 = abs(bw(:,col)/L);
P1 = P2(1:(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f, P1)
title(sprintf('Frequency Band for S%d:D%d | Subject %d', ...
    output.dodWl.measurementList(col).sourceIndex, ...
    output.dodWl.measurementList(col).detectorIndex,n))
ylabel('Amplitude')
xlabel('Frequency')

%% Preprocessing Step 6      :     Spatial Median filter

numChannels = length(tmpData.data.measurementList);
halfChannels = numChannels/2;
output.dodBpf.dataTimeSeries(:,1:halfChannels) =  medfilt1(tmpData.data.dataTimeSeries(:,1:halfChannels)',5)';
output.dodBpf.dataTimeSeries(:,halfChannels+1:numChannels) =  medfilt1(tmpData.data.dataTimeSeries(:,halfChannels+1:numChannels)',5)';

% Plot on probe
% [hfig,hBGAxis,hChAxis] = myHomer3_plotSnirfData(tmpData.data, tmpData.probe, plotOptions);

%% Preprocessing Step 7     :     Optical Densities to Concentrations
 
output.dc = hmrR_OD2Conc(output.dodBpf, tmpData.probe, [6.00, 6.00]);

% Save output
tmpData.data = output.dc;
savePath = [resultsDir filesep 'Conc' filesep];
saveFile = strcat(savePath, 'Subject', int2str(n),'_Session1.snirf');
tmpData.Save(saveFile);

%% Preprocessing Step 8     :     Block Average

param.trange = [-20 100];
[output.dcAvg, ~, nTrials] = hmrR_BlockAvg(output.dc, tmpData.stim, param.trange);
disp(nTrials)

% Save output
tmpData.data = output.dcAvg;
savePath = [resultsDir filesep 'Average' filesep];
saveFile = strcat(savePath, 'Subject', int2str(n),'_Session1.snirf');
tmpData.Save(saveFile);

% The averaged stim
avgStim = copy(tmpData.stim); 
for iStim = 1:length(tmpData.stim)
    avgStim(iStim).data = [0 50 1];
end

% Plot on probe
plotOptions.stim = avgStim;
[hfig,hBGAxis,hChAxis] = myHomer3_plotSnirfData(tmpData.data, tmpData.probe, plotOptions);
