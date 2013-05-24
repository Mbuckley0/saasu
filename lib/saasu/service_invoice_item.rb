module Saasu

  class ServiceInvoiceItem < Base

    elements  "description"         => :string,
              "accountUid"          => :integer,
              "taxCode"             => :string,
              "totalAmountInclTax"  => :decimal,
              "totalAmountExclTax"  => :decimal,
              "totalTaxAmount"      => :decimal
  end

end

