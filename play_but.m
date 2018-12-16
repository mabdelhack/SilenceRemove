function handles = play_but(handles,newpos,seg)

axes(handles.sound_plot); hold on;
mag = ylim;
frameT = 1/10;
tog = get(handles.orig_rad,'Value');
if  tog == 1 && ~exist('ov','var') && ~exist('newpos','var')
    playHeadLoc = handles.out{seg}(1);
elseif exist('newpos','var') && ~isempty(newpos) && newpos > 0
    
    playHeadLoc = newpos;
    
else
    playHeadLoc = handles.starting(seg);
end

ax1 = plot([playHeadLoc playHeadLoc], mag, 'r', 'LineWidth', 2);
myStruct.playHeadLoc = playHeadLoc;
myStruct.frameT = frameT;
myStruct.ax = ax1;




set(handles.player_orig, 'UserData', myStruct);
set(handles.player_orig, 'TimerFcn', @apCallback);
set(handles.player_orig, 'TimerPeriod', frameT);
set(handles.player_orig, 'StopFcn', @clax);




if  tog == 1
    
    if ~isplaying(handles.player_orig)
        set(handles.playbut,'UserData',0);
        play(handles.player_orig,floor(playHeadLoc*handles.fs));
    else
        stop(handles.player_orig);
        StopTimer(handles)
        set(handles.playbut,'UserData',1);
    end
else
    if ~isplaying(handles.player_orig)
        
        
        set(handles.playbut,'UserData',0);
        play(handles.player_orig, floor([playHeadLoc, handles.ending(seg)]*handles.fs));
        
    else
        stop(handles.player_orig);
        StopTimer(handles)
        set(handles.playbut,'UserData',1);
    end
end

end

function src = clax(src, eventdata)
    myStruct = get(src, 'UserData'); %//Unwrap
    set(myStruct.ax, 'Xdata', [-1 -1]);
    set(src, 'UserData', myStruct); %//Rewrap
end