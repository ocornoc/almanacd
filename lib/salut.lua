---- Dependencies ---------------------------------------------
local ffi = require "ffi"
local salut = {encrypt = {}, decrypt = {}, hash = {}, mac = {}, pad = {}, random = {}}

---- Declarations ---------------------------------------------
ffi.cdef[[
//   :: SODIUM ::
int sodium_init(void);

//   :: AEAD ::
int crypto_aead_aes256gcm_encrypt(unsigned char *c,
                                  unsigned long long *clen_p,
				  const unsigned char *m,
				  unsigned long long mlen,
				  const unsigned char *ad,
				  unsigned long long adlen,
                                  const unsigned char *nsec,
				  const unsigned char *npub,
				  const unsigned char *k);

int crypto_aead_aes256gcm_decrypt(unsigned char *m,
                                  unsigned long long *mlen_p,
				  unsigned char *nsec,
				  const unsigned char *c,
				  unsigned long long clen,
				  const unsigned char *ad,
				  unsigned long long adlen,
				  const unsigned char *npub,
				  const unsigned char *k);

//   :: RANDOM ::
uint32_t randombytes_random(void);

uint32_t randombytes_uniform(const uint32_t upper_bound);

void randombytes_buf(void *const buf,
                     const size_t size);

//   :: SHA512 ::
int crypto_hash_sha512(unsigned char *out,
                       const unsigned char *in,
		       unsigned long long inlen);
]]

local sodium = assert(ffi.load("sodium"))

local started = sodium.sodium_init()

if started ~= 0 then
	error("libsodium failed to start: " .. started)
end

---- Pad Functions --------------------------------------------
-- Zero padding -----------------------------------------------
-- Action: Pads a message with null bytes ('\0') until the string reaches a specific length.
-- Input: message (a Lua string), length (a nonnegative integer)
-- Output: A padded Lua string
-- Note: If length has a decimal part, it is rounded up.
function salut.pad.zero(message, length)
	if length < 0 then
		return nil, "Cannot use a negative length"
	end
	
	length = math.ceil(length)
	
	while message:len() < length do
		message = message .. "\0"
	end
	
	return message
end

---- Random ---------------------------------------------------
-- Random Num -------------------------------------------------
-- Action: Generates a random unsigned doubleword int.
-- Output: A random unsigned integer (a number)
function salut.random.int()
	return sodium.randombytes_random()
end

-- Uniform Random Bytes ---------------------------------------
-- Action: Generates a uniformly random between 0 and upper_bound (exclusively).
-- Input: upper_bound (an unsigned integer)
-- Output: A random unsigned integer (a number)
function salut.random.uniform(upper_bound)
	local int_upper = ffi.new("const uint32_t", upper_bound)
	
	return sodium.randombytes_uniform(int_upper)
end

-- Random Byte String -----------------------------------------
-- Action: Generates a random string with a given length.
-- Input: length (a positive integer)
-- Output: A random Lua string
-- Note: If length has a decimal part, it is rounded up.
function salut.random.string(length)
	if length < 1 then
		return nil, "Cannot use a length < 1"
	end
	
	local newstring = ffi.new("unsigned char[?]", length)
	sodium.randombytes_buf(newstring, length)
	
	return ffi.string(newstring, length)
end

---- AEAD Symmetric Encryption --------------------------------
-- AES256-GCM (using E-then-M) --------------------------------
-- Action: Encrypts a message with some key and nonce, along with some additional data.
-- Input: message (a Lua string), key (a Lua string), nonce (a Lua string), add (a Lua string or nil)
-- Output: AES encrypted data with authentication MAC appended (a Lua string)
-- Note: inputs are padded with trailing 0 bytes. key is truncated to 16 bytes and nonce to 12
function salut.encrypt.aes256gcm(message, key, nonce, add)
	local input_m = ffi.new("const unsigned char[?]", message:len(), message)
	local input_mlen = ffi.new("unsigned long long", message:len())
	local input_ad
	if add and add ~= "" then
		input_ad = ffi.new("const unsigned char[?]", add:len(), add)
	else
		input_ad = ffi.new("const unsigned char *")
	end
	local input_adlen = ffi.new("unsigned long long", (add or ""):len())
	local input_npub = ffi.new("const unsigned char[12]", salut.pad.zero(nonce, 12):sub(1, 12))
	local input_k = ffi.new("const unsigned char[32]", salut.pad.zero(key, 32):sub(1, 32))
	local output_c = ffi.new("unsigned char[?]", message:len() + 16, salut.pad.zero("", message:len() + 16))
	local output_clen = ffi.new("unsigned long long[1]", {})
	local nsec = ffi.new("const unsigned char *")
	
	local err = sodium.crypto_aead_aes256gcm_encrypt(output_c, output_clen, input_m, input_mlen,
	                                                 input_ad, input_adlen, nsec, input_npub, input_k)
	
	if err ~= nil and err ~= 0 then
		return nil, err
	else
		return ffi.string(output_c, output_clen[0])
	end
