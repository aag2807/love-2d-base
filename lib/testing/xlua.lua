local XLua = {
    passed = 0,
    failed = 0,
    tests = {},
    current_suite = nil,
    hooks = {
        beforeAll = {},
        afterAll = {},
        beforeEach = {},
        afterEach = {}
    }
}

local colors = {
    reset = "\27[0m",
    bright = "\27[1m",
    dim = "\27[2m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m"
}

-- Colored output helpers
local function colorize(color, text)
    return colors[color] .. text .. colors.reset
end

local function success_color(text)
    return colorize("green", text)
end

local function error_color(text)
    return colorize("red", text)
end

local function info(text)
    return colorize("cyan", text)
end

local function header(text)
    return colorize("bright", colorize("yellow", text))
end

-- XLua testing hooks
function XLua.beforeAll(fn)
    if XLua.current_suite then
        XLua.hooks.beforeAll[XLua.current_suite] = fn
    end
end

function XLua.beforeEach(fn)
    if XLua.current_suite then
        XLua.hooks.beforeEach[XLua.current_suite] = fn
    end
end

function XLua.afterAll(fn)
    if XLua.current_suite then
        XLua.hooks.afterAll[XLua.current_suite] = fn
    end
end

function XLua.afterEach(fn)
    if XLua.current_suite then
        XLua.hooks.afterEach[XLua.current_suite] = fn
    end
end

-- XLua create a new test suite
function XLua.suite(name, fn)
    XLua.current_suite = name
    fn()
    XLua.current_suite = nil
end

-- XLua register a test
function XLua.test(name, fn)
    table.insert(XLua.tests, {
        name = name,
        suite = XLua.current_suite,
        fn = fn
    })
end

-- XLua assertions
function XLua.assertEquals(expected, actual)
    if expected ~= actual then
        error(string.format(
            "Assertion failed:\nExpected: %s\nActual:   %s",
            tostring(expected),
            tostring(actual)
        ))
    end
end

function XLua.assertTrue(value)
    if not value then
        error("Assertion failed: Expected true but got false")
    end
end

function XLua.assertFalse(value)
    if value then
        error("Assertion failed: Expected false but got true")
    end
end

-- Helper function to execute hooks safely
local function runHook(hook, suite)
    if hook and type(hook) == "function" then
        local hook_passed, err = pcall(hook)
        if not hook_passed then
            print(error_color("Hook error: " .. tostring(err)))
            return false
        end
    end
    return true
end

-- Run all registered tests
function XLua.run()
    print("\n" .. header("Running tests..."))
    print(header("=============="))
    
    -- Group tests by suite
    local suites = {}
    for _, test in ipairs(XLua.tests) do
        local suite_name = test.suite or "_default"
        suites[suite_name] = suites[suite_name] or {}
        table.insert(suites[suite_name], test)
    end
    
    -- Run tests suite by suite
    for suite_name, suite_tests in pairs(suites) do
        print("\n" .. info("Suite: " .. suite_name))
        print(info("-----------------"))
        
        -- Run beforeAll hook
        if not runHook(XLua.hooks.beforeAll[suite_name]) then
            goto continue
        end
        
        -- Run suite tests
        for _, test in ipairs(suite_tests) do
            io.write(test.name .. ": ")
            
            -- Run beforeEach hook
            runHook(XLua.hooks.beforeEach[suite_name])
            
            -- Run test
            local test_passed, err = pcall(test.fn)
            
            -- Run afterEach hook
            runHook(XLua.hooks.afterEach[suite_name])
            
            if test_passed then
                print(success_color("✓ PASS"))
                XLua.passed = XLua.passed + 1
            else
                print(error_color("✗ FAIL"))
                print(error_color("Error: " .. tostring(err)))
                XLua.failed = XLua.failed + 1
            end
        end
        
        -- Run afterAll hook
        runHook(XLua.hooks.afterAll[suite_name])
        
        ::continue::
    end
    
    print("\n" .. header("Results:"))
    print(header("========"))
    print(success_color("Passed: " .. XLua.passed))
    print(error_color("Failed: " .. XLua.failed))
    print(info("Total:  " .. #XLua.tests))
    
    -- Show final status with color
    print("\n" .. (XLua.failed == 0 
        and success_color("✓ All tests passed!") 
        or error_color("✗ Some tests failed!")))
    
    return XLua.failed == 0
end

return XLua