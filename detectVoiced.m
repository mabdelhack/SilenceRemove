function [segments, fs, starting, ending] = detectVoiced(wavFileName,Weight,prec,trail)

% 
% function [segments, fs] = detectVoiced(wavFileName)
% 
% Theodoros Giannakopoulos
% http://www.di.uoa.gr/~tyiannak
%
% (c) 2010
%
% This function implements a simple voice detector. The algorithm is
% described in more detail, in the readme.pdf file
%
% ARGUMENTS:
%  - wavFileName: the path of the wav file to be analyzed
%  - t: if provided, the detected voiced segments are played and some
%  intermediate results are also ploted
% 
% RETURNS:
%  - segments: a cell array of M elements. M is the total number of
%  detected segments. Each element of the cell array is a vector of audio
%  samples of the respective segment. 
%  - fs: the sampling frequency of the audio signal
%
% EXECUTION EXAMPLE:
%
% [segments, fs] = detectVoiced('example.wav',1);
%
% Modified by Mohamed Abdelhack 2016 - December - 16

Weight = 1e3 * Weight;
if ~exist('prec')
    prec = 0; %s
end
if ~exist('trail')
    trail = 0; %s
end

% Check if the given wav file exists:
fp = fopen(wavFileName, 'rb');
if (fp<0)
	fprintf('The file %s has not been found!\n', wavFileName);
	return;
end 
fclose(fp);

% Check if .wav extension exists:
if  (strcmpi(wavFileName(end-3:end),'.wav'))
    % read the wav file name:
    [x,fs] = audioread(wavFileName);
else
    fprintf('Unknown file type!\n');
    return;
end


