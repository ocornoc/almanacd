local lfs = require "lfs"
local files = {}

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

lfs.chdir(files.folder_path)

lfs.mkdir("./keys")
files.key_folder_path = files.main_folder_path .. "/keys"
files.key_file_path = files.key_folder_path .. "/keyfile"

lfs.mkdir("./logs")
files.logs_folder_path = files.main_folder_path .. "/logs"
<<<<<<< HEAD
files.log_file_path = files.logs_folder_path .. "/" .. os.date("!%t")
>>>>>>> Added initial directory creation script
=======
files.log_file_path = files.logs_folder_path .. "/bibliolog.txt"

return files
>>>>>>> Forgot some simple stuff
