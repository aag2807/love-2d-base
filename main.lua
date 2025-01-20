UI = require('lib.ui.core')
local root = nil

function love.load()
    -- Create UI structure once
    UI.begin(300, 300)
    
    UI.container {
        layout = "vertical",
        padding = 20,
        children = {
            UI.text { 
                text = "hello world",
                color = {1, 1, 1, 1}
            },
            UI.container {
                layout = "horizontal",
                padding = 10,
                spacing = 5,
                children = {
                    UI.rectangle {
                        width = 100,
                        height = 100,
                        color = {1, 0, 0, 1}
                    },
                    UI.rectangle {
                        width = 100,
                        height = 100,
                        color = {0, 1, 0, 1}
                    }
                }
            }
        }
    }
    
    root = UI.finish()
end

function love.update(dt)
    -- Update layouts only if something changed (window resize, content change, etc.)
    UI.calculateLayouts(root, 0, 0, 300, 300)
end

function love.draw()
    -- Just render the existing structure
    UI.render(root)
end