function sss = loadsetparms(fn)
% setparms = loadsetparms(fn)
%
% Read the ranger set file specified by filename fn.  Return as the
% structure setparms.  The set file should have the following syntax:
%
% All blanks lines ignored.
% All lines beginning with # are comment lines and ignored.
% Data lines have a field specifier followed by space characters (space
% or tab) possibly followed by a data value.
% Field specifiers are alphanumeric ascii, plus the underscore, and case
% independent.  They may be terminated by a colon.
% Leading and trailing space on any line is ignored.
%
% The following fields are permitted:
% DATA_FILENAME     <string>
% ROOT_FILENAME     <string>
% CAMERA_TYPE       <string>
% FILE_TYPE         'AVI' | 'TIFF'
% CONSECUTIVE_CAPTURES <integer>
% NUMBER_FRAMES     <integer>
% ACQUISITION_DATE  <ISO8601 date> | <yyyymmddhhmmss>
% VIDEO_MODE        <integer>
% EXPOSURE_MODE     <integer>
% EXPOSURE_TIME     <real>
% EXPOSURE_CONTROL  <integer>
% ANALOG_GAIN       <integer>
% ANALOGUE_GAIN     <integer>
% LEFT_GAIN         <integer>
% RIGHT_GAIN        <integer>
% FRAME_RATE        <real>
% BIN_SIZE          <integer>
% BIT_DEPTH         <integer>
% DUAL_CHANNEL      <boolean>
% PRETRIGGER        <integer>
% REDUCTION_FACTOR  <integer>
% PADDING_SIZE      <integer>
% INVERT_HORIZONTAL <boolean>
% INVERT_VERTICAL   <boolean>
% FRAME_RATE_FTW    <real>
% SYNC_DIVIDER_CODE <integer>
% SHUTTER_WIDTH     <integer>
% In the above <boolean> must be specified as 1 for true and 0 for false.

% (C) 2005 University of Waikato.
% Author: M J Cree

% $Id: loadsetparms.m,v 1.1 2008/03/09 23:47:26 jongenad Exp $

if ~exist(fn, 'file')
  error('loadsetparms:FileNotFound','File %s doesn''t exist',fn);
end

% line number counter for reporting errors
ln = 0;

% Open file
fid = fopen(fn,'rt');
if (fid == -1)
  error('loadsetparms:FileFailToOpen','Couldn''t open %s for reading.', ...
	fn);
end

% Important: parmstrs, parmtypes and parmsyns depend on same order.  If
% insert new keyword into parmstrs, must then update parmtypes and parmsyns.
parmstrs = {'data_filename','root_filename','file_type','number_frames', ...
            'acquisition_date', ...
            'video_mode','exposure_mode','exposure_control','exposure_time', ...
            'analog_gain','left_gain','right_gain', ...
            'actual_frame_rate','bin_size','bit_depth','dual_channel', ...
            'pretrigger','reduction_factor', ...
            'consecutive_captures','invert_horizontal','invert_vertical', ...
            'camera_type', ...
            'frame_rate_ftw','sync_divider_code','shutter_width', ...
            'padding_size','refresh_rate','frame_rate','analogue_gain',};
            
% One entry for each parmstr above.
% 0 = string, 1 = boolean, 2 = integer, 3 = real, -1 = special.
parmtypes = [0, 0, -1, 2, -1, ...	% data_filename, etc.
            2, 2, 2, 3, ...         % video_mode, etc.
            2, 2, 2, ...            % analog_gain, etc.
            3, 2, 2, 1, 2, 2, ...	% actual_frame_rate, etc.
            2, 1, 1, 0, ...         % consecutive_captures, etc.
            3, 2, 2, ...            % frame_rate_ftw, etc.
            2, 3, 3, 2];             % synonyms (place holders)

% One entry for each parmstr above.
% 0 = root word, num >= 1 is index of root word in parmstrs.
parmsyns = [0, 0, 0, 0, 0, ... 		% data_filename, etc.
            0, 0, 0, 0, ...         % video_mode, etc.
            0, 0, 0, ...            % analog_gain, etc.
            0, 0, 0, 0, 0, 0, ...	% frame_rate, etc.
            0, 0, 0, 0, ...         % consecutive_captures, etc.
            0, 0, 0, ...            % frame_rate_ftw, etc.
            0, 13, 13, 10];         % synonyms
            
% Just a check on programming
if (length(parmstrs) ~= length(parmtypes)) ...
      | (length(parmstrs) ~= length(parmsyns))
  error('Inconsistent paramstrs and parmtypes variables.');
end

