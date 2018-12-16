function [ handles ] = learn_err( handles )
%learn_err This function applies learning
%   This function receives the error output from the user input
if isfield(handles,'error_st')
    start_err = handles.error_st;
    end_err = handles.error_en;
else
    start_err = 0;
    end_err = 0;
end
lambda = 0.1;
lrnFileName = 'lrn_pars.dat';

% Check if the learning dat file exists:
fp = fopen(lrnFileName, 'r+');
if (fp<0)
	fp = fopen(lrnFileName, 'w');
    prec_in = 0;
    trail_in = 0;
else
    D = csvread(lrnFileName);
    prec_in = D(1);
    trail_in = D(2);
end 
prec_new = prec_in + lambda * start_err;
trail_new = trail_in - lambda * end_err;

handles.prec = prec_new;
handles.trail = trail_new;

M_new = [prec_new , trail_new];
csvwrite(lrnFileName,M_new);


fclose(fp);
end

