module Saasu
  
  class Payment < Entity

    elements  "invoicePaymentUid" => :integer,
              "paymentDate" => :date,  
              "dateCleared" => :date,
              "summary" => :string,
              "ccy" => :string,
              "autoPopulateFxRate" => :boolean,
              "fcToBcFxRate" => :decimal,
              "reference" => :string,
              "bankAccountUid" => :integer,
              "bankAccountName" => :string,
              "amount" => :decimal
  end
  
end

