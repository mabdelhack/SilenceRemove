windowlength = 1 * fs;
figure;
for i = 1:(length(data) - windowlength + 1)
    windowed = data(i:i+windowlength-1);
    vol(i) = mean(abs(windowed));
    if mod(i,1000) == 0
        plot(abs(windowed)); drawnow;
    end
end

figure;
plot(5*vol,'b'); hold on;
plot(data,'g'); 

std(vol)/max(vol)