% Parse file
% For each line in .set file do
while ~feof(fid)
  % Read next line
  str = fgets(fid);
  % If EOF break
  if ~ischar(str)
    break;
  end
  badline = false;
  ln = ln + 1;
  % Strip leading and trailing white space
  str = strtrim(str);
  % If line blank then skip
  if length(str) == 0
    continue;
  end
  % If comment marker then skip
  if str(1) == '#'
    continue;
  end
  % Match first word to field names
  [token, rem] = strtok(str);
  if token(end) == ':'
    token = token(1:end-1);
  end

  idx = strmatch(lower(token), parmstrs, 'exact');
  
  ignore = {'desmear', 'depth_transform', 'base_ftw', 'diff_ftw', ...
      'intensifier_output', 'intensifier_power', 'intensifier_voltage',...
      'shutter_delay', 'shutter_enable','internal_camera_sync_refresh_rate'};
  
  if isempty(idx)
    if ~isempty(strmatch(lower(token), ignore, 'exact'))
        continue;
    else
        fprintf('WARNING: Couldn''t parse line %d of set file %s\n',ln,fn);
        continue;
    end
  end
  % If idx is to a synonym, then remap idx to priority keyword.
  if parmsyns(idx) > 0
    idx = parmsyns(idx);
    % Check for duplicated information 
    if exist('sss', 'var') && isfield(sss, parmstrs(idx))
      fprintf(['WARNING: Multiple synonyms on line %d of set file' ...
	       ' %s\n'],ln,fn);
    end
  end
  % Process parameter of keyword.
  switch parmtypes(idx)
   case -1
    % Special cases
    if isempty(rem)
      fprintf('WARNING: No parameter given on line %d of %s.\n',ln,fn);
      continue;
    end
    if strcmp(parmstrs(idx),'file_type')
      % Must be one of AVI or TIFF
      rem = lower(strtrim(rem));
      if strcmp(rem, 'avi')
	sss.file_type = 'AVI';
      elseif strcmp(rem, 'tif') | strcmp(rem, 'tiff')
	sss.file_type = 'TIFF';
      else
	fprintf('WARNING: Expected TIFF or AVI on line %d of %s.\n', ln, ...
		fn);
	continue;
      end
    elseif strcmp(parmstrs(idx),'acquisition_date')
      % Must be ISO 8601 date or Adrian format date
      rem = strtrim(rem);
      if length(rem) == 8
	% Might be Adrian unspecified date format used in tv study
	yr = str2num(rem(1:4));
	mn = str2num(rem(5:6));
	dy = str2num(rem(7:8));
	hh = 0;
	mm = 0;
	ss = 0;
	if isempty(yr) | isempty(mn) | isempty(dy) 
	  fprintf('WARNING: Expected date on line %d of %s.\n', ln, fn);
	  continue;
	end
	dt = [yr mn dy hh mm ss];
      elseif length(rem) == 14
	% Might be Adrian specified date format
	yr = str2num(rem(1:4));
	mn = str2num(rem(5:6));
	dy = str2num(rem(7:8));
	hh = str2num(rem(9:10));
	mm = str2num(rem(11:12));
	ss = str2num(rem(13:14));
	if isempty(yr) | isempty(mn) | isempty(dy) | isempty(hh) | ...
	      isempty(mm) | isempty(ss)
	  fprintf('WARNING: Expected date on line %d of %s.\n', ln, fn);
	  continue;
	end
	dt = [yr mn dy hh mm ss];
      elseif length(rem) == 15 & rem(9) == 'T'
	% Probably ISO 8601 date, format number 30 of datestr
	% Currently broken because matlab function broken.
	dt = datevec(rem, 30);
      elseif length(rem) == 10 & rem(5) == '-'
	% Probably ISO 8601 date, format number 29 of datestr
	% Currently broken because matlab function broken.
	dt = datevec(rem, 29);
      else
	% Don't recognise date string format
	fprintf('WARNING: Expected date on line %d of %s.\n', ln, fn);
	continue;
      end
      sss.acquisition_date = dt;
    end
   
   case 0
    % Argument is a string
    if isempty(rem)
      fprintf('WARNING: No parameter given on line %d of %s.\n',ln,fn);
      continue;
    end
    sss.(parmstrs{idx}) = strtrim(rem);
   case 1
    % Argument is a boolean, i.e. 0 or 1
    if isempty(rem)
      fprintf('WARNING: No parameter given on line %d of %s.\n',ln,fn);
      continue;
    end
    parm = str2num(rem);
    if isempty(parm) | (parm ~= 0 & parm ~= 1)
      fprintf('WARNING: Expected boolean value on line %d of %s.\n', ln, ...
	      fn);
      continue;
    end
    sss.(parmstrs{idx}) = (parm == 1);
   case 2
    % Argument is an integer
    if isempty(rem)
      fprintf('WARNING: No parameter given on line %d of %s.\n',ln,fn);
      continue;
    end
    parm = str2num(rem);
    if isempty(parm) | (round(parm) ~= parm)
      fprintf('WARNING: Expected integer value on line %d of %s.\n',ln,fn);
      continue;
    end
    sss.(parmstrs{idx}) = parm;
   case 3
    % Argument is a real number
    if isempty(rem)
      fprintf('WARNING: No parameter given on line %d of %s.\n',ln,fn);
      continue;
    end
    parm = str2num(rem);
    if isempty(parm)
      fprintf('WARNING: Expected real value on line %d of %s.\n',ln,fn);
      continue;
    end
    sss.(parmstrs{idx}) = parm;
  end
end
fclose(fid);

% Fix up some problems

% Get rid of directory path in filenames
if isfield(sss,'root_filename')
  % Matlab fileparts routine does not work for us because it is specific to
  % the OS matlab is running under.  Our filenames may have been created on
  % another OS. Using '\' and '/' as path delimiters means this code is
  % valid for both Windows and Unix filename conventions.
  [dl, rm] = strtok(sss.root_filename, '\/');
  pathstr = [];
  while ~isempty(rm)
    if isempty(pathstr)
      pathstr = dl;
    else
      pathstr = [pathstr '/' dl];
    end
    [dl, rm] = strtok(rm, '\/');
  end
  sss.root_dirname = pathstr;
  sss.root_filename = dl;
end

% If consecutive captures is 1 then make data_filename field active with
% complete filename.
if isfield(sss,'consecutive_captures') && sss.consecutive_captures == 1
  if isfield(sss,'file_type') && strncmp(sss.file_type, 'TIF', 3)
    ext = 'tif';
  else
    ext = 'avi';
  end
  sss.data_filename = [sss.root_filename '-01.' ext];
end

  