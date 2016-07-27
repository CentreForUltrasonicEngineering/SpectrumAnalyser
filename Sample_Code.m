%% Set the range you wish to view on the spectrum analyser
freq_range = 5e6;

%% Initialise the spectrum analyser
Analyser = HP_Spec();
Analyser.initialise(freq_range);

%% Plot what we see on the screen
while true
    frame = Analyser.getFrame();
    Analyser.plotLastFrame();
end

%% Close the communications channel
Analyser.close();