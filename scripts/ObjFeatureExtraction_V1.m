% Object Measures
% Ther script measure 3D object properties using the raw image and the
% label images.
%
%
% Notes: This script is written on Linux!! -> if executed on windows: "/" must be changed to "\"!!
                    
% Clear window, close all open images and clear workspace
clc; close all; clear;

%% 1) Choose the source raw input and starDist ouput directroies
% Raw images input path (NOT USED! Keep for intensity features extraction)
rawInputsPath = uigetdir('/media/carloberetta/Data/MATLAB/LiviaAsan',...
    'Choose the input RAW data directory');

if isequal(rawInputsPath, 0)
    disp('> User selected cancel')
    return
else
    % Add and print the input path
    addpath(fullfile(rawInputsPath));
    disp(['> Raw input directory: ', fullfile(rawInputsPath)])
end

% Gets raw data input file list
rawInputsFileList = dir(fullfile(rawInputsPath, '*.tif'));

% ilastik Probability map input path
labelInputPath = uigetdir('/media/carloberetta/Data/MATLAB/LiviaAsan',...
    'Choose the input label starDist directory');

if isequal(labelInputPath, 0)
    disp('> User selected cancel')
    return
else
    % Add and print the input path
    addpath(fullfile(labelInputPath));
    disp(['> starDist label input directory: ', fullfile(labelInputPath)])
end

% Get the ilastik PM input file list
labelInputsFileList = dir(fullfile(labelInputPath, '*.tif'));

% Min object volume size
minVolume = 1500;

%% 2) Created the output directory using the input path
[resultsPath, ~, ~] = fileparts(rawInputsPath);
resultsPath = fullfile(strcat(resultsPath, '/Results', sprintf('_%s', datestr(now,'mm-dd-yyyy_HH-MM-SS'))));
mkdir(resultsPath);
fprintf('> Created the OUTPUT directory: %s\n\n', resultsPath);

%% 3) ###################### Loop through files ######################
for i = 1:size(rawInputsFileList,1)
    
    % Raw and PM input directories must contain the same number of files
    if (size(rawInputsFileList,1) == size(labelInputsFileList,1))
        
        % Get input file path, name and ext and update the user
        disp('##################################################################################');
        [pathstr, name, ext] = fileparts(rawInputsFileList(i).name);
        fprintf('> Processing: %s\n', rawInputsFileList(i).name);
  
        % Create an output directory for each input file to process
        outPutPath = fullfile(strcat(resultsPath, '/', sprintf('%s_%s', 'Results', name)));
        mkdir(outPutPath);
        addpath(outPutPath);
        fprintf('> Created the OUTPUT subdirectory: %s\n\n', outPutPath);
       
        %% Read the label input file
        readLabelStack = ReadTiffstack(fullfile(strcat(labelInputPath, '/', labelInputsFileList(i).name)));
        
        % Change order dimentions LAST
        order = [{2, 1}, num2cell(3:ndims(readLabelStack))];
        readLabelStack = permute(readLabelStack,[order{:}]);
        
        %% Measure object properties in 3D
        geometryMeasures = regionprops3(readLabelStack,...
            {'Volume', 'Centroid', 'EquivDiameter', 'Extent', 'Solidity', 'SurfaceArea'}); 
        
        % Volume filter
        index  = (geometryMeasures.Volume <= minVolume);
        geometryMeasures = geometryMeasures(~index, :);
        
        % Convert table to matrix (volume, x, y, z)
        geometryMeasures = table2array(geometryMeasures);
    
        % Output the statistic in a table
        tableStatistic = array2table(geometryMeasures,...
            'VariableNames', {'Volume', 'Centroid_X', 'Centroid_Y',...
            'Centroid_Z', 'EqDiameter', 'Extent', 'Solidity', 'SurfArea'});
        
        % Save the result table
        outputTable = fullfile(strcat(outPutPath, '/', (sprintf('%s_%s', name,'3D_GeometryMeasures.csv'))));
        writetable(tableStatistic, outputTable, 'Delimiter',' ');        
      
        %% Update the user
        fprintf('> Processed! %s\n', name);

    else
        
        % Exit
        disp("Error! Inconsistent input file list length");
        return
        
    end

end

%% 4) Update the user when all files are processed
fprintf('\n> Total number of file processed: %1d\n', size(rawInputsFileList,1));
disp('> Congratulation! All your file has been successfully processed!');