% Convert mono to stereo
if (size(x, 2)==2)
	zx = mean(x')';
end

% Window length and step (in seconds):
win = 0.050;
step = 0.050;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  THRESHOLD ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute short-time energy and spectral centroid of the signal:
Eor = ShortTimeEnergy(x, win*fs, step*fs);
Cor = SpectralCentroid(x, win*fs, step*fs, fs);

% Apply median filtering in the feature sequences (twice), using 5 windows:
% (i.e., 250 mseconds)
E = medfilt1(Eor, 5); E = medfilt1(E, 5);
C = medfilt1(Cor, 5); C = medfilt1(C, 5);

% Get the average values of the smoothed feature sequences:
E_mean = mean(E);
Z_mean = mean(C);

% Find energy threshold:
[HistE, X_E] = hist(E, round(length(E) / 1));  % histogram computation
[MaximaE, countMaximaE] = findMaxima(HistE, 3); % find the local maxima of the histogram
if (size(MaximaE,2)>=2) % if at least two local maxima have been found in the histogram:
    T_E = (Weight*X_E(MaximaE(1,1))+X_E(MaximaE(1,2))) / (Weight+1); % ... then compute the threshold as the weighted average between the two first histogram's local maxima.
else
    T_E = E_mean / 2;
end

% Find spectral centroid threshold:
[HistC, X_C] = hist(C, round(length(C) / 1));
[MaximaC, countMaximaC] = findMaxima(HistC, 3);
if (size(MaximaC,2)>=2)
    T_C = (Weight*X_C(MaximaC(1,1))+X_C(MaximaC(1,2))) / (Weight+1);
else
    T_C = Z_mean / 2;
end

% Thresholding:
Flags1 = (E>=T_E);
Flags2 = (C>=T_C);
flags = Flags1 & Flags2;

[MinimaE, countMinimaE] = findMaxima(-E, 5);

if (nargin==2) % plot results:
	clf;
    time = 0:win:(length(Eor)-1) *win;
	subplot(3,1,1); plot(time,Eor, 'g'); hold on; plot(time,E, 'c'); legend({'Short time energy (original)', 'Short time energy (filtered)'});
    L = line([0 length(E)],[T_E T_E]); set(L,'Color',[0 0 0]); set(L, 'LineWidth', 2);
    axis([0 (length(x)-1) / fs min(Eor) max(Eor)]);
	
    subplot(3,1,2); plot(time,Cor, 'g'); hold on; plot(time,C, 'c'); legend({'Spectral Centroid (original)', 'Spectral Centroid (filtered)'});    
	L = line([0 length(C)],[T_C T_C]); set(L,'Color',[0 0 0]); set(L, 'LineWidth', 2);   
    axis([0 (length(x)-1) / fs min(Cor) max(Cor)]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SPEECH SEGMENTS DETECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count = 1;
WIN = 5;
Limits = [];
while (count < length(flags)) % while there are windows to be processed:
	% initilize:
	curX = [];	
	countTemp = 1;
	% while flags=1:
	while ((flags(count)==1) && (count < length(flags)))
		if (countTemp==1) % if this is the first of the current speech segment:
			Limit1 = round((count-WIN)*step*fs)+1-prec*fs; % set start limit:
			if (Limit1<1)	Limit1 = 1; end        
		end	
		count = count + 1; 		% increase overall counter
		countTemp = countTemp + 1;	% increase counter of the CURRENT speech segment
	end

	if (countTemp>1) % if at least one segment has been found in the current loop:
% 		Limit2 = round((count+WIN)*step*fs);			% set end counter
        [MinimaE, countMinimaE] = findMaxima(-E, 5);
        MinimaE = MinimaE(:,MinimaE(1,:)>count+WIN);
        if isempty(MinimaE)
            MinimaE = Inf;
        end
        Limit2 = round(MinimaE(1,1)*step*fs)+trail*fs;			% set end counter
		if (Limit2>length(x))
            Limit2 = length(x);
        end
        
        Limits(end+1, 1) = Limit1;
        Limits(end,   2) = Limit2;
    end
	count = count + 1; % increase overall counter
end

%%%%%%%%%%%%%%%%%%%%%%%
% POST - PROCESS      %
%%%%%%%%%%%%%%%%%%%%%%%

% A. MERGE OVERLAPPING SEGMENTS:
RUN = 1;
while (RUN==1)
    RUN = 0;
    for (i=1:size(Limits,1)-1) % for each segment
        if (Limits(i,2)>=Limits(i+1,1))
            RUN = 1;
            Limits(i,2) = Limits(i+1,2);
            Limits(i+1,:) = [];
            break;
        end
    end
end

% B. Get final segments:
segments = {};


if isempty(Limits)
    starting(1) = 1;
    ending(1) = length(x);
    segments{1} = x(starting:ending);
else
    for (i=1:size(Limits,1))
        if (Limits(i,1)) < 1 && (Limits(i,2)) > length(x)
            starting(i) = 1;
            ending(i) = length(x);
        elseif (Limits(i,1)) < 1
            starting(i) = 1;
            ending(i) = (Limits(i,2));

        elseif (Limits(i,2)) > length(x)
            starting(i) = (Limits(i,1));
            ending(i) = length(x);

        else
            starting(i) = (Limits(i,1));
            ending(i) = (Limits(i,2));

        end
    
        segments{i} = x(starting(i):ending(i));
    end
end

% to be used later
% for (i=1:size(Limits,1))
%     if (Limits(i,1)-prec*fs) < 1
%         starting = 1;
%         ending = (Limits(i,2)+trail*fs);
%         
%     elseif (Limits(i,2)+trail*fs) > length(x)
%         starting = (Limits(i,1)-prec*fs);
%         ending = length(x);
%         
%     else
%         starting = (Limits(i,1)-prec*fs);
%         ending = (Limits(i,2)+trail*fs);
%          
%     end
%     segments{end+1} = x(starting:ending);
% end
% 




if (nargin==2) 
    subplot(3,1,3);
    % Plot results and play segments:
    time = 0:1/fs:(length(x)-1) / fs;
    for (i=1:length(segments))
        hold off;
        P1 = plot(time, x); set(P1, 'Color', [0.7 0.7 0.7]);    
        hold on;
        for (j=1:length(segments))
            if (i~=j)
                timeTemp = starting(j)/fs:1/fs:ending(j)/fs;
                P = plot(timeTemp, segments{j});
                set(P, 'Color', [0.4 0.1 0.1]);
            end
        end
        timeTemp = starting(i)/fs:1/fs:ending(i)/fs;
        P = plot(timeTemp, segments{i});
        set(P, 'Color', [0.9 0.0 0.0]);
        axis([0 time(end) min(x) max(x)]);
        sound(segments{i}, fs);
        clc;
        fprintf('Playing segment %d of %d. Press any key to continue...', i, length(segments));
        pause
    end
    clc
    hold off;
    P1 = plot(time, x); set(P1, 'Color', [0.7 0.7 0.7]);    
    hold on;    
    for (i=1:length(segments))
        for (j=1:length(segments))
            if (i~=j)
                timeTemp = starting(j)/fs:1/fs:ending(j)/fs;
                P = plot(timeTemp, segments{j});
                set(P, 'Color', [0.4 0.1 0.1]);
            end
        end
        axis([0 time(end) min(x) max(x)]);
    end
end