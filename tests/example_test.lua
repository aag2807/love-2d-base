local XLua = require "lib.xlua"

XLua.suite("My Test Suite", function()
    -- Setup hooks if needed
    XLua.beforeAll(function()
        -- Run once before all tests in this suite
    end)

    XLua.beforeEach(function()
        -- Run before each test
    end)

    XLua.test("should do something", function()
        XLua.assertTrue(true)
    end)

    XLua.afterEach(function()
        -- Run after each test
    end)

    XLua.afterAll(function()
        -- Run once after all tests in this suite
    end)
end)