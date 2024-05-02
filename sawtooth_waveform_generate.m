%% Build a function of constructing sinus oscillators and vibrato modulation option to approach sawtooth waveform
function source_signal = sawtooth_waveform_generate(f_0, num_partials)
    
    fsamp = 32000;
    totalTime = 2;

    % Set up vibrato modulation of amplitude and frequency
    vibAmp = 0.001; % Vibrato amplitude
    vibFreq = 6; % Vibrato frequency

    % Dynamics control to approach sawthooth waveform
    sound_level_dB = -20;
    spectral_slope_dB_per_octave = -6; % Spectral slope in set to minus six dB/octave
    t = linspace(0, totalTime, totalTime * fsamp);
    f_0vib = (1 + (vibAmp ./ t) .* sin(2 * pi * vibFreq * t)) * f_0; % Add vibrato modulation effect into fundamental frequency f_0
    source_signal = zeros(size(t));
    for i = 1:num_partials
       partial_freq = i * f_0vib;
       partial_amplitude = 10^((sound_level_dB + (i-1) * spectral_slope_dB_per_octave) / 20);
       source_signal = source_signal + partial_amplitude * sin(2 * pi * partial_freq .* t);
    end

    % Normalize signal
    source_signal = source_signal / max(abs(source_signal));

    % Plot waveform and observe if it is in sawtooth form
    figure;
    plot(t, source_signal);
    title('Generated Waveform with Dynamic Control');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

end