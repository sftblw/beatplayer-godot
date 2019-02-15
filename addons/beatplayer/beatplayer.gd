extends AudioStreamPlayer

# # brief
# beatplayer is simple stream player for rhythm games which wraps AudioStreamPlayer.
#
# - interpolated offset with process() → don't manually enable or disable processing.
# - knowledge of bpm and beat
# - supports minus playback offset

var playback_position setget _set_playback_position, get_playback_position
var _playback_position_last_known = 0
var _playback_position_interpolated = 0 # interpolated offset by physics_process or process

export(float) var bpm = 100.0 # this can be set anytime since this value dosesn't affect other variables

export(float) var offset = 0.0 # beat calculation offset in second. does not affect to playback position
var beat setget set_beat, get_beat # calculated value!

export(float) var lerp_val = 0.5
export(float) var pop_filter = 0.8

##################
# setter, getter #
##################

func set_beat(beat):
	var beat_per_second = (bpm / 60.0)
	self.playback_position = beat / beat_per_second
func get_beat():
	var beat_per_second = (bpm / 60.0)
	return (self.playback_position) * beat_per_second

# this doesn't set seek
func _set_playback_position(playback_position):
	_playback_position_last_known = playback_position
	_playback_position_interpolated = playback_position
	
func get_playback_position(): return _playback_position_interpolated

############
# utillity #
############

func beat_to_playback(beat):
	var beat_per_second = (bpm / 60.0)
	return beat / beat_per_second
	
func playback_to_beat(playback_pos):
	var beat_per_second = (bpm / 60.0)
	return (playback_pos) * beat_per_second

##################################
# overrides of AudioStreamPlayer #
##################################

func play_absolute(from_position = 0.0):
	.play(from_position - offset)

func play(from_position = 0.0):
	if self.stream == null:
		return
		
	self.playback_position = from_position
	if from_position + offset >= 0.0:
		.play(from_position + offset)
	set_process(true)

func seek(to_position):
	self.playback_position = to_position
	if to_position + offset < 0.0:
		set_process(true)
		.stop()
	else:
		.seek(to_position + offset)

func seek_to_beat(beat):
	self.beat = beat # this calls setter and changes playback_position
	self.seek(self.playback_position)
	
func stop():
	.stop()
	set_process(false)
	
#####################
# overrides of Node #
#####################

func _ready():
	connect("finished", self, "_finished")
	set_process(false) # it seems like AudioStreamPlayer automatically sets processing to true

func _process(delta):
	_interpolate_playback_position(delta)

###############
# own methods #
###############

func _interpolate_playback_position(delta):
	# update new virtual playback position
	_playback_position_interpolated += delta
	
	if not _playback_position_interpolated < 0.0:
		# if processing but not playing, play it
		if not playing:
			.play(0)
			return

		# if actual playback pos is changed, apply it
		var super_pos = .get_playback_position() - offset
		if super_pos != _playback_position_last_known and super_pos != 0.0: # 0.0 when started. we ignore that
			_playback_position_last_known = super_pos
			
			# when popped up value occured
			if pop_filter != 0.0 and abs(_playback_position_interpolated - super_pos) > pop_filter:
				return
			
			# update _playback_position_interpolated by [lerp or not]
			if lerp_val != 0.0:
				var lerp_pos = lerp(super_pos, _playback_position_interpolated, pow(lerp_val, delta))
				_playback_position_interpolated = lerp_pos
			else:
				_playback_position_interpolated = super_pos

func _finished():
	self.playback_position = .get_playback_position()
	set_process(false)