function src = apCallback(src, eventdata)
    myStruct = get(src, 'UserData'); %//Unwrap

    newPlayHeadLoc = ...
        myStruct.playHeadLoc + ...
        + myStruct.frameT;
    set(myStruct.ax, 'XData', [newPlayHeadLoc newPlayHeadLoc])
    
    myStruct.playHeadLoc = newPlayHeadLoc;
    set(src, 'UserData', myStruct); %//Rewrap
end