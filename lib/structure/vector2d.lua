local vector2d = {}
vector2d.__index = vector2d
vector2d.__name = "vector2D"

local function isVector(table)
    return table and table.__name and table.__name == "vector2D" 
end

function vector2d.new(x, y)
    local vector = setmetatable({}, vector2d)
    vector.x = x or 0.0
    vector.y = y or 0.0
    return vector
end

-- Operator overloads
function vector2d.__add(a, b)
    assert(isVector(a) and isVector(b), "Can only add two vectors")
    return vector2d.new(a.x + b.x, a.y + b.y)
end

function vector2d.__sub(a, b)
    assert(isVector(a) and isVector(b), "Can only subtract two vectors")
    return vector2d.new(a.x - b.x, a.y - b.y)
end

function vector2d.__mul(a, b)
    if type(a) == "number" then
        return vector2d.new(b.x * a, b.y * a)
    elseif type(b) == "number" then
        return vector2d.new(a.x * b, a.y * b)
    else
        assert(isVector(a) and isVector(b), "Invalid multiplication operands")
        return vector2d.new(a.x * b.x, a.y * b.y)
    end
end

function vector2d.__div(a, b)
    if isVector(a) and type(b) == "number" then
        assert(b ~= 0, "Division by zero")
        return vector2d.new(a.x / b, a.y / b)
    end
    assert(false, "Invalid division operands")
end

function vector2d.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function vector2d.__tostring(v)
    return string.format("Vector2D(%.3f, %.3f)", v.x, v.y)
end

-- Vector operations
function vector2d:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function vector2d:lengthSqr()
    return self.x * self.x + self.y * self.y
end

function vector2d:normalize()
    local len = self:length()
    if len > 0 then
        return vector2d.new(self.x / len, self.y / len)
    end
    return vector2d.new()
end

function vector2d:dot(other)
    assert(isVector(other), "Dot product requires a vector")
    return self.x * other.x + self.y * other.y
end

function vector2d:distance(other)
    assert(isVector(other), "Distance requires a vector")
    local dx = self.x - other.x
    local dy = self.y - other.y
    return math.sqrt(dx * dx + dy * dy)
end

function vector2d:angle(other)
    assert(isVector(other), "Angle calculation requires a vector")
    return math.atan2(other.y - self.y, other.x - self.x)
end

function vector2d:rotate(angle)
    local cs = math.cos(angle)
    local sn = math.sin(angle)
    return vector2d.new(
        self.x * cs - self.y * sn,
        self.x * sn + self.y * cs
    )
end

function vector2d:lerp(other, t)
    assert(isVector(other), "Lerp requires a vector")
    t = math.max(0, math.min(1, t))
    return vector2d.new(
        self.x + (other.x - self.x) * t,
        self.y + (other.y - self.y) * t
    )
end

function vector2d:clamp(min, max)
    assert(isVector(min) and isVector(max), "Clamp requires two vectors")
    return vector2d.new(
        math.max(min.x, math.min(max.x, self.x)),
        math.max(min.y, math.min(max.y, self.y))
    )
end

function vector2d:reflect(normal)
    assert(isVector(normal), "Reflection requires a normal vector")
    local dot = self:dot(normal)
    return vector2d.new(
        self.x - 2 * dot * normal.x,
        self.y - 2 * dot * normal.y
    )
end

-- Static constructors
function vector2d.zero()
    return vector2d.new(0, 0)
end

function vector2d.one()
    return vector2d.new(1, 1)
end

function vector2d.up()
    return vector2d.new(0, -1)
end

function vector2d.down()
    return vector2d.new(0, 1)
end

function vector2d.left()
    return vector2d.new(-1, 0)
end

function vector2d.right()
    return vector2d.new(1, 0)
end

return vector2d