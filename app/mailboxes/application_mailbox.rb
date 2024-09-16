class ApplicationMailbox < ActionMailbox::Base
  routing /\S+/ => :incomings
end
