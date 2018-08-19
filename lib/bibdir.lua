local lfs = require "lfs"
local files = {}

lfs.mkdir("~/.bibliosoph")
files.main_folder_path = "~/.bibliosoph"

lfs.chdir(files.folder_path)

lfs.mkdir("./keys")
files.key_folder_path = files.main_folder_path .. "/keys"
files.key_file_path = files.key_folder_path .. "/keyfile"

lfs.mkdir("./logs")
files.logs_folder_path = files.main_folder_path .. "/logs"
files.log_file_path = files.logs_folder_path .. "/bibliolog.txt"

return files
