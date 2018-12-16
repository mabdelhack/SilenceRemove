%----------------------------------------------------------------------------
function StopTimer(handles)
try
	
    listofplots =  findobj(handles.sound_plot,'Type','line','-and','Color','r');
    delete(listofplots);
	
	
catch ME
	errorMessage = sprintf('Error in StopTimer().\nThe error reported by MATLAB is:\n\n%s', ME.message);
	fprintf('%s\n', errorMessage);

end
return; % from btnStopTimer_Callback