-- See LICENSE for terms

-- EXPORT
rcsh_library = {}	-- avoid clogging up global namespace

local format_pair = "%s = [%s], "
local format_single = "%s, "
local dbg = false
-- TODO: mod option

local function make_prefix(...)
	local args = {...}
	local s = ""
	for _, v in ipairs(args) do
		s = s .. string.format("%s | ", v)
	end
	return s
end

local function logtable(s, ...)
	-- MAYBE: check if table is table and prefix is string
	for _, t in pairs({...}) do
		for k, v in pairs(t) do
			print(s .. string.format(format_pair, k, v))
		end
	end
end

local function log(s, ...)
	-- MAYBE: check if everything is a string
	local args = {...}
	if #args < 1 then table.insert(args, "---") end
	local k	--hold key since table is flattened
	for _, v in ipairs(args) do
		if k == nil then
			k = v	--first one is key
		else
			s = s .. string.format(format_pair, k, v)
			k = nil
		end
	end
	if k then s = s .. string.format(format_single, k) end
	print(s)
end

local function string_filter(s, pattern)
	local pre = make_prefix(CurrentModId, "string_filter")

	local x, y = string.find(s, pattern)
	local result = ""
	if x and y then
		result = string.sub(s, x, y)
	end

	return result
end

local function array_unordered_remove(t, index)
	t[index] = t[#t]
	t[#t] = nil
end

local function array_clear(arr)
	for i = #arr, 1, -1 do
		arr[i] = nil
	end
end

local function table_remove_keys(t, list_of_keys)
	for _, v in ipairs(list_of_keys) do
		t[v] = nil
	end
end

local function table_count_elements(t)
	local count = 0
	for _, _ in pairs(t) do
		count = count + 1
	end
	return count
end



--console logging utilities
rcsh_library.make_prefix = make_prefix --make prefix from modid and funcname
rcsh_library.log = log                 --treats inputs as paired values
rcsh_library.logtable = logtable       --treats inputs as a hashmap
rcsh_library.string_filter = string_filter
rcsh_library.array_unordered_remove = array_unordered_remove
rcsh_library.table_remove_keys = table_remove_keys
rcsh_library.table_count_elements = table_count_elements
