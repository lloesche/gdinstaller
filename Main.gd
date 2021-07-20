extends Node2D

var installer_uri = "https://raw.githubusercontent.com/lloesche/installer/main/install."
var install_script = OS.get_user_data_dir() + "/install."
var install_log = OS.get_user_data_dir() + "/install.log"
var seek = 0
var windows = false

func _ready():
	flush_tmpfiles()
	if OS.get_name() == "Windows":
		windows = true
		installer_uri += "ps1"
		install_script += "ps1"
	else:
		installer_uri += "sh"
		install_script += "sh"

func _input(event):
	if event.is_action_pressed("ui_quit"):
		get_tree().quit()

func _process(delta):
	var file = File.new()
	var progress = 0
	if $ProgressBar.value < 100 and file.file_exists(install_log):
		var installer_file = File.new()
		var err = installer_file.open(install_log, File.READ)
		if err == 0:
			var current_len = installer_file.get_len()
			if seek != current_len:
				installer_file.seek(seek)
				seek = current_len
				while !installer_file.eof_reached():
					var status = installer_file.get_csv_line()
					if len(status) > 0:
						if status[0] == "PROGRESS":
							progress = int(status[1])
							print("Progress " + str(progress))
							$ProgressBar.value = progress
							if progress == 100:
								$LabelResults.text += "Done\n"
						elif status[0] == "INFO":
							var info = str(status[1])
							$LabelResults.text += info + "\n"
			installer_file.close()


func _http_request_completed(result, response_code, headers, body):
	if response_code != 200:
		push_error("Unexpected response")
		return
	var response = body.get_string_from_utf8()
	print(response)
	var install_script_file = File.new()
	$LabelResults.text += "Writing Installer to " + install_script + "\n"
	install_script_file.open(install_script, File.WRITE)
	install_script_file.store_string(response)
	install_script_file.close()
	var install_script_output = []
	$LabelResults.text += "Running Installer\n"
	var exit_code = 0
	if windows:
		exit_code = OS.execute("powershell.exe", ["-file", install_script], true, install_script_output)
	else:
		exit_code = OS.execute("chmod", ["+x", install_script], true)
		if exit_code == 0:
			exit_code = OS.execute(install_script, [], true, install_script_output)
		else:
			print("Failed to set script permissions " + str(exit_code))
	if exit_code == 0:
		install_log = str(install_script_output[0]).replace("\\", "/").replace("\r", "").replace("\n", "")
		$LabelResults.text += "Reading install status from " + install_log + "\n"


func flush_tmpfiles():
	var dir = Directory.new()
	dir.remove(install_script)
	dir.remove(install_log)


func _on_BtnInstall_released():
	$BtnInstall.disconnect("released", self, "_on_BtnInstall_released")
	$LabelResults.text += "Fetching Installer from " + installer_uri +  "\n"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	var error = http_request.request(installer_uri)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenDrag:
		OS.window_position += event.relative
