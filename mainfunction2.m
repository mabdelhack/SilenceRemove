function handles =  mainfunction2(handles,hObject)
set(handles.status, 'String', 'Loading');
workingdir = handles.workingfolder;
soundfiles = handles.soundfiles;
rem = handles.remainingfiles;
handles.w = 1000;
f = handles.f;
auto = get(handles.auto,'Value');
if auto == 1
    loops = length(soundfiles);
else
    loops = f;
end
for l = f:loops
    if rem > 0
        curfile = fullfile(workingdir, soundfiles(l).name);
        [x,fs] = audioread(curfile);
        if (size(x, 2)==2)
            zx = mean(x')';
        else
            zx = x;
        end

        handles.orig = x;
        t = 0:1/fs:length(zx)/fs;
        t = t(1:end-1);
        axes(handles.sound_plot); hold on;
        handles.p(1) = plot(t,zx,'Color',[0.5, 0.5, 0.5]);
        xlim([t(1) , t(end)]);
        set(handles.sound_plot,'XTick',[]);
        [segments, fs, starting, ending] = detectVoiced(curfile,handles.w, handles.prec, handles.trail);
        halfheight = max(abs(zx));
        if halfheight == 0
            halfheight = 1;
        end
        ylim([-halfheight , halfheight]);
        for s = 1:length(segments)
            handles.p(2) = plot(starting(s)/fs:1/fs:ending(s)/fs, segments{s}, 'Color' , [0 , 0, 1]);
            handles.startline(s) = line([starting(s) starting(s)]/fs, [-halfheight , halfheight],'Color' , [0,0,0]);
            handles.endline(s) = line([ending(s) ending(s)]/fs, [-halfheight , halfheight],'Color' , [0,0,0]);
            handles.sttag(s,1) = text([starting(s)]/fs,[halfheight],{'S'}, 'FontSize',6,...
                'HorizontalAlignment','center','VerticalAlignment', 'bottom');
            handles.sttag(s,2) = text([starting(s)]/fs,[-halfheight],{'S'}, 'FontSize',6,...
                'HorizontalAlignment','center','VerticalAlignment', 'top');
            handles.entag(s,1) = text([ending(s)]/fs,[halfheight],{'E'}, 'FontSize',6,...
                'HorizontalAlignment','center','VerticalAlignment', 'bottom');
            handles.entag(s,2) = text([ending(s)]/fs,[-halfheight],{'E'}, 'FontSize',6,...
                'HorizontalAlignment','center','VerticalAlignment', 'top');
            
            handles.starting(s) = starting(s)/fs;
            handles.ending(s) = ending(s)/fs;
        end
        hold off;
        
        handles.allsize = length(t);
        handles.accept = 0;
        handles.out = segments;
        handles.fs = fs;
        handles.player = audioplayer(segments{1}, fs);
        handles.player_orig = audioplayer(x, fs);
        if auto ~= 1
            for s = 1:length(segments)
                handles = play_but(handles,[],s);
                pause(length(segments{s})/fs+0.5);
            end
        else
            for s = 1:length(segments)
                fname  = [curfile(1:end-4), '_' , num2str(s), '.WAV'];
                audiowrite(fname, handles.out{s} , handles.fs,'BitsPerSample',16);
            end
        end
        handles.segsave = 1;
        handles.remainingfiles = rem - 1;

        handles.f = f + 1 ;
        guidata(hObject,handles);
        set(handles.status, 'String', {['File: ' num2str(f) , '/' num2str(length(soundfiles))]; ...
        [soundfiles(f).name]});
    else
        guidata(hObject,handles);
    end
end