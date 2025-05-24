% Define main directories
clear all
close all
base_dir = 'D:\Data\Human\ObjectCategorization'; % Adjust path accordingly
behavior_dir = fullfile(base_dir, 'data_defaced','derivatives','behaviours');
analysis_dir = fullfile(base_dir, 'analysis2');

% Get list of subjects
subjects = dir(fullfile(behavior_dir, 'sub-*'));
subjects = {subjects.name};

% Loop through subjects
for subj_idx = 1:length(subjects)
    subject = subjects{subj_idx};

    % Get list of sessions
    sessions = dir(fullfile(behavior_dir, subject, 'ses-*'));
    sessions = {sessions.name};
    sess_idx = 2;
    session = sessions{sess_idx};

    % Get list of runs
    runs = dir(fullfile(behavior_dir, subject, session, 'func/*.mat'));
    runs = {runs.name};

    for run_idx = 1:length(runs)
        run = runs{run_idx};

        % Find behavior file
        behavior_file = fullfile(behavior_dir, subject, session, 'func', run);

        if exist(behavior_file, 'file')
            % Load data
            load(behavior_file);

            % Extract required variables
            stim_onset = data.trials.Stim_Onset - (5 * 2); % Adjust for 5 dummy scans (TR = 2s)
            iti_onset = data.trials.ITI_Onset - (5 * 2);   % Adjust ITI timing accordingly
            accuracy = data.results.accuracy;
            response_time = data.results.time_Response;
            category = data.trials.Object_Category;
            motor_onset = response_time - (5 * 2); % Adjust for dummy scans

            % Compute stimulus duration
            stim_duration = iti_onset - stim_onset;
            motor_duration = zeros(size(motor_onset)); % Fast response -> duration = 0

            % Identify correct and incorrect responses
            correct_idx = accuracy == 1;
            error_idx = accuracy == 0;

            % Separate by category
            category1_idx = correct_idx & (category == 1);
            category2_idx = correct_idx & (category == 2);

            % Create EV files with appropriate third column values
            correct_ev = [stim_onset(correct_idx), stim_duration(correct_idx), ones(sum(correct_idx),1)];
            error_ev = [stim_onset(error_idx), stim_duration(error_idx), ones(sum(error_idx),1)];

            category1_ev = [stim_onset(category1_idx), stim_duration(category1_idx), ones(sum(category1_idx),1)];
            category2_ev = [stim_onset(category2_idx), stim_duration(category2_idx), ones(sum(category2_idx),1)];

            motor_ev = [motor_onset, motor_duration, ones(size(motor_onset))]; % Motor response EV (third column = 1)

            % Define output directory in analysis folder
            run_info = regexp(run, 'run-\d+', 'match', 'once');

            output_dir = fullfile(analysis_dir, subject, session, 'func',run_info);
            if ~exist(output_dir, 'dir')
                disp(['There is no folder: ', output_dir]);
            end

            % Save EV files to analysis folder within run directory
            writematrix(correct_ev, fullfile(output_dir, 'Correct_Responses_Category1&2.txt'), 'Delimiter', ' ');
            writematrix(error_ev, fullfile(output_dir, 'Error_Responses.txt'), 'Delimiter', ' ');
            writematrix(category1_ev, fullfile(output_dir, 'Correct_Category1.txt'), 'Delimiter', ' ');
            writematrix(category2_ev, fullfile(output_dir, 'Correct_Category2.txt'), 'Delimiter', ' ');
            writematrix(motor_ev, fullfile(output_dir, 'Motor_Response.txt'), 'Delimiter', ' ');

            disp(['Processed and saved EVs for ', subject, ', ', session, ', ', run_info]);
        else
            disp(['Missing file: ', behavior_file]);
        end
    end
end
