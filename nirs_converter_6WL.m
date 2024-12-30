% Load SNIRF library (Ensure the SNIRF library is in your MATLAB path)
addpath('D:\softwares\snirf-master'); % Update to the actual path

% Load data
d = load('org_bh_100.txt'); % Combined data (time × measurements)
[r,~]=size(d);
time = 0:120/(r-1):120; % Example time vector with 46 points

numDetectors = 16;
numSources = 4;
numWavelengths = 6;

% Initialize SNIRF Object
snirfObj = SnirfClass(); % Initialize SNIRF object

% Assign MetaDataTags
snirfObj.metaDataTags = MetaDataTagsClass();
snirfObj.metaDataTags.Set('SubjectID', 'Subject001'); % Subject ID
snirfObj.metaDataTags.Set('MeasurementDate', '2024-12-23'); % Measurement date
snirfObj.metaDataTags.Set('MeasurementTime', '12:30:00'); % Measurement time
snirfObj.metaDataTags.Set('Notes', 'data with N = 100'); % Optional notes

% Initialize Probe
snirfObj.probe = ProbeClass();
snirfObj.probe.sourcePos3D = [
    12.07,36.93,0;    % S1
    39.21,36.93, 0;   % S2
    12.07,11.31, 0;   % S3
    39.21,11.31, 0;   % S4
];
snirfObj.probe.detectorPos3D = [
    2.5, 46.12, 0;    % D1
    21.64, 46.12, 0;  % D2
    2.5,27.76, 0;     % D3
    21.64,27.76, 0;   % D4
    29.64, 46.12, 0;  % D5
    48.78,46.12, 0;   % D6
    29.64,27.76, 0;   % D7
    48.78,27.76, 0;   % D8
    2.5,20.5, 0;      % D9
    21.64, 20.5, 0;   % D10
    2.5, 2.12, 0;     % D11
    21.64, 2.12, 0;   % D12
    29.64,20.5, 0;    % D13
    48.78,20.5, 0;    % D14
    29.64, 2.12, 0;   % D15
    48.78,2.12, 0;    % D16
];
snirfObj.probe.wavelengths = [670, 740, 770, 810, 850, 950]; % Corrected wavelengths

% Initialize Data
snirfObj.data = DataClass();

% Assign Measurement List
MeasList = [];
for detIdx = 1:numDetectors
    for srcIdx = 1:numSources
        for wlIdx = 1:numWavelengths
            meas = MeasListClass();
            meas.sourceIndex = srcIdx;
            meas.detectorIndex = detIdx;
            meas.wavelengthIndex = wlIdx;
            meas.dataType = 1; % Raw intensity
            meas.dataTypeIndex = 1; % Fix for all wavelengths appearing in Homer3
            MeasList = [MeasList, meas];
        end
    end
end
snirfObj.data(1).measurementList = MeasList;

% Validate Data Shape
expected_size = length(time) * numSources * numDetectors * numWavelengths;
if size(d, 1) ~= length(time) || size(d, 2) ~= numSources * numDetectors * numWavelengths
    error('Data dimensions do not match the expected size.');
end

% Assign Data
snirfObj.data(1).dataTimeSeries = d;
snirfObj.data(1).time = time';

% Add Stim (Breath Hold Markers)
stimClass = StimClass();
stimClass.name = 'FT';
stimClass.data = [
    40, 10, 1; % Start at 40s, duration 10s, amplitude 1
    90, 10, 1;
    
];
snirfObj.stim = stimClass;

% Save as .snirf
output_path = 'bh_100.snirf';
snirfObj.Save(output_path);
disp(['SNIRF file saved as ', output_path]);
