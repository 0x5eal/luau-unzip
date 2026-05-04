return {
	{ name = "literal_single", data = "x" },
	{ name = "literal_multiple", data = "Hello World!" },
	{ name = "repeated_a", data = string.rep("a", 100) },
	{ name = "repeated_ab", data = string.rep("ab", 50) },
	{ name = "repeated_long", data = string.rep("x", 2324) },
	{ name = "mixed", data = "abc" .. string.rep("d", 100) .. "efg" },
	{ name = "binary", data = string.char(0, 1, 2, 3, 255, 254, 253) },
	{ name = "empty", data = "" },
}