end

-- Action: Decrypts ciphertext with some key and nonce, along with some additional data.
-- Input: ciphertext (a Lua string), key (a Lua string), nonce (a Lua string), add (a Lua string or nil)
-- Output: Decrypted contents of the ciphertext.
-- Note: inputs are padded with trailing 0 bytes. key is truncated to 16 bytes and nonce to 12.
-- Note 2: One of the "error" conditions (soft error) is if the args don't decrypt the ciphertext.
function salut.decrypt.aes256gcm(ciphertext, key, nonce, add)
	local output_m = ffi.new("unsigned char[?]", ciphertext:len(), salut.pad.zero("", ciphertext:len()))
	local output_mlen = ffi.new("unsigned long long[1]", {0})
	local nsec = ffi.new("unsigned char *")
	local input_c = ffi.new("const unsigned char[?]", ciphertext:len(), ciphertext)
	local input_clen = ffi.new("unsigned long long", ciphertext:len())
	local input_ad
	if add and add ~= "" then
		input_ad = ffi.new("const unsigned char[?]", add:len(), add)
	else
		input_ad = ffi.new("const unsigned char *")
	end
	local input_adlen = ffi.new("unsigned long long", (add or ""):len())
	local input_npub = ffi.new("const unsigned char[12]", salut.pad.zero(nonce, 12):sub(1, 12))
	local input_k = ffi.new("const unsigned char[32]", salut.pad.zero(key, 32):sub(1, 32))
	
	local err = sodium.crypto_aead_aes256gcm_decrypt(output_m, output_mlen, nsec, input_c, input_clen,
	                                                 input_ad, input_adlen, input_npub, input_k)
	
	if err ~= nil and err ~= 0 then
		return nil, err
	else
		return ffi.string(output_m, output_mlen[0])
	end
end

-- GMAC256 ----------------------------------------------------
-- Action: Calculates the GMAC of the additional data.
-- Input: key (a Lua string), nonce (a Lua string), add (a Lua string or nil)
-- Output: The GMAC of add (the additional data).
-- See salut.encrypt.aes256gcm notes.
function salut.mac.gmac256(key, nonce, add)
	return salut.encrypt.aes256gcm("", key, nonce, add)
end

-- Action: Verifies that a GMAC hash is equal to the one calculated from the data.
-- Input: mac (a Lua string), key (a Lua string), nonce (a Lua string), add (a Lua string or nil)
-- Output: A boolean describing if mac == the GMAC of the other args
-- See salut.encrypt.aes256gcm notes.
function salut.mac.gmac256_verify(mac, key, nonce, add)
	local hash, err = salut.mac.gmac256(key, nonce, add)
	
	if err ~= nil and err ~= 0 then
		return nil, err
	else
		return mac == hash
	end
end

---- SHA-2 Family ---------------------------------------------
-- SHA-512 ----------------------------------------------------
-- Action: Generates a SHA-512 hash from a given input.
-- Input: data (a Lua string)
-- Output: hash (a Lua string)
function salut.hash.sha512(data)
	local input_in = ffi.new("const unsigned char[?]", data:len(), data)
	local output_out = ffi.new("unsigned char[64]")
	local err = sodium.crypto_hash_sha512(output_out, input_in, data:len())
	
	if err ~= nil and err ~= 0 then
		return nil, err
	else
		return ffi.string(output_out, 64)
	end
end

-- SHA-512 truncated ------------------------------------------
-- Action: Generates a SHA-512 hash truncated to 256 bits from a given input.
-- Input: data (a Lua string)
-- Output: hash (a Lua string)
function salut.hash.sha512_256(data)
	local hash, err = salut.hash.sha512(data)
	
	if err ~= nil and err ~= 0 then
		return nil, err
	else
		return ffi.string(hash, 32)
	end
end

return salut
