module Saasu

  class TransactionCategoryListItem < Entity

    elements  "transactionCategoryUid"  => :integer,
              "lastUpdatedUid"          => :string,
              "type"                    => :string,
              "name"                    => :string,
              "ledgerCode"              => :string,
              "defaultTaxCode"          => :string,
              "isActive"                => :boolean,
              "isInbuilt"               => :boolean
  end
end