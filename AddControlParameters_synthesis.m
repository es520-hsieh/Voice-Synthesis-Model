%% Build a function of applying control parameters of sound level and spectral slope to synthesize sound
function source_signal = AddControlParameters_synthesis(midi_freqs, format_bandwidths_hz, level_dB, slope_dB_per_octave)

    fsamp = 32000;
    totalTime = 1;
    vibAmp = 0.001;
    vibFreq = 6;
    A = -0.8;
    f_0 = 100.0;
    
    % Convert MIDI note number to Frequency in Hertz (Standard tuning reference using A4 = 440 Hz)
    formant_freqs_hz = 440 .* 2.^((midi_freqs - 69)/12);
    
    % Generate a synthesized glottal source signal with harmonic settings
    N_harmonics = floor(fsamp/(2*f_0));
    a_slope = 1.0;

    t = linspace(0.001, totalTime, totalTime*fsamp);
    f_0vib = (1 + (vibAmp ./ t) .* sin(2*pi*vibFreq*t)) * f_0;

    p = zeros(size(t));
    for i = 1 : N_harmonics
        p = p + A*(i^(-a_slope))*sin(2*pi*i*f_0vib .* t);
    end

    % Apply dynamics
    p = p * 10^(level_dB/20); % Adjust sound level
    % Apply spectral slope
    p = p .* (f_0vib.^slope_dB_per_octave); % Apply spectral slope
    
    % Apply effect of formant bandwidths
    qN = formant_freqs_hz ./ format_bandwidths_hz;
    
    % Compute the second order filter coefficients
    T = 1/fsamp;
    for i = 1 : numel(formant_freqs_hz)
        betas(i) = formant_freqs_hz(i)*2*pi;
        beta0s(i) = betas(i)*sqrt(1+1/(4*qN(i)^2));
        alphas(i) = beta0s(i)/(2*qN(i));
        aOnes(i) = -2*exp(-alphas(i)*T)*cos(betas(i)*T);
        aTwos(i) = exp(-2*alphas(i)*T);
        Gs(i) = 1 + aOnes(i) + aTwos(i);
    end

    % Apply the five formant filters with the computed filter coeffeicients
    pOut1 = p;
    pOut2 = p;
    pOut3 = p;
    pOut4 = p;
    pOut5 = p;

    pOut1(1:2) = 0.0;
    for n = 3 : length(pOut1)
        % Apply the recursive filter formula
        pOut1(n) = Gs(1)*pOut1(n) - aOnes(1)*pOut1(n-1) - aTwos(1)*pOut1(n-2);
    end

    pOut2(1:2) = 0.0;
    for n = 3 : length(pOut2)
        % Apply the recursive filter formula
        pOut2(n) = Gs(2)*pOut2(n) - aOnes(2)*pOut2(n-1) - aTwos(2)*pOut2(n-2);
    end

    pOut3(1:2) = 0.0;
    for n = 3 : length(pOut3)
        % Apply the recursive filter formula
        pOut3(n) = Gs(3)*pOut3(n) - aOnes(3)*pOut3(n-1) - aTwos(3)*pOut3(n-2);
    end

    pOut4(1:2) = 0.0;
    for n = 3 : length(pOut4)
        % Apply the recursive filter formula
        pOut4(n) = Gs(4)*pOut4(n) - aOnes(4)*pOut4(n-1) - aTwos(4)*pOut4(n-2);
    end

    pOut5(1:2) = 0.0;
    for n = 3 : length(pOut5)
        % Apply the recursive filter formula
        pOut5(n) = Gs(5)*pOut5(n) - aOnes(5)*pOut5(n-1) - aTwos(5)*pOut5(n-2);
    end
    
    volume = 0.5;
    p = [pOut1, pOut2, pOut3, pOut4, pOut5];

    % Normalize signal
    source_signal = p * volume;
    
end