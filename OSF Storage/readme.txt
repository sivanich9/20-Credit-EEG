This entry contains the data and MATLAB scripts for the article ‘EEG alpha-theta dynamics during mind wandering in the context of breath focus meditation: an experience sampling approach with novice meditation practitioners’

MATLAB scripts
- read_pre_process_and_epoch_EEG.m  = import text file, pre-process EEG data, epoch relative to probe triggers, perform ICA and save matlab file
- read_pre_process_and_epoch_EOG.m  = import text file, pre-process EOG data, epoch relative to probe triggers and save matlab file
- get_behavioral_data.m  = get behavioural data (condition index, confidence and arousal) from text files
- reject_components.m = visualize ICA components per subject to reject manually (uses matlab files with clean EEG and EOG data)
- amplitude_analysis.m = perform short term fft and average across epochs 
- estimate_1f.m  = estimation of 1/f trend of average spectrum 
- findpeaks_analysisnothreshold.m/ findpeaks_analysis1fthreshold.m = estimation of transient peaks and cross-frequency ratios using find peaks approach (without and with amplitude threshold respectively)
- IF_and_PLV.m / IF_and_PLV_withfindpeaks.m= estimation of instantaneous frequency, cross-frequency ratios and phase synchrony (without and with selection of trials respectively)
- Permutation stats (folder) = code to convert data to fieldtrip-friendly structure and perform cluster permutation test (as implemented in fieldtrip) to assess differences between 2 variables of interest

Raw data
- EEG data text files = raw EEG (one column per channel) and trigger information (column 'Event'). Sampling rate is 512hz
- EOG data text files= raw EOG text files including HEOG and VEOG channels. Sampling rate is 2048Hz
*Triggers:
100 = Bell sound
101 = Breath focus answer
102 = Mind wandering answer
The two subsequent triggers indicate the self-reported level of confidence (1 to 7) and arousal (1 to 5) in each answer


Other files
- debriefings after the task (excel files)
- weights_per_epoch_after_rejection.m = condition indexes and weights based on confidence after noisy trials are rejected
- robust_estimation_1f_per_electrodeandsubject_excl_alpha.m = estimation of 1/f per subject (rows) and electrode (columns) (output from estimate_1f.m)  
- EEG21locs = matlab file with channel locations in our EEG set up




