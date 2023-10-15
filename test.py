from subprocess import Popen, PIPE

inputs = ["Man", "Woman", "On_my_god", "__assembly__", ""]
outputs = ["Content", "Oh_my_god", "", "", ""]
errors = ["", "", "Entry not found", "Entry not found", "Input error"]

for i in range(len(inputs)):
	p = Popen("./lab_2", shell=None, stdin=PIPE, stdout=PIPE, stderr=PIPE)
	inp = inputs[i]
	out = outputs[i]
	err = errors[i]
	data = p.communicate(inp + "\n")
	if data[0] == out and data[1] == err:
		print("Passed tests: \"" + inp + "\"")
	else:
		print("Failed tests: \"" + data[0] + "\", stderr: \"" + data[1] + "\". Expected output: \"" + out + "\", stderr: \"" + err + "\"")
