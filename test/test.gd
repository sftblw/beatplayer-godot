extends Control

signal playback_changed(playback, beat)
signal beatplayer_changed(beatplayer)

export(NodePath) var play_pos_node
onready var PlayPos: SpinBox = get_node(play_pos_node)
export(NodePath) var play_from_pos_node
onready var PlayFromPos: SpinBox = get_node(play_from_pos_node)
onready var logNode: TextEdit = $hbox_all/log

func _ready():
	emit_signal("beatplayer_changed", $BeatPlayer)

func _process(delta):
	# if $BeatPlayer.playing:
	emit_signal("playback_changed", $BeatPlayer.playback_position, $BeatPlayer.beat)
	if $BeatPlayer.playing:
		_beatplayer_log()

func _on_play_btn_pressed():
	$BeatPlayer.play(PlayPos.value)
	logNode.text = ""
	logNode.clear_undo_history()

func _on_play_from_btn_pressed():
	$BeatPlayer.play_from_music_offset(PlayFromPos.value)
	logNode.text = ""
	logNode.clear_undo_history()
	
func _beatplayer_log():
	var ip_text = ("intepolated " + str($BeatPlayer._playback_position_interpolated))
	var ln_text = ("last_known  " + str($BeatPlayer._playback_position_last_known))
	_log_prepend(ip_text)
	_log_prepend(ln_text)
	_log_prepend('--')
	logNode.clear_undo_history()

func _log_prepend(text: String):
	logNode.cursor_set_line(0)
	logNode.cursor_set_column(0)
	logNode.insert_text_at_cursor('\n')
	logNode.cursor_set_line(0)
	logNode.cursor_set_column(0)
	logNode.insert_text_at_cursor(text)

func _on_bpm_edit_text_entered(new_text):
	var new_bpm = float(new_text)
	if new_bpm != null:
		$BeatPlayer.bpm = new_bpm
		emit_signal("beatplayer_changed", $BeatPlayer)


func _on_stop_pressed():
	$BeatPlayer.stop()
