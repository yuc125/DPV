function [obj, varargout] = vmspikerates(varargin)
%@dirfiles Constructor function for DIRFILES class
%   OBJ = dirfiles(varargin)
%
%   OBJ = dirfiles('auto') attempts to create a DIRFILES object by ...
%   
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on dirfiles %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Example [as, Args] = dirfiles('save','redo')
%
%   Dependencies: 

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0, 'ObjectLevel', 'Session');
Args.flags = {'Auto','ArgsOnly'};
% Specify which arguments should be checked when comparing saved objects
% to objects that are being asked for. Only arguments that affect the data
% saved in objects should be listed here.
Args.DataCheckArgs = {};                            

[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'vmspikerates';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'df';

% To decide the method to create or load the object
[command,robj] = checkObjCreate('ArgsC',Args,'narginC',nargin,'firstVarargin',varargin);

if(strcmp(command,'createEmptyObjArgs'))
    varargout{1} = {'Args',Args};
    obj = createEmptyObject(Args);
elseif(strcmp(command,'createEmptyObj'))
    obj = createEmptyObject(Args);
elseif(strcmp(command,'passedObj'))
    obj = varargin{1};
elseif(strcmp(command,'loadObj'))
    % l = load(Args.matname);
    % obj = eval(['l.' Args.matvarname]);
	obj = robj;
elseif(strcmp(command,'createObj'))
    % IMPORTANT NOTICE!!! 
    % If there is additional requirements for creating the object, add
    % whatever needed here
    obj = createObject(Args,modvarargin{:});
end

function obj = createObject(Args,varargin)

% look for spiketrains file
    dlist = nptDir('spiketrain.mat');
    % get entries in directory list
    dnum = size(dlist,1);
    % load rplparallel object
    % the constructor function for rplparallel will automatically 
    % change to the session directory to attempt to load the saved
    % object
    rp = rplparallel('auto',varargin{:});
 
    % continue only if both required files are present
    if( (dnum>0) && (~isempty(rp)) )
    % load the spiketrains
    l = load(dlist(1).name);
    % we are going to compute spike counts using the histcounts
    % function there are 3 marker times per trial: 1) cue onset, 
    % 2) cue offset, and 3) reward/time-out. But since we are
    % only interested in the counts between the 2nd and 3rd
    % markers, we will use only those values to create the
    % histcounts bins by extracting the 2nd and 3rd columns
    % transposing the values, and then converting the values to a
    % column vector
    timestamps = rp.data.timeStamps(:,2:3)';
    hbins = reshape(timestamps,[],1);
    % count spikes between marker times
    % need to divide timestamps by 1000 as rplparallel timestamps are
    % seconds while spiketrain timestamps are in milliseconds
    hcounts = histcounts(l.timestamps/1000,hbins');
    % reshape hcounts into 2 rows so we can discard the counts 
    % between the 3rd marker of 1 trial and the 2nd marker of the
    % next trial
    hcounts2 = reshape([hcounts 0],2,[]);
    % we will need the corresponding time intervals to compute
    % spike rate    we will then store the remaining spike counts in
    % the object
    data.rates = hcounts2(1,:)' ./ diff(timestamps)';
    data.avgrate = mean(data.rates);

	
	% create nptdata so we can inherit from it
	data.numSets = 1;    
    data.Args = Args;
	n = nptdata(data.numSets,0,pwd);
	d.data = data;
	obj = class(d,Args.classname,n);
	saveObject(obj,'ArgsC',Args);
else
	% create empty object
	obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

% these are object specific fields
data.dlist = [];
data.setIndex = [];

% create nptdata so we can inherit from it
% useful fields for most objects
data.numSets = 0;
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
