local safereq = require "saferequire"
local fs = safereq "lfs"
local fsname
local files = {}

if fs then
	fsname = "lfs"
else
	fs = safereq "love"
	
	assert(fs, "Cannot find either love.filesystem or luafilesystem. At least one must be installed!")
	
	fs = fs.filesystem
	fsname = "love"
end

local append = ""
local fileappend = ""
local original_place

if fsname == "lfs" then
	append = os.getenv("HOME"):gsub("[/\\]$", "", 1) .. "/"
	fileappend = append
	original_place = fs.currentdir()
	fs.chdir(append)
elseif fsname == "love" then
	append = ""
	fileappend = fs.getSaveDirectory()
	fs.mkdir = fs.createDirectory
end

files.main_folder_path = append .. ".bibliosoph/"
files.main_folder_path_long = fileappend .. ".bibliosoph/"
fs.mkdir(files.main_folder_path)
files.scratchpad_file_path = files.main_folder_path_long .. "scratchpad"

files.key_folder_path = files.main_folder_path .. "keys"
files.key_folder_path_long = files.main_folder_path_long .. "keys"
fs.mkdir(files.key_folder_path)
files.key_file_path = files.key_folder_path_long .. "keyfile.txt"

files.logs_folder_path = files.main_folder_path .. "logs"
files.logs_folder_path_long = files.main_folder_path_long .. "logs"
fs.mkdir(files.logs_folder_path)
files.log_file_path = files.logs_folder_path_long .. "bibliolog.txt"

if fsname == "lfs" then
	fs.chdir(original_place)
end

return files
