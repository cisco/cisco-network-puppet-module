require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:         agent,
  master:        master,
  resource_name: 'name_server',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:create] = {
  desc:           '1.1 Create Name Server',
  title_pattern:  '7.7.7.7',
  manifest_props: {
    ensure: 'present',
  },
  code:           [0, 2],
}

# Test hash test cases
tests[:delete] = {
  desc:           '2.1 Delete Name Server',
  title_pattern:  '7.7.7.7',
  manifest_props: {
    ensure: 'absent',
  },
  code:           [0, 2],
}

def cleanup(agent)
  test_set(agent, 'no ip name-server 7.7.7.7')
end
#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Create Property Testing")
  test_harness_run(tests, :create)
  # # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Delete Property Testing")
  test_harness_run(tests, :delete)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
