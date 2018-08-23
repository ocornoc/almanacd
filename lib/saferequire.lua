return function(path)
	local lib
	local status, err = pcall(function() lib = require(path) end)
	
	return status and lib 
end
