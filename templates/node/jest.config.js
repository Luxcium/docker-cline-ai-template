export default {
  // Use ES modules
  type: 'module',
  
  // The test environment that will be used for testing
  testEnvironment: 'node',
  
  // An array of file extensions your modules use
  moduleFileExtensions: ['js', 'mjs', 'cjs', 'jsx', 'json'],
  
  // The glob patterns Jest uses to detect test files
  testMatch: [
    '**/tests/**/*.[jt]s?(x)',
    '**/?(*.)+(spec|test).[jt]s?(x)'
  ],
  
  // An array of regexp pattern strings that are matched against all test paths
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/'
  ],
  
  // A map from regular expressions to paths to transformers
  transform: {},
  
  // Automatically clear mock calls, instances, contexts and results before every test
  clearMocks: true,
  
  // Indicates whether the coverage information should be collected while executing the test
  collectCoverage: true,
  
  // The directory where Jest should output its coverage files
  coverageDirectory: 'coverage',
  
  // An array of regexp pattern strings used to skip coverage collection
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/dist/'
  ],
  
  // Indicates which provider should be used to instrument code for coverage
  coverageProvider: 'v8',
  
  // A list of reporter names that Jest uses when writing coverage reports
  coverageReporters: [
    'json',
    'text',
    'lcov',
    'clover'
  ],
  
  // The root directory that Jest should scan for tests and modules within
  rootDir: '.',
  
  // A list of paths to directories that Jest should use to search for files in
  roots: [
    '<rootDir>/src'
  ],
  
  // Allows you to use a custom runner instead of Jest's default test runner
  runner: 'jest-runner',
  
  // The paths to modules that run some code to configure or set up the testing environment
  setupFiles: [],
  
  // A list of paths to modules that run some code to configure or set up the testing framework
  setupFilesAfterEnv: [],
  
  // Elapsed time before a test is considered slow
  slowTestThreshold: 5,
  
  // The test runner that will be used to execute the tests
  testRunner: 'jest-circus/runner',
  
  // This option allows use of a custom test runner
  runner: 'jest-runner',
  
  // An array of regexp pattern strings that are matched against all source file paths before re-running tests
  watchPathIgnorePatterns: [
    '/node_modules/',
    '/dist/'
  ],
  
  // Whether to use watchman for file crawling
  watchman: true,
  
  // An array of regexp patterns that are matched against all source file paths before transformation
  transformIgnorePatterns: [
    '/node_modules/',
    '\\.pnp\\.[^\\/]+$'
  ]
};
