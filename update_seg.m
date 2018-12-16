function handles = update_seg(handles)
handles.error_st = 0; handles.error_en =0;
if isfield(handles,'segmv')
    s = handles.segmv;
else
    s = 1;
end
if s>1
    prev_en = handles.ending(s-1);
else
    prev_en = 0;
end
if s < length(handles.out)
    next_st = handles.starting(s+1);
else
    next_st = Inf;
end

newpos_st = get(handles.startline(s), 'xdata');
next = find(handles.orig(floor(newpos_st(1)*handles.fs))*handles.orig(floor(newpos_st(1)*handles.fs)+1:end) <= 0);
newpos_st = newpos_st + next(1)/handles.fs;
newpos_en = get(handles.endline(s), 'xdata');
next = find(handles.orig(floor(newpos_en(1)*handles.fs))*handles.orig(floor(newpos_en(1)*handles.fs)+1:end) <= 0);
newpos_en = newpos_en + next(1)/handles.fs;

if newpos_st < prev_en
    merge  = mergediag();
    if  merge == 'Yes'
        
        handles.out(s) = [];
        handles.ending(s-1) = handles.ending(s);
        handles.ending(s) = [];
        delete(handles.startline(s));
        delete(handles.endline(s-1));
        handles.startline(s) = [];
        handles.endline(s-1) = [];
        handles.starting(s) = [];
        newpos_st = handles.starting(s-1);
        
        s = s-1;
    end
end

if newpos_en > next_st
    merge  = mergediag();
    if merge == 'Yes'
        
        handles.out(s) = [];
        handles.ending(s) = handles.ending(s+1);
        handles.ending(s+1) = [];
        handles.starting(s+1) = [];
        delete(handles.startline(s+1));
        delete(handles.endline(s));
        handles.endline(s) = [];
        handles.startline(s+1) = [];
%         newpos_st = handles.starting(s);
        newpos_en = handles.ending(s);
        
    end
end

handles.error_st = handles.error_st + handles.starting(s) - newpos_st(1);
handles.error_en = handles.error_en + handles.ending(s) - newpos_en(1);
handles.out{s} = handles.orig(floor(newpos_st*handles.fs): floor(newpos_en*handles.fs));
handles.starting(s) = newpos_st(1);
handles.ending(s) = newpos_en(1);

    if handles.error_st ~= 0 || handles.error_en ~= 0
        axes(handles.sound_plot); hold on;
        t1 = 0:1/handles.fs:length(handles.orig)/handles.fs;
        t1 = t1(1:end-1);
        plot(t1,handles.orig,'Color',[0.5, 0.5, 0.5]);
        
        for st = 1:length(handles.out)
            t = handles.starting(st):1/handles.fs:handles.ending(st);
            if length(handles.out{st}) > length(t)
                handles.out{st} = handles.out{st}(1:end-1);
            elseif length(handles.out{st}) < length(t)
                t = t(1:end-1);
            end
                           
            plot(t,handles.out{st}, 'Color' , [0 , 0, 1]);
            
        end
%         s = handles.segmv; 
        t = handles.starting(s):1/handles.fs:handles.ending(s);
        if length(handles.out{s}) > length(t)
            handles.out{s} = handles.out{s}(1:end-1);
        elseif length(handles.out{s}) < length(t)
            t = t(1:end-1);
        end
        plot(t,handles.out{s}, 'Color' , [0 , 1, 0]);
        handles.player = audioplayer(handles.out{s}, handles.fs);
        handles = play_but(handles, handles.starting(s),s);
        pause(length(handles.out{s})/handles.fs+0.5);
        plot(t,handles.out{s}, 'Color' , [0 , 0, 1]);
    end
end