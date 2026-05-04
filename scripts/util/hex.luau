local function toHex(data: string, maxBytes: number)
    local bytes = {}
    for i = 1, math.min(#data, maxBytes) do
        bytes[i] = string.format("%02X", data:byte(i))
    end
 
	local hex = table.concat(bytes, " ")
    if #data > maxBytes then
        hex = hex .. string.format(" ... (%d bytes total)", #data)
    end
 
	return hex
end

return toHex
