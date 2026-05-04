local MOD_ADLER = 65521

local function adler32(buf: buffer): number
	local a = 1
	local b = 0
	
	for i = 0, buffer.len(buf) - 1 do
		local byte = buffer.readu8(buf, i)
		a = (a + byte) % MOD_ADLER
		b = (b + a) % MOD_ADLER
	end
	
	return bit32.lshift(b, 16) + a
end

return adler32
