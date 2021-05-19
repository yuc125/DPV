function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0, 'GroupPlots',1, 'GroupPlotIndex',1, …
'Color','b', 'ReturnVars',{''}, 'ArgsOnly',0, 'Cmds','', …
'Boxplot',0);
Args.flags = {'LabelsOff','ArgsOnly','Boxplot'};

[Args,varargin2] = getOptArgs(varargin,Args);

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

if(~isempty(Args.NumericArguments))
		% plot one data set at a time
		n = Args.NumericArguments{1};
plot(obj.data.rates(:,n),'.')
	sdstr = get(obj,'SessionDirs');
	sessionstr = getDataOrder('ShortName','DirString',sdstr{n});
title(sessionstr)
	xlabel('Trial #')
	ylabel('Spike rate (sp/s)')
else
	% plot all data
	plot(obj.data.rates,'.')
	xlabel('Trial #')
	ylabel('Spike rate (sp/s)')
end


% The following code allows any commands to be executed as part of each plot
if(~isempty(Args.Cmds))
    % save the current figure in case Args.Cmds switches to another figure
    h = gcf;
    eval(Args.Cmds)
    % switch back to previous figure
    figure(h);
end

RR = eval('Args.ReturnVars');
lRR = length(RR);
if(lRR>0)
    for i=1:lRR
        RR1{i}=eval(RR{i});
    end 
    varargout = getReturnVal(Args.ReturnVars, RR1);
else
    varargout = {};
end
