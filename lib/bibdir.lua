local lfs = require "lfs"
local files = {}

<<<<<<< HEAD
<<<<<<< HEAD
files.home = os.getenv("HOME")

files.main_folder_path = files.home .. "/.bibliosoph"
lfs.mkdir(files.main_folder_path)
files.scratchpad_file_path = files.main_folder_path .. "/scratchpad"

files.key_folder_path = files.main_folder_path .. "/keys"
lfs.mkdir(files.key_folder_path)
files.key_file_path = files.key_folder_path .. "/keyfile.txt"

files.logs_folder_path = files.main_folder_path .. "/logs"
lfs.mkdir(files.logs_folder_path)
files.log_file_path = files.logs_folder_path .. "/bibliolog.txt"

return files
=======
lfs.mkdir("~/.bibliosoph")
files.main_folder_path = "~/.bibliosoph"
=======
files.home = os.getenv("HOME")
>>>>>>> Actually fixed bibdir.lua, attempting to finish upload_key

files.main_folder_path = files.home .. "/.bibliosoph"
lfs.mkdir(files.main_folder_path)
files.scratchpad_file_path = files.main_folder_path .. "/scratchpad"

files.key_folder_path = files.main_folder_path .. "/keys"
lfs.mkdir(files.key_folder_path)
files.key_file_path = files.key_folder_path .. "/keyfile.txt"

files.logs_folder_path = files.main_folder_path .. "/logs"
<<<<<<< HEAD
<<<<<<< HEAD
files.log_file_path = files.logs_folder_path .. "/" .. os.date("!%t")
>>>>>>> Added initial directory creation script
=======
=======
lfs.mkdir(files.logs_folder_path)
>>>>>>> Actually fixed bibdir.lua, attempting to finish upload_key
files.log_file_path = files.logs_folder_path .. "/bibliolog.txt"

return files
>>>>>>> Forgot some simple stuff
