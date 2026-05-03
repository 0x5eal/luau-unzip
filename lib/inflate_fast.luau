-- Inflate.lua
-- CRC-safe Luau DEFLATE inflater

----------------------------------------------------------------
-- Bitstream
----------------------------------------------------------------

type BitStream = {
	src: buffer,
	pos: number,
	len: number,
	tag: number,
	bits: number,
}

local function bsInit(src: buffer): BitStream
	return { src = src, pos = 0, len = buffer.len(src), tag = 0, bits = 0 }
end

local function bsFill(bs: BitStream)
	while bs.bits <= 56 and bs.pos < bs.len do
		bs.tag = bit32.bor(bs.tag, bit32.lshift(buffer.readu8(bs.src, bs.pos), bs.bits))
		bs.pos += 1
		bs.bits += 8
	end
end

local function bsRead(bs: BitStream, n: number): number
	if bs.bits < n then bsFill(bs) end
	local v = bit32.band(bs.tag, bit32.lshift(1, n) - 1)
	bs.tag = bit32.rshift(bs.tag, n)
	bs.bits -= n
	return v
end

local function bsAlignByte(bs: BitStream)
	if bs.bits % 8 ~= 0 then
		local skip = 8 - (bs.bits % 8)
		bsRead(bs, skip)
	end
end

----------------------------------------------------------------
-- Huffman
----------------------------------------------------------------

local MAX_BITS = 15
local LOOKUP_BITS = 10
local LOOKUP_SIZE = 1024
local LOOKUP_MASK = 1023

type Huffman = {
	count: {number},
	symbol: {number},
	maxBits: number,
	lookup: {number},
}

local function buildHuffman(lengths: {number}, offset: number?, count: number?): Huffman
	offset = offset or 0
	count = count or #lengths

	local h: Huffman = { count = table.create(MAX_BITS + 1, 0), symbol = table.create(count, 0),
		maxBits = 0, lookup = table.create(LOOKUP_SIZE, 0) }

	for i = 0, MAX_BITS do h.count[i] = 0 end
	for i = 0, count - 1 do
		local l = lengths[offset + i] or 0
		if l > 0 then
			h.count[l] += 1
			if l > h.maxBits then h.maxBits = l end
		end
	end

	local offs = table.create(MAX_BITS + 1, 0)
	for i = 0, MAX_BITS do offs[i] = 0 end

	local sum = 0
	for i = 1, MAX_BITS do
		offs[i] = sum
		sum += h.count[i]
	end

	for i = 0, count - 1 do
		local l = lengths[offset + i] or 0
		if l > 0 then
			h.symbol[offs[l]] = i
			offs[l] += 1
		end
	end

	for code = 0, LOOKUP_SIZE - 1 do
		local cur = 0
		local bits = code
		local sum2 = 0
		for len = 1, MAX_BITS do
			cur = cur * 2 + bit32.band(bits, 1)
			bits = bit32.rshift(bits, 1)
			sum2 += h.count[len]
			cur -= h.count[len]
			if cur < 0 then
				if len <= LOOKUP_BITS then
					h.lookup[code] = bit32.bor(bit32.lshift(h.symbol[sum2 + cur], 8), len)
				end
				break
			end
		end
	end

	return h
end

local function decode(bs: BitStream, h: Huffman): number
	if bs.bits < 15 then bsFill(bs) end

	local entry = h.lookup[bit32.band(bs.tag, LOOKUP_MASK)]
	local len = bit32.band(entry, 0xFF)

	if len ~= 0 then
		bs.tag = bit32.rshift(bs.tag, len)
		bs.bits -= len
		return bit32.rshift(entry, 8)
	end

	local cur = 0
	local sum = 0

	for l = 1, h.maxBits do
		cur = cur * 2 + bit32.band(bs.tag, 1)
		bs.tag = bit32.rshift(bs.tag, 1)
		bs.bits -= 1

		sum += h.count[l]
		cur -= h.count[l]

		if cur < 0 then return h.symbol[sum + cur] end
	end

	error("Invalid Huffman code")
end

----------------------------------------------------------------
-- Fixed Huffman trees
----------------------------------------------------------------

local fixedLitLen: Huffman
local fixedDist: Huffman

do
	local ll = table.create(288, 0)
	for i = 0, 143 do ll[i] = 8 end
	for i = 144, 255 do ll[i] = 9 end
	for i = 256, 279 do ll[i] = 7 end
	for i = 280, 287 do ll[i] = 8 end
	fixedLitLen = buildHuffman(ll, 0, 288)

	local dl = table.create(32, 5)
	fixedDist = buildHuffman(dl, 0, 32)
