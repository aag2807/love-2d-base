local Vector2D = require("vector2d")
local Rectangle = require("rectangle")

local Circle = {}
Circle.__index = Circle
Circle.__name = "Circle"

local function isCircle(table)
    return table and table.__name and table.__name == "Circle"
end

function Circle.new(x, y, radius)
    local circle = setmetatable({}, Circle)
    if type(x) == "table" and x.__name == "vector2D" then
        circle.position = x
        circle.radius = y or 0
    else
        circle.position = Vector2D.new(x or 0, y or 0)
        circle.radius = radius or 0
    end
    return circle
end

-- Basic properties and setters/getters
function Circle:getX() return self.position.x end
function Circle:getY() return self.position.y end
function Circle:setX(x) self.position.x = x end
function Circle:setY(y) self.position.y = y end
function Circle:getPosition() return self.position end
function Circle:setPosition(x, y)
    if type(x) == "table" and x.__name == "vector2D" then
        self.position = x
    else
        self.position = Vector2D.new(x, y)
    end
end

-- Geometric properties
function Circle:getArea()
    return math.pi * self.radius * self.radius
end

function Circle:getCircumference()
    return 2 * math.pi * self.radius
end

function Circle:getDiameter()
    return 2 * self.radius
end

-- Collision detection
function Circle:contains(x, y)
    if type(x) == "table" and x.__name == "vector2D" then
        return self:contains(x.x, x.y)
    end
    
    local dx = x - self.position.x
    local dy = y - self.position.y
    return (dx * dx + dy * dy) <= (self.radius * self.radius)
end

function Circle:intersectsCircle(other)
    assert(isCircle(other), "Can only check intersection with another circle")
    local distance = self.position:distance(other.position)
    return distance <= (self.radius + other.radius)
end

function Circle:intersectsRectangle(rect)
    assert(rect.__name == "Rectangle", "Can only check intersection with a Rectangle")
    -- Find the closest point to the circle within the rectangle
    local closest = rect:getNearestPoint(self.position)
    -- If the closest point is inside the circle, the rectangle intersects
    return self:contains(closest)
end

function Circle:getIntersectionPoints(other)
    assert(isCircle(other), "Can only get intersection points with another circle")
    local d = self.position:distance(other.position)
    
    -- Circles are too far apart or one is inside the other
    if d > self.radius + other.radius or d < math.abs(self.radius - other.radius) then
        return nil
    end
    
    -- Circles are coincident
    if d == 0 and self.radius == other.radius then
        return nil
    end
    
    local a = (self.radius * self.radius - other.radius * other.radius + d * d) / (2 * d)
    local h = math.sqrt(self.radius * self.radius - a * a)
    
    local p2 = other.position - self.position
    local dx = p2.x / d
    local dy = p2.y / d
    
    local p3 = self.position + Vector2D.new(dx * a, dy * a)
    
    return {
        Vector2D.new(
            p3.x + h * dy,
            p3.y - h * dx
        ),
        Vector2D.new(
            p3.x - h * dy,
            p3.y + h * dx
        )
    }
end

-- Movement and transformation
function Circle:move(dx, dy)
    if type(dx) == "table" and dx.__name == "vector2D" then
        self.position = self.position + dx
    else
        self.position.x = self.position.x + (dx or 0)
        self.position.y = self.position.y + (dy or 0)
    end
    return self
end

function Circle:scale(factor)
    self.radius = self.radius * factor
    return self
end

-- Get bounding box
function Circle:getBoundingBox()
    return Rectangle.new(
        self.position.x - self.radius,
        self.position.y - self.radius,
        self.radius * 2,
        self.radius * 2
    )
end

-- Get point on circumference at given angle
function Circle:getPointOnCircle(angle)
    return Vector2D.new(
        self.position.x + math.cos(angle) * self.radius,
        self.position.y + math.sin(angle) * self.radius
    )
end

-- Check if point is on the circle's circumference (with tolerance)
function Circle:isOnCircumference(point, tolerance)
    tolerance = tolerance or 0.1
    local distance = self.position:distance(point)
    return math.abs(distance - self.radius) <= tolerance
end

-- Get nearest point on circumference to a given point
function Circle:getNearestPoint(point)
    if self:contains(point) and point.x == self.position.x and point.y == self.position.y then
        return self:getPointOnCircle(0) -- arbitrary angle for center point
    end
    
    local angle = math.atan2(point.y - self.position.y, point.x - self.position.x)
    return self:getPointOnCircle(angle)
end

-- Distance to point (0 if point is inside)
function Circle:distanceToPoint(point)
    if self:contains(point) then
        return 0
    end
    return self.position:distance(point) - self.radius
end

-- String representation
function Circle:__tostring()
    return string.format("Circle(x=%.2f, y=%.2f, r=%.2f)",
        self.position.x, self.position.y, self.radius)
end

-- LÖVE specific helpers
function Circle:draw(mode)
    if love then 
        love.graphics.circle(mode or "line", self.position.x, self.position.y, self.radius)
    end
end

function Circle:drawFilled()
    self:draw("fill")
end

-- Draw with debug information
function Circle:drawDebug()
    if love then 
        -- Draw the circle
        self:draw("line")
        
        -- Draw center point
        love.graphics.points(self.position.x, self.position.y)
        
        -- Draw radius line
        love.graphics.line(
            self.position.x, self.position.y,
            self.position.x + self.radius, self.position.y
        )
        
        -- Draw bounding box
        local bbox = self:getBoundingBox()
        bbox:draw("line")
    end
end

return Circle