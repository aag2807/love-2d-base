# XLua Tests

This directory contains the test files for your Lua projects. XLua will automatically find and run any files that end with `_test.lua`.

## Directory Structure

```
tests/
├── unit/                  # Unit tests
│   ├── models_test.lua    
│   └── utils_test.lua     
├── integration/           # Integration tests
│   └── api_test.lua       
└── fixtures/              # Test fixtures and data
    └── test_data.lua      
```

## Writing Tests

### Basic Test Structure

```lua
local XLua = require("xlua")

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
```

### Available Assertions

```lua
-- Equality
XLua.assertEquals(expected, actual)

-- Boolean checks
XLua.assertTrue(value)
XLua.assertFalse(value)
```

## Running Tests

### Run All Tests
```bash
lua run_tests.lua
```

### Run Tests in Specific Directory
```bash
lua run_tests.lua tests/unit
```

## Test Naming Conventions

1. Test files should end with `_test.lua`
2. Test suites should describe the module or functionality being tested
3. Individual tests should describe the expected behavior
4. Use descriptive names for test functions

Example:
```lua
-- user_model_test.lua
XLua.suite("UserModel", function()
    XLua.test("should validate email format", function()
        -- test code here
    end)
end)
```

## Best Practices

1. **Isolation**: Each test should be independent and not rely on other tests
2. **Setup/Teardown**: Use hooks to properly set up and clean up test environment
3. **Single Purpose**: Each test should verify one specific behavior
4. **Clear Intent**: Test names should clearly describe what is being tested
5. **Fixtures**: Store test data in the fixtures directory
6. **Organization**: Group related tests into suites

## Excluded Directories

The test runner automatically excludes these directories:
- `.git`
- `.vscode`
- `node_modules`

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed or an error occurred

## Debugging Tests

When a test fails, XLua provides:
1. Colored output indicating failed tests
2. Error messages with stack traces
3. Suite and test names for easy identification
4. Summary of total passed/failed tests

## Contributing New Tests

1. Create a new test file in the appropriate directory
2. Follow the naming convention `*_test.lua`
3. Write clear, focused tests
4. Include both positive and negative test cases
5. Run the full test suite before submitting