local Vector2D = require("vector2d")

local Rectangle = {}
Rectangle.__index = Rectangle
Rectangle.__name = "Rectangle"

local function isRectangle(table)
    return table and table.__name and table.__name == "Rectangle"
end

function Rectangle.new(x, y, width, height)
    local rect = setmetatable({}, Rectangle)
    rect.x = x or 0
    rect.y = y or 0
    rect.width = width or 0
    rect.height = height or 0
    return rect
end

-- Get the rectangle's position as a Vector2D
function Rectangle:getPosition()
    return Vector2D.new(self.x, self.y)
end

-- Set position from a Vector2D
function Rectangle:setPosition(vector)
    assert(vector.__name == "vector2D", "Position must be a Vector2D")
    self.x = vector.x
    self.y = vector.y
end

-- Get the center point of the rectangle
function Rectangle:getCenter()
    return Vector2D.new(
        self.x + self.width / 2,
        self.y + self.height / 2
    )
end

-- Get all four corners as Vector2D
function Rectangle:getCorners()
    return {
        topLeft = Vector2D.new(self.x, self.y),
        topRight = Vector2D.new(self.x + self.width, self.y),
        bottomLeft = Vector2D.new(self.x, self.y + self.height),
        bottomRight = Vector2D.new(self.x + self.width, self.y + self.height)
    }
end

-- Check if a point is inside the rectangle
function Rectangle:contains(x, y)
    if type(x) == "table" and x.__name == "vector2D" then
        return self:contains(x.x, x.y)
    end
    
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Check collision with another rectangle
function Rectangle:intersects(other)
    assert(isRectangle(other), "Can only check intersection with another rectangle")
    return self.x < other.x + other.width and
           self.x + self.width > other.x and
           self.y < other.y + other.height and
           self.y + self.height > other.y
end

-- Get the intersection rectangle between this and another rectangle
function Rectangle:getIntersection(other)
    if not self:intersects(other) then
        return nil
    end
    
    local x = math.max(self.x, other.x)
    local y = math.max(self.y, other.y)
    local width = math.min(self.x + self.width, other.x + other.width) - x
    local height = math.min(self.y + self.height, other.y + other.height) - y
    
    return Rectangle.new(x, y, width, height)
end

-- Get the union rectangle (bounding box of both rectangles)
function Rectangle:union(other)
    local x = math.min(self.x, other.x)
    local y = math.min(self.y, other.y)
    local width = math.max(self.x + self.width, other.x + other.width) - x
    local height = math.max(self.y + self.height, other.y + other.height) - y
    
    return Rectangle.new(x, y, width, height)
end

-- Grow or shrink the rectangle by a given amount
function Rectangle:inflate(dx, dy)
    dy = dy or dx
    self.x = self.x - dx
    self.y = self.y - dy
    self.width = self.width + 2 * dx
    self.height = self.height + 2 * dy
    return self
end

-- Check if this rectangle is completely inside another
function Rectangle:isContainedIn(other)
    return self.x >= other.x and
           self.y >= other.y and
           self.x + self.width <= other.x + other.width and
           self.y + self.height <= other.y + other.height
end

-- Move the rectangle by a given amount
function Rectangle:move(dx, dy)
    if type(dx) == "table" and dx.__name == "vector2D" then
        self.x = self.x + dx.x
        self.y = self.y + dy.y
    else
        self.x = self.x + (dx or 0)
        self.y = self.y + (dy or 0)
    end
    return self
end

-- Calculate the nearest point on the rectangle's perimeter to a given point
function Rectangle:getNearestPoint(point)
    local nearest = Vector2D.new(
        math.max(self.x, math.min(point.x, self.x + self.width)),
        math.max(self.y, math.min(point.y, self.y + self.height))
    )
    return nearest
end

-- Get distance to a point (0 if point is inside)
function Rectangle:distanceTo(point)
    if self:contains(point) then
        return 0
    end
    return self:getNearestPoint(point):distance(point)
end

-- Check if rectangle overlaps with a circle
function Rectangle:intersectsCircle(center, radius)
    local nearest = self:getNearestPoint(center)
    return nearest:distance(center) <= radius
end

-- Create a scaled version of the rectangle
function Rectangle:scale(sx, sy)
    sy = sy or sx
    return Rectangle.new(
        self.x * sx,
        self.y * sy,
        self.width * sx,
        self.height * sy
    )
end

-- Get area of the rectangle
function Rectangle:getArea()
    return self.width * self.height
end

-- Get perimeter of the rectangle
function Rectangle:getPerimeter()
    return 2 * (self.width + self.height)
end

-- Check if rectangle is valid (positive width and height)
function Rectangle:isValid()
    return self.width > 0 and self.height > 0
end

-- String representation
function Rectangle:__tostring()
    return string.format("Rectangle(x=%.2f, y=%.2f, w=%.2f, h=%.2f)",
        self.x, self.y, self.width, self.height)
end

-- Utility functions for common rectangles
function Rectangle.fromCenter(centerX, centerY, width, height)
    return Rectangle.new(
        centerX - width/2,
        centerY - height/2,
        width,
        height
    )
end

function Rectangle.fromPoints(p1, p2)
    local x = math.min(p1.x, p2.x)
    local y = math.min(p1.y, p2.y)
    local width = math.abs(p2.x - p1.x)
    local height = math.abs(p2.y - p1.y)
    return Rectangle.new(x, y, width, height)
end

-- LÖVE specific helpers
function Rectangle:draw(mode)
    if love then  
        love.graphics.rectangle(mode or "line", self.x, self.y, self.width, self.height)
    end
end

function Rectangle:drawFilled()
    self:draw("fill")
end

return Rectangle