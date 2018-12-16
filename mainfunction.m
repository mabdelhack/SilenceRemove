function handles =  mainfunction(handles,hObject)
set(handles.status, 'String', 'Loading');
workingdir = handles.workingfolder;
soundfiles = handles.soundfiles;
rem = handles.remainingfiles;
handles.w = 1000;
f = handles.f;
if rem > 0
    curfile = fullfile(workingdir, soundfiles(f).name);
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
    set(handles.sound_plot,'XTick',0:(floor(t(end)/10)+1):floor(t(end)));
    [segments, fs, starting, ending] = detectVoiced(curfile,handles.w, handles.prec, handles.trail);
    for s = 1:length(segments)
        handles.p(2) = plot(starting/fs:1/fs:ending/fs, segments{s}, 'Color' , [0 , 0, 1]);
    end
    hold off;
    halfheight = max(abs(zx));
    ylim([-halfheight , halfheight]);
    handles.startline = line([starting starting]/fs, [-halfheight , halfheight],'Color' , [0,0,0]);
    handles.endline = line([ending ending]/fs, [-halfheight , halfheight],'Color' , [0,0,0]);
    handles.starting = starting/fs;
    handles.ending = ending/fs;
    handles.allsize = length(t);
    handles.accept = 0;
    handles.out = segments{1};
    handles.fs = fs;
    handles.player = audioplayer(segments{1}, fs);
    handles.player_orig = audioplayer(x, fs);
    handles = play_but(handles);
    
    handles.remainingfiles = rem - 1;
    
    handles.f = f + 1 ;
    guidata(hObject,handles);
    set(handles.status, 'String', {['File: ' num2str(f) , '/' num2str(length(soundfiles))]; ...
        [soundfiles(f).name]});
else
    guidata(hObject,handles);
end
