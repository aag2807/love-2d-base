local UI = require 'lib.ui.core'

local Button = UI.component("Button", {
    init = function(props)
        return {
            hovered = false
        }
    end,

    render = function(self, props)
        return UI.container {
            layout = "horizontal",
            padding = { left = 8, right = 8, top = 8, bottom = 8 },
            children = {
                UI.container {
                    layout = "horizontal",
                    children = {
                        UI.rectangle {
                            width = props.width or 100,
                            height = props.height or 40,
                            color = self.state.hovered and {0.8, 0.3, 0.3, 1} or {0.6, 0.2, 0.2, 1},
                            onClick = props.onClick,
                            onHover = function(isHovered) 
                                self.state.hovered = isHovered
                                UI.markDirty()
                            end,
                            children = {
                                UI.text {
                                    text = props.text or "Button",
                                    color = {1, 1, 1, 1},
                                }
                            }
                        }
                    }
                }
            }
        }
    end
})

-- Example usage:
function love.load()
    UI.begin(300, 300)
    
    Button {
        text = "Click me!",
        onClick = function()
            print("Button clicked!")
        end
    }
    
    root = UI.finish()
end

function love.update(dt)
    -- Update UI state and layout
    UI.calculateLayouts(root, 0, 0, 300, 300)
end

function love.draw()
    UI.render(root)
end