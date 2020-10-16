


local data = {0.2717210, 0.8052869, 0.3745298, 0.0037695, 0.9474171}
local i
local s, m, c = 0, 0, 0, 0

for i, x in ipairs(data) do
    c = c + 1
    s = s + 1.0 * (c - 1) / c * (x - m) * (x - m)
    m = m + (x - m) / c
end


print(s/(c-1), math.sqrt(s/(c-1)), m, c)

