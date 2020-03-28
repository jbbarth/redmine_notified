# Load the normal Rails helper
require File.expand_path("../../../redmine_base_rspec/spec/spec_helper", __FILE__)

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


