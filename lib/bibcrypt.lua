---- Dependencies ---------------------------------------------
local json = require "cjson"
local ltn12 = require "ltn12"
local mime = require "mime"
local salut = require "salut"

local bibcrypt = {}
bibcrypt.construct = {}
bibcrypt.deconstruct = {}
bibcrypt.verify = {}

---- Object Construction --------------------------------------
function bibcrypt.construct.aeskey()
	
end

function bibcrypt.construct.authregister(pubkey, aeskey, aesnonce)
	assert(type(pubkey) == "string", "'pubkey' field must be a string (was a " .. type(pubkey) .. ")")
	assert(type(aeskey) == "string", "'aeskey' field must be a string (was a " .. type(aeskey) .. ")")
	assert(type(aesnonce) == "string", "'aesnonce' field must be a string (was a " .. type(aesnonce) .. ")")
	
	local aeskey_hash, err = salut.hash.sha512_256(aeskey)
	
	assert(err == nil or err == 0, "AES key hashing failed")
	
	local ciphertext, err = salut.encrypt.aes256gcm(pubkey, aeskey_hash, aesnonce, "bibliosoph10")
	
	assert(err == nil or err == 0, "encryption failed")
	
	return ciphertext
end

function bibcrypt.construct.message(message, message_nonce, last_message_nonce, alias, aeskey, aesnonce)
	assert(type(message) == "string", "'message' field must be a string (was a " .. type(message) .. ")")
	assert(type(message_nonce) == "string", "'message_nonce' field must be a string (was a " .. type(message_nonce) .. ")")
	assert(type(last_message_nonce) == "string", "'last_message_nonce' field must be a string (was a " .. type(last_message_nonce) .. ")")
	assert(type(alias) == "string", "'alias' field must be a string (was a " .. type(alias) .. ")")
	assert(type(aeskey) == "string", "'aeskey' field must be a string (was a " .. type(aeskey) .. ")")
	assert(type(aesnonce) == "string", "'aesnonce' field must be a string (was a " .. type(aesnonce) .. ")")
	
	local aeskey_hash, err = salut.hash.sha512_256(aeskey)
	
	assert(err == nil or err == 0, "AES key hashing failed")
	
	local submessage_hash, err = salut.hash.sha512_256(message .. aeskey_hash .. message_nonce)
	
	assert(err == nil or err == 0, "message text hash failed")
	
	local message_object = {
		message = message,
		alias = alias,
		--time = os.time(os.date("!*t")),
		message_hash = submessage_hash,
		last_message_nonce = last_message_nonce,
	}
	
	local canonical_aesnonce = salut.pad.zero(aesnonce:sub(1, 12), 12)
	local ciphertext, err = salut.encrypt.aes256gcm(json.encode(message_object), aeskey_hash, canonical_aesnonce, "bibliosoph01")
	
	assert(err == nil or err == 0, "encryption failed")
	
	return ciphertext
end

---- Object Deconstruction ------------------------------------
function bibcrypt.deconstruct.authregister(authreg, aeskey, aesnonce)
	assert(type(authreg) == "string", "'authreg' field must be a string (was a " .. type(authreg) .. ")")
	assert(type(aeskey) == "string", "'aeskey' field must be a string (was a " .. type(aeskey) .. ")")
	assert(type(aesnonce) == "string", "'aesnonce' field must be a string (was a " .. type(aesnonce) .. ")")
	local aeskey_hash, err = salut.hash.sha512_256(aeskey)
	
	assert(err == nil or err == 0, "AES key hashing failed")
	
	local canonical_aesnonce = salut.pad.zero(aesnonce:sub(1, 12), 12)
	local data, err = salut.decrypt.aes256gcm(authreg, aeskey_hash, canonical_aesnonce, "bibliosoph01")
	
	assert(err == nil or err == 0, "decryption failed")
	
	return json.decode(data)
end

function bibcrypt.deconstruct.message(message, aeskey, aesnonce)
	assert(type(message) == "string", "'message' field must be a string (was a " .. type(message) .. ")")
	assert(type(aeskey) == "string", "'aeskey' field must be a string (was a " .. type(aeskey) .. ")")
	assert(type(aesnonce) == "string", "'aesnonce' field must be a string (was a " .. type(aesnonce) .. ")")
	local aeskey_hash, err = salut.hash.sha512_256(aeskey)
	
	assert(err == nil or err == 0, "AES key hashing failed")
	
	local canonical_aesnonce = salut.pad.zero(aesnonce:sub(1, 12), 12)
	local data, err = salut.decrypt.aes256gcm(message, aeskey_hash, canonical_aesnonce, "bibliosoph01")
	
	assert(err == nil or err == 0, "decryption failed")
	
	return json.decode(data)
end

---- Object Verification --------------------------------------

---------------------------------------------------------------

return bibcrypt
