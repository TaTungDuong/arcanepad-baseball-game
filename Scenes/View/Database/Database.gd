extends Node2D

var file_path = "res://index.txt"

func read_record(table_name: String):
	var result = []
	var file = File.new()
	file.open(file_path, File.READ)
	var record = file.get_as_text()
	file.close()

	var lines = record.split("\n")
	if lines.size() == 2:
		var score = lines[0].to_int()
		var distance = lines[1].to_float()
		if score != null and distance != null:
			if table_name == "Score":
				result.append({"Score": score})
			if table_name == "Distance":
				result.append({"Distance": distance})
	return result

func edit_record(table_name: String, value):
	var file = File.new()
	if file.open(file_path, File.READ) == OK:
		# Read the content of the file
		var content = file.get_as_text()
		file.close()

		# Split content into lines
		var lines = content.split("\n")
		# Update the corresponding line based on the table_name
		if table_name == "Score":
			lines[0] = str(value)
		elif table_name == "Distance":
			lines[1] = str(value)
		# Open the file for writing
		if file.open(file_path, File.WRITE) == OK:
			# Write the updated content to the file
			file.store_string(lines.join("\n"))
			file.close()

func table_of_score():
	return read_record("Score")

func update_score(_name: String, score: int):
	edit_record("Score", score)

func table_of_distance():
	return read_record("Distance")

func update_distance(_name: String, distance: float):
	edit_record("Distance", distance)




