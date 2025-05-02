function rootDir = setup_paths()

    % Get the absolute path to the folder where this script lives
    thisScriptPath = mfilename('fullpath');
    scriptFolder = fileparts(thisScriptPath);

    % Go two levels up to get the project root
    rootDir = fullfile(scriptFolder, '..', '..');

    % Define subfolders relative to root
    helpersPath       = fullfile(rootDir, 'helpers');
    dataRawMatlabPath = fullfile(rootDir, 'data', 'raw', 'matlab');
    dataProcessedPath = fullfile(rootDir, 'data', 'processed');
    resultsPath       = fullfile(rootDir, 'results');

    % Add to path
    addpath(helpersPath);
    addpath(dataRawMatlabPath);
    addpath(dataProcessedPath);
    addpath(resultsPath);

    % Optional: display for confirmation
    fprintf('Paths added:\n');
    disp(helpersPath);
    disp(dataRawMatlabPath);
    disp(dataProcessedPath);
    disp(resultsPath);
end