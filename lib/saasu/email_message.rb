module Saasu
  class EmailMessage < Base

    elements "from" => :string,
              "to" => :string,
              "cc" => :string,
              "bcc" => :string,
              "subject" => :string,
              "body" => :string
  end
end