end

----------------------------------------------------------------
-- Length / distance tables
----------------------------------------------------------------

local LEN_BASE = {3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,
	35,43,51,59,67,83,99,115,131,163,195,227,258}
local LEN_EXTRA = {0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,
	3,3,3,3,4,4,4,4,5,5,5,5,0}
local DIST_BASE = {1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,
	193,257,385,513,769,1025,1537,2049,3073,
	4097,6145,8193,12289,16385,24577}
local DIST_EXTRA = {0,0,0,0,1,1,2,2,3,3,4,4,5,5,
	6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13}

----------------------------------------------------------------
-- Dynamic Huffman
----------------------------------------------------------------

local CL_ORDER = {16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15}

local function readCodeLengths(bs, codeLenTree, total)
	local lengths = table.create(total, 0)
	local i = 0
	local prev = 0

	while i < total do
		local sym = decode(bs, codeLenTree)
		if sym <= 15 then
			lengths[i] = sym
			prev = sym
			i += 1
		elseif sym == 16 then
			if i == 0 then error("Invalid repeat: no previous length") end
			local run = 3 + bsRead(bs, 2)
			for _ = 1, run do lengths[i] = prev; i += 1 end
		elseif sym == 17 then
			local run = 3 + bsRead(bs, 3)
			for _ = 1, run do lengths[i] = 0; i += 1 end
			prev = 0
		elseif sym == 18 then
			local run = 11 + bsRead(bs, 7)
			for _ = 1, run do lengths[i] = 0; i += 1 end
			prev = 0
		else
			error("Invalid code length symbol")
		end
	end

	return lengths
end

local function decodeDynamicTrees(bs)
	local HLIT = bsRead(bs, 5) + 257
	local HDIST = bsRead(bs, 5) + 1
	local HCLEN = bsRead(bs, 4) + 4

	local clLengths = table.create(19, 0)
	for i = 0, HCLEN - 1 do
		clLengths[CL_ORDER[i + 1]] = bsRead(bs, 3)
	end

	local clTree = buildHuffman(clLengths, 0, 19)
	local lengths = readCodeLengths(bs, clTree, HLIT + HDIST)

	local litTree = buildHuffman(lengths, 0, HLIT)
	local distTree = buildHuffman(lengths, HLIT, HDIST)

	return litTree, distTree
end

----------------------------------------------------------------
-- Inflate main
----------------------------------------------------------------

local function inflate(src: buffer, expectedSize: number?): buffer
	local bs = bsInit(src)
	local out = buffer.create(expectedSize or buffer.len(src) * 4)
	local outLen = 0

	repeat
		local bfinal = bsRead(bs, 1)
		local btype = bsRead(bs, 2)
		local litTree, distTree

		if btype == 0 then
			bsAlignByte(bs)
			local len = buffer.readu8(src, bs.pos) + bit32.lshift(buffer.readu8(src, bs.pos + 1), 8)
			local nlen = buffer.readu8(src, bs.pos + 2) + bit32.lshift(buffer.readu8(src, bs.pos + 3), 8)
			bs.pos += 4
			if len ~= bit32.bxor(nlen, 0xFFFF) then error("Stored block length mismatch") end
			buffer.copy(out, outLen, src, bs.pos, len)
			outLen += len
			bs.pos += len

		elseif btype == 1 then
			litTree = fixedLitLen
			distTree = fixedDist

		elseif btype == 2 then
			litTree, distTree = decodeDynamicTrees(bs)

		else
			error("Invalid block type")
		end

		if btype ~= 0 then
			while true do
				local sym = decode(bs, litTree)
				if sym < 256 then
					buffer.writeu8(out, outLen, sym)
					outLen += 1
				elseif sym == 256 then
					break
				else
					local lengthSym = sym - 257
					local length = LEN_BASE[lengthSym] + bsRead(bs, LEN_EXTRA[lengthSym])
					local distSym = decode(bs, distTree)
					local dist = DIST_BASE[distSym] + bsRead(bs, DIST_EXTRA[distSym])
					local from = outLen - dist
					if from < 0 then error("Invalid distance") end
					if dist >= length then
						buffer.copy(out, outLen, out, from, length)
						outLen += length
					else
						for i = 0, length - 1 do
							buffer.writeu8(out, outLen, buffer.readu8(out, from + i))
							outLen += 1
						end
					end
				end
			end
		end
	until bfinal == 1

	local result = buffer.create(outLen)
	buffer.copy(result, 0, out, 0, outLen)
	return result
end

return inflate
