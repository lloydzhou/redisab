--[[
  https://github.com/rgertenbach/Lua-Stats
]]


--[[ Generics ]]--

local function assertTables(...)
  for _, t in pairs({...}) do
    assert(type(t) == "table", "Argument must be a table")
  end
end


-- Simple map function
local function map(t, f, ...)
  assert(t ~= nil, "No table provided to map")
  assert(f ~= nil, "No function provided to map")
  local output = {}

  for i, e in pairs(t) do
    output[i] = f(e, ...)
  end
  return output
end 


-- Simple reduce function
local function reduce(t, f)
  assert(t ~= nil, "No table provided to reduce")
  assert(f ~= nil, "No function provided to reduce")
  local result

  for i, value in ipairs(t) do
    if i == 1 then
      result = value
    else
      result = f(result, value)
    end 
  end
  return result
end 


-- Concatenates tables and scalars into one list
local function unify(...)
  local output = {}
  for i, element in ipairs({...}) do
    if type(element) == 'number' then
      table.insert(output, element)
    elseif type(element) == 'table' then
      for j, row in ipairs(element) do
        table.insert(output, row)
      end
    end 
  end 
  return output
end 


-- Integrates a function from start to stop in delta sized steps
local function integral(f, start, stop, delta, ...)
  local delta = delta or 1e-5
  local area = 0
  for i = start, stop, delta do
    area = area + f(i, ...) * delta
  end
  return area
end


-- p-value of a quantile q of a probability function f
local function pValue(q, f, ...)
  assert(q ~= nil, "pValue needs a q-value")
  assert(f ~= nil, "pValue needs a function")
  return math.abs(1 - math.abs(f(q, ...) - f(-q, ...)))
end


--[[ Basic Arithmetic functions needed for aggregate functions ]]--
local function sum(...) 
  return reduce(unify(...), function(a, b) return a + b end)
end 


local function count(...) 
  return #unify(...) 
end 


local function mean(...) 
  return sum(...) / count(...) 
end 


local function sumSquares(...)
  local data = unify(...)
  local mu = mean(data)

  return sum(map(data, function(x) return (x - mu)^2 end))  
end 


local function var(...)
  return sumSquares(...) / (count(...) - 1)
end


local function sd(...)
  return math.sqrt(var(...))
end 


-- Pooled standard deviation for two already calculated standard deviations
-- Seconds return is the new sample size adjusted for degrees of freedom
local function sdPooled(sd1, n1, sd2, n2)
  return math.sqrt(((n1 - 1) * sd1^2 + (n2 - 1) * sd2^2) / (n1 + n2 - 2))
end 


--[[ Normal Distribution Functions ]]--

-- Probability Density function of a Normal Distribution
local function dNorm(x, mu, sd)
  assert(type(x) == "number", "x must be a number")
  local mu = mu or 0
  local sd = sd or 1

  return (1 / 
         (sd * math.sqrt(2 * math.pi))) * 
         math.exp(-(((x - mu) * (x - mu)) / (2 * sd^2)))
end


-- CDF of a normal distribution
local function pNorm(q, mu, sd, accuracy)
  assert(type(q) == "number", "q must be a number")
  mu = mu or 0
  sd = sd or 1
  accuracy = accuracy or 1e-3

  return 0.5 + 
    (q > 0 and 1 or -1) * integral(dNorm, 0, math.abs(q), accuracy, mu, sd)
end


--[[ Tests ]]--

-- Calculates the Z-Score for one or two samples. 
-- Assumes non equivalent Variance.
local function zValue(y1, sd1, n1, y2, sd2, n2, sameVar)
  assert(sd1 > 0, "Standard Deviation has to be positive")
  assert(n1  > 1, "Sample Size has to be at least 2")
  
  y2 = y2 or 0
  sameVar = sameVar or false
  local z
  local d = y1 - y2

  if n2 == nil then
    z = d / (sd1 / math.sqrt(n1))
  elseif sameVar then
    z = d / math.sqrt(sd1^2 / n1 + sd2^2 / n2)
  else
    z = d / (sdPooled(sd1, n1, sd2, n2) * math.sqrt(1 / n1 + 1 / n2))
  end

  return z
end


-- Performs a z-test on two tables and returns z-statistic.
local function zTest(t1, t2, sameVar)
  assertTables(t1, t2)
  return zValue(mean(t1), sd(t1), #t1, mean(t2), sd(t2), #t2, sameVar)
end 


-- Calculates the p-value of a two sample zTest.
local function zTestP(t1, t2, sameVar)
  assertTables(t1, t2)
  return pValue(zTest(t1, t2, sameVar), pNorm)
end

