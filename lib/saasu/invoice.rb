module Saasu

  class Invoice < Transaction

    elements  "transactionType"     => :string,
              "invoiceType"         => :string,
              "date"                => :string,
              "contactUid"          => :string,
              "shipToContactUid"    => :integer,
              "folderUid"           => :integer,
              "tags"                => :string,
              "reference"           => :string,
              "summary"             => :string,
              "ccy"                 => :string,
              "autoPopulateFxRate"  => :boolean,
              "fcToBxFxRate"        => :decimal,
              "notes"               => :string,
              "externalNotes"       => :string,
              "requiresFollowUp"    => :boolean,
              "dueOrExpiryDate"     => :date,
              "tradingTerms"        => :TradingTerms,
              "layout"              => :string,
              "status"              => :string,
              "invoiceNumber"       => :string,
              "purchaseOrderNumber" => :string,
              "invoiceItems"        => :array,
              "quickPayment"        => :array,
              "payments"            => :array,
              "totalAmountInclTax"  => :decimal,
              "totalAmountExclTax"  => :decimal,
              "totalTaxAmount"      => :decimal,
              "isSent"              => :boolean

    required_fields %w(uid lastUpdatedUid), :only => :update
    required_fields %w(transactionType invoiceType date layout status)
    defaults :query_options => { :transaction_type => "s" }
  end

end
