% MAIN is the main routine to be run for data conditioning and machine 
% learning aspect of the project. MAIN will check for existing files 
% containing variables, in order to speed up processing time. The output 
% of MAIN most interesting to the project is: 
%
%   predTest - The predicted k-values of the main set of data
%   predTrain - The predicted k-values of the training data
%   rms - the mean deviation from the actual values of k

clear all;
clc;

help main
pause(2)

%% Overwrite config
% Setting any of these to 1 (true) will force that subroutine to overwrite
% any data from previous runs, saving the new variables to disk. Setting
% overwrite_all to true will imply a true setting for all others.

overwrite_all = 0;

overwrite_prep = 0;
overwrite_splice = 0;
overwrite_choose = 0;
overwrite_learning = 0;
overwrite_prediction = 0;

overwrite_learning = 1;
overwrite_prediction = 1;

%% Subroutine calls
% This section calls the individual subroutines responsible for the
% handling of the actual data. The *.m files will need to be either in the
% working folder or the MATLAB path. Each module outputs variables to both
% the workspace and the disk, in the form of individual files i.e. one file
% for each sub.

% Preperatory call handles initial training data and runs parallel
% computing pool to poll computer capabilities. This increases performance
% of the treebagger method.
if ~exist('prep_vars.mat', 'file') || overwrite_all || overwrite_prep
    [k_value, pot_ref_1, pot_ref_2, data_1_in, data_2_in,...
        data_1_out, data_2_out] = prep();

    save('prep_vars.mat','k_value', 'pot_ref_1', 'pot_ref_2', ...
        'data_1_in', 'data_2_in', 'data_1_out', 'data_2_out')
else
    disp('Using existing values from previous run of prep()')
    load('prep_vars.mat')
end

% Splice section takes individual files for which predictions will be made,
% and splices them together into a single dataset, in the form of some MxN
% matrix with M samples of N variables.
if ~exist('splice_vars.mat', 'file') || overwrite_all || overwrite_splice
    [InputData, potentialOfInputs] = splice();

    save('splice_vars.mat','InputData','potentialOfInputs');
else
    disp('Using existing values from previous run of splice()');
    load('splice_vars.mat')
end

% This part finds the voltage ranges common to all datasets and crops the
% common part to training data. 
if ~exist('choose_vars.mat', 'file') || overwrite_all || overwrite_choose
    [InputTrain, OutputTrain, InputTest] = ...
        choose(pot_ref_1, pot_ref_2, potentialOfInputs, data_1_in, ...
        data_2_in, InputData, data_1_out, data_2_out);

    save('choose_vars.mat', 'InputTrain', 'OutputTrain', 'InputTest')
else
    disp('Using existing values from previous run of choose()')
    load('choose_vars.mat')
end

% This is where the treebagger and neural network are run. This part also
% checks whether the capability of the computer was run initially.
if ~exist('learning_vars.mat', 'file') ...
        || overwrite_all || overwrite_learning
    b = learning(InputTrain, OutputTrain);

    save('learning_vars.mat','b')
else
    disp('Using existing values from previous run of learning()');
    load('learning_vars.mat')
end

% This uses the regression data found in the learning section to predict
% the k values of the larger dataset. It also calculates the RMS error of
% the method.
if ~exist('prediction_vars.mat', 'file') ...
        || overwrite_all || overwrite_prediction
    [predTrain, predTest, rms] = ...
        prediction(b, InputTrain, InputTest, k_value);

    save('prediction_vars.mat', 'predTrain', 'predTest','rms')
else
    disp('Using existing values from previous run of prediction()');
    load('prediction_vars.mat')
end
