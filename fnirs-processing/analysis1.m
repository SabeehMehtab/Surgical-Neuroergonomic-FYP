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

%% Select session and subject

% Select session from : '01_Pre','02_Post','03_Retention'
sess = '01_Pre';
% Select Subject
n=12;

%% Load original raw data
if n<10
    fileName = [sess filesep 'Subj00' int2str(n) '_Sess001.snirf'];
    if (strcmp(sess,'01_Pre') == 1) && n==2
        fileName = [sess filesep 'Subj00' int2str(n) '_Sess001b.snirf'];
    end
else
    fileName = [sess filesep 'Subj0' int2str(n) '_Sess001.snirf'];
end

cleanData = SnirfClass([srcDir filesep fileName]);
cleanData.Info();

%% Set the results folder according to session

if strcmp(sess,'01_Pre') == 1
    resultsDir = preResultsDir;
elseif strcmp(sess,'02_Post') == 1
    resultsDir = postResultsDir;
elseif strcmp(sess,'03_Retention') == 1
    resultsDir = retResultsDir;
else
    error('Choose a valid session')
end

%% Load data from results Conc dir

fileName = strcat('Subject', int2str(n),'_Session1.snirf');
filePath = [resultsDir filesep 'Conc' filesep fileName];
cleanData = SnirfClass(filePath);
cleanData.Info();

%% GLM Analysis
mlActAuto = [];
aux = [];
tIncAuto = [];
rcMap = [];
trange = [-20, 50.0];
glmSolveMethod = 1;
idxBasis = 1;
paramsBasis = [1.0 1.0];
rhoSD_ssThresh = 15.0;
flagNuisanceRMethod = 1;
driftOrder = 3;
c_vector = [1 0];

[dcAvg, dcAvgStd, nTrials, dcNew, dcResid, dcSum2, beta, R, hmrstats] = hmrR_GLM(cleanData.data, ...
    cleanData.stim, cleanData.probe, mlActAuto,aux,tIncAuto,rcMap, ...
    trange, glmSolveMethod, idxBasis, paramsBasis, rhoSD_ssThresh, flagNuisanceRMethod, driftOrder, c_vector);

%% Calculate and plot the Gaussian used in regressors

gms = paramsBasis(1);
gstd = paramsBasis(1);

t = cleanData.data.time;
dt = t(2) - t(1);
fq = 1/dt;
nPre = round(trange(1)/dt);
nPost = round(trange(2)/dt);
tHRF = (1*nPre*dt:dt:nPost*dt)';
ntHRF = length(tHRF);
nT = length(t);

nB = floor((trange(2)-trange(1)) / gms) - 1;
tbasis = zeros(ntHRF,nB);

for b=1:nB
    tbasis(:,b) = exp(-(tHRF-(trange(1)+b*gms)).^2/(2*gstd.^2));
    tbasis(:,b) = tbasis(:,b)./max(tbasis(:,b));

end

% Plot
figure;
plot(tHRF,tbasis)
title('Gaussian functions')
xlabel('Block Average time')
ylabel('Magnitude')
