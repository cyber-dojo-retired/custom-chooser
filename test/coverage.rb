require 'simplecov'

code_name = ENV['COVERAGE_CODE_GROUP_NAME']
test_name = ENV['COVERAGE_TEST_GROUP_NAME']

SimpleCov.start do
  #enable_coverage :branch
  filters.clear
  coverage_dir(ENV['COVERAGE_ROOT'])
  #add_group('debug') { |src| puts src.filename; false }
  add_group(code_name) { |src| src.filename =~ %r"^/app/" }
  add_group(test_name) { |src| src.filename =~ %r"^/test/.*_test\.rb$" }
end
