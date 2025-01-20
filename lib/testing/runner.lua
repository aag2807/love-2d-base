local lfs = require("lfs") -- Lua File System
local XLua = require("xlua")

local Runner = {
    test_pattern = "_test.lua$", -- Files ending with _test.lua
    test_directory = "tests",    -- Default test directory
    excluded_dirs = {            -- Directories to skip
        "%.git",
        "%.vscode",
        "node_modules"
    }
}

-- Check if a path should be excluded
local function is_excluded(path)
    for _, pattern in ipairs(Runner.excluded_dirs) do
        if path:match(pattern) then
            return true
        end
    end
    return false
end

-- Find all test files in a directory
function Runner.find_test_files(directory)
    local test_files = {}
    
    local function scan_directory(dir)
        for file in lfs.dir(dir) do
            if file ~= "." and file ~= ".." then
                local full_path = dir .. "/" .. file
                local attr = lfs.attributes(full_path)
                
                if attr then
                    if attr.mode == "directory" and not is_excluded(full_path) then
                        scan_directory(full_path)
                    elseif attr.mode == "file" and file:match(Runner.test_pattern) then
                        table.insert(test_files, full_path)
                    end
                end
            end
        end
    end
    
    scan_directory(directory)
    return test_files
end

-- Run a specific test file
function Runner.run_test_file(file_path)
    local success, err = pcall(function()
        dofile(file_path)
    end)
    
    if not success then
        print(XLua.error_color("Error loading test file: " .. file_path))
        print(XLua.error_color(err))
        return false
    end
    
    return true
end

-- Run all tests in directory
function Runner.run(directory)
    directory = directory or Runner.test_directory
    
    -- Validate directory exists
    local attr = lfs.attributes(directory)
    if not attr or attr.mode ~= "directory" then
        print(XLua.error_color("Error: Directory not found - " .. directory))
        return false
    end
    
    print(XLua.header("\nXLua Test Runner"))
    print(XLua.header("================"))
    print(XLua.info("Scanning for tests in: " .. directory))
    
    local test_files = Runner.find_test_files(directory)
    
    if #test_files == 0 then
        print(XLua.error_color("No test files found matching pattern: " .. Runner.test_pattern))
        return false
    end
    
    print(XLua.info("Found " .. #test_files .. " test files"))
    print("")
    
    local failed_files = 0
    
    for _, file in ipairs(test_files) do
        print(XLua.header("Running tests from: " .. file))
        if not Runner.run_test_file(file) then
            failed_files = failed_files + 1
        end
        print("")
    end
    
    print(XLua.header("Test Runner Summary"))
    print(XLua.header("=================="))
    print(XLua.info("Total test files: " .. #test_files))
    print(XLua.success_color("Passed files: " .. (#test_files - failed_files)))
    print(XLua.error_color("Failed files: " .. failed_files))
    
    return failed_files == 0
end

return Runner