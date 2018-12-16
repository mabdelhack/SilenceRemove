function handles = play_but1(handles)

axes(handles.fin); hold on;
mag = ylim;
frameT = 1/10;

playHeadLoc = 0;

ax1 = plot([playHeadLoc playHeadLoc], mag, 'r', 'LineWidth', 2);
myStruct.playHeadLoc = playHeadLoc;
myStruct.frameT = frameT;
myStruct.ax = ax1;


set(handles.plfin, 'UserData', myStruct);
set(handles.plfin, 'TimerFcn', @apCallback);
set(handles.plfin, 'TimerPeriod', frameT);
set(handles.plfin, 'StopFcn', @clax);




play(handles.plfin);


end

function src = clax(src, eventdata)
    myStruct = get(src, 'UserData'); %//Unwrap
    set(myStruct.ax, 'Xdata', [-1 -1]);
    set(src, 'UserData', myStruct); %//Rewrap
end