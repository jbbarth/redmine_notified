# Load the normal Rails helper
require File.expand_path("../../../redmine_base_rspec/spec/spec_helper", __FILE__)

# Taken from core
def with_settings(options, &block)
  saved_settings = options.keys.inject({}) do |h, k|
    h[k] = case Setting[k]
      when Symbol, false, true, nil
        Setting[k]
      else
        Setting[k].dup
      end
    h
  end
  options.each {|k, v| Setting[k] = v}
  yield
ensure
  saved_settings.each {|k, v| Setting[k] = v} if saved_settings
end

def assert_mail_body_match(expected, mail, message=nil)
  if expected.is_a?(String)
    expect(mail_body(mail)).to include(expected)
  else
    assert_match expected, mail_body(mail), message
  end
end

def assert_mail_body_no_match(expected, mail, message=nil)
  if expected.is_a?(String)
    expect(mail_body(mail)).to_not include expected
  else
    assert_no_match expected, mail_body(mail), message
  end
end

def mail_body(mail)
  mail.parts.first.body.encoded
end


