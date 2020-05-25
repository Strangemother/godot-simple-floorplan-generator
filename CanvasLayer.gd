extends CanvasLayer

signal configure_space

const BASE = "http://127.0.0.1:8000/floorplan/"

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func _on_Button_pressed():
	print('Making request')
	var url = BASE
	var name = $NameEdit.text
	if len(name) != 0:
		url += name + '/'
	$HTTPRequest.request(url)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	#print(json.result)
	emit_signal("configure_space", json.result)

