# frozen_string_literal: true

def silent_warnings
  old_stderr = $stderr
  $stderr = StringIO.new
  yield
ensure
  $stderr = old_stderr
end

def require_silent(name)
  silent_warnings do
    require name
  end
end
