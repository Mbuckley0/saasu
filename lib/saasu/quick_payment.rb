module Saasu
  class QuickPayment < Base

    root "quickPayment"

    elements  "datePaid" => :date,
              "dateCleared" => :date,
              "bankedToAccountUid" => :integer,
              "amount" => :decimal,
              "reference" => :string,
              "summary" => :string

  end
end
 

