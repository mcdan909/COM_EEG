# COM_EEG
EEG processing pipeline

	•	Run ‘PreProcSignedQuartFinal.m’
	•	Set variables to do appropriate time-locking and/or extend window width for TF analyses
	•	This modulates epoch width, baseline period, etc.
	•	Script edits channel labels and adds in photodiode channel to realign event times to stim onset
	•	Script appends behavioral data to generate appropriate event codes based on accuracy and curvature
	•	Script re-references to mastoid channels
	•	Script applies HPF to continuous EEG (0.1 Hz)
	•	Script downsamples data to 250 Hz to reduce file size
	•	Scripts creates bins for ERPLAB and assigns events to bins
	•	Artifact rejection
	•	Script removes trials where peak-to-peak voltage exceeded 200 µV in any 200 ms window (all channels)
	•	Script removes trials containing eye blinks using a step function of 80 µV (Fp1/2, VEOG)
	•	Script removes horizontal eye movements exceeding a 30 µV step function (HEOG)
	•	N. B. 16 µV of deflection corresponds to 1º of eye movement that can contaminate lateral posterior EEG components (e.g., N2pc, CDA)
	•	To be more conservative, HEOG waveforms can be examined to exclude subjects exceeding residual HEOG activity. E.g., residual EOG activity more than 3.2 µV (Woodman and Luck, 2003) means that the residual averaged less than ±0.1º with a propagated voltage of less than 0.1 µV at posterior scalp sites (Lins et al., 1993).
	•	Script removes epochs with blocking (flatlining or amplifier saturation) in which 200 ms worth of data points are within 1 µV of the max
	•	Optional: convert data to current source density (reference-free, spherical spline interpolation) for less volume conduction across electrodes (better with 64+ electrode arrangements)
	•	Script averages waveforms for each event to create condition ERPs
	•	Script applies 30 Hz LPF to averaged waveforms for plotting
	•	N.B. all analyses should be done on datasets with no LPF!



