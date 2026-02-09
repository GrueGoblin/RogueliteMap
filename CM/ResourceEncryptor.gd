extends Object

class_name ResourceEncryptor

const default_password = "x0dYb19G"

func save_encrypted(resource_path : String, resource : Resource, password := default_password) -> bool:
	var temp_path = resource_path.replace("//","//_")
	var a = ResourceSaver.save(temp_path,resource)
	print(a)
	var temp_file := File.new()
	temp_file.open(temp_path,File.READ)
	var content := temp_file.get_as_text()
	print(content)
	var file := File.new()
	file.open_encrypted_with_pass(resource_path,File.WRITE,password)
	file.store_string(content)
	temp_file.close()
	file.close()
	Directory.new().remove(temp_path)
	return true

func load_encrypted(resource_path : String, password := default_password) -> Resource:
	var file := File.new()
	file.open_encrypted_with_pass(resource_path,File.READ,password)
	var content := file.get_as_text()
	var temp_path = resource_path.replace(".tres","_.tres")
	var temp_file := File.new()
	temp_file.open(temp_path,File.WRITE)
	print(temp_path)
	temp_file.store_string(content)
	temp_file.close()
	file.close()
	var resource = load(temp_path)
	print(resource)
	return resource
