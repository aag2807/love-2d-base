local UI = {
    _stack = {},  -- Stack to keep track of parent elements
    _context = nil,  -- Current UI context
    _rootElement = nil
}

-- Base Element class
local Element = {}
Element.__index = Element

function Element.new(props)
    local self = setmetatable({}, Element)
    self.children = {}
    self.props = props or {}
    self.layout = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
        padding = props.padding or 0,
        margin = props.margin or 0,
        direction = props.layout or "vertical"  -- Store layout direction here
    }
    return self
end

function Element:addChild(child)
    table.insert(self.children, child)
end

-- UI Context management
function UI.begin(width, height)
    UI._context = {
        width = width,
        height = height,
        mouseX = love.mouse.getX(),
        mouseY = love.mouse.getY(),
        mousePressed = love.mouse.isDown(1)
    }
    UI._rootElement = Element.new({
        width = width,
        height = height,
        layout = "vertical"
    })
    UI._stack = {UI._rootElement}
end

function UI.finish()
    -- Calculate layouts and return root element
    local root = UI._rootElement
    UI._rootElement = nil
    UI._stack = {}
    return root
end

-- Layout container
function UI.container(props)
    local container = Element.new(props)
    local current = UI._stack[#UI._stack]
    
    -- If we have a parent, add this container to it
    if current then
        current:addChild(container)
    end
    
    -- Add container to stack so its children can reference it
    table.insert(UI._stack, container)
    
    -- Process children
    if props.children then
        for _, child in ipairs(props.children) do
            -- The children are already elements, so no need to call anything
            -- They were created by UI.text() or UI.rectangle() before being added to children
            if type(child) == "table" then
                container:addChild(child)
            end
        end
    end
    
    -- Pop the container off the stack when done
    table.remove(UI._stack)
    
    return container
end
-- Basic elements
function UI.text(props)
    local element = Element.new(props)
    element.type = "text"
    element.text = props.text or ""
    element.font = props.font or love.graphics.getFont()
    element.color = props.color or {1, 1, 1, 1}
    
    local current = UI._stack[#UI._stack]
    if current then
        current:addChild(element)
    end
    
    return element
end

function UI.rectangle(props)
    local element = Element.new(props)
    element.type = "rectangle"
    element.color = props.color or {1, 1, 1, 1}
    element.borderRadius = props.borderRadius or 0
    
    local current = UI._stack[#UI._stack]
    if current then
        current:addChild(element)
    end
    
    return element
end

-- Layout calculation
function UI.calculateLayouts(element, x, y, availableWidth, availableHeight)
    local padding = element.layout.padding
    local layout = element.layout

    -- Set initial position
    layout.x = x + padding
    layout.y = y + padding
    
    -- Calculate width/height based on props or content
    if element.props.width then
        layout.width = element.props.width
    elseif element.type == "text" then
        layout.width = element.font:getWidth(element.text) + padding * 2
    else
        layout.width = availableWidth - padding * 2
    end
    
    if element.props.height then
        layout.height = element.props.height
    elseif element.type == "text" then
        layout.height = element.font:getHeight() + padding * 2
    else
        layout.height = availableHeight - padding * 2
    end
    
    -- Layout children based on container type
    local childX = layout.x
    local childY = layout.y
    local spacing = element.props.spacing or 0
    
    if layout.direction == "horizontal" then  -- Check the stored direction
        for _, child in ipairs(element.children) do
            UI.calculateLayouts(child, childX, childY, 
                child.props.width or (layout.width - childX + layout.x),
                child.props.height or layout.height)
            childX = childX + child.layout.width + spacing
        end
    else
        for _, child in ipairs(element.children) do
            UI.calculateLayouts(child, childX, childY, 
                child.props.width or layout.width,
                child.props.height or (layout.height - childY + layout.y))
            childY = childY + child.layout.height + spacing
        end
    end
end

-- Add to Element class
function Element:isHovered(mx, my)
    local l = self.layout
    return mx >= l.x and mx <= l.x + l.width and
           my >= l.y and my <= l.y + l.height
end

function Element:onClick(callback)
    self.clickCallback = callback
    return self
end

-- Add to UI module
function UI.handleMouse(element)
    local mx, my = love.mouse.getPosition()
    
    if element:isHovered(mx, my) and element.clickCallback then
        if love.mouse.isPressed(1) then
            element.clickCallback()
        end
    end
    
    -- Check children
    for _, child in ipairs(element.children) do
        UI.handleMouse(child)
    end
end

-- LÖVE2D rendering
function UI.render(element)
    local l = element.layout
    
    if element.type == "rectangle" then
        love.graphics.setColor(unpack(element.color))
        if element.borderRadius > 0 then
            -- TODO: Implement rounded rectangles
            love.graphics.rectangle("fill", l.x, l.y, l.width, l.height)
        else
            love.graphics.rectangle("fill", l.x, l.y, l.width, l.height)
        end
    elseif element.type == "text" then
        love.graphics.setColor(unpack(element.color))
        love.graphics.setFont(element.font)
        love.graphics.print(element.text, l.x, l.y)
    end
    
    -- Render children
    for _, child in ipairs(element.children) do
        UI.render(child)
    end
end

return UI