local collection = {}
collection.__index = collection

function collection.new()
    local list = setmetatable({}, collection)
    list.length = 0 
    list.__data = {}
    
    -- Iterator support
    function list:ipairs()
        local i = 0
        return function()
            i = i + 1
            if i <= self.length then
                return i-1, self.__data[i]
            end
        end
    end
    
    -- Basic operations
    function list:add(item)
        if item == nil then return end
        self.length = self.length + 1 
        table.insert(self.__data, item)
    end
    
    function list:value() 
        return self.__data
    end
    
    function list:at(index) 
        if index < 0 or index >= self.length then
            return nil
        end
        return self.__data[index + 1]
    end
    
    function list:pop()
        if self.length <= 0 then 
            return nil
        end

        local lastItem = self.__data[self.length]
        table.remove(self.__data, self.length)
        self.length = self.length - 1
        
        return lastItem
    end
    
    function list:front()
        return self.__data[1]
    end
    
    function list:back()
        return self.__data[self.length]
    end
    
    function list:empty()
        return self.length == 0
    end
    
    function list:clear()
        self.__data = {}
        self.length = 0
    end
    
    -- Enhanced operations
    function list:addRange(a, ...) 
        if a ~= nil then
            self:add(a)
            for _, v in ipairs({...}) do
                self:add(v)
            end
        end
    end
    
    function list:remove(index)
        if index < 0 or index >= self.length then
            return nil
        end
        local realIndex = index + 1
        local item = table.remove(self.__data, realIndex)
        self.length = self.length - 1
        return item
    end
    
    function list:insert(index, item)
        if index < 0 or index > self.length then
            return false
        end
        local realIndex = index + 1
        table.insert(self.__data, realIndex, item)
        self.length = self.length + 1
        return true
    end
    
    function list:indexOf(item)
        for i = 1, self.length do
            if self.__data[i] == item then
                return i - 1
            end
        end
        return -1
    end
    
    function list:contains(item)
        return self:indexOf(item) ~= -1
    end
    
    -- LÖVE specific helper for random access
    function list:random()
        if self.length == 0 then return nil end
        return self.__data[love.math.random(1, self.length)]
    end
    
    function list:filter(predicate)
        local result = collection.new()
        for i = 1, self.length do
            local item = self.__data[i]
            if predicate(item) then
                result:add(item)
            end
        end
        return result
    end
    
    function list:map(transform)
        local result = collection.new()
        for i = 1, self.length do
            result:add(transform(self.__data[i]))
        end
        return result
    end
    
    function list:forEach(fn)
        for i = 1, self.length do
            fn(self.__data[i], i-1)
        end
    end
    
    function list:print()
        print("Collection (length: " .. self.length .. ")")
        for i = 1, self.length do
            print(string.format("  [%d] = %s", i-1, tostring(self.__data[i])))
        end
    end
    
    -- Protect the internal data
    return setmetatable(list, {
        __index = list,
        __len = function(self) return self.length end,
        __pairs = function(self) return self:ipairs() end,
        __ipairs = function(self) return self:ipairs() end,
        __tostring = function(self) 
            return string.format("Collection(%d)", self.length)
        end
    })
end

return collection