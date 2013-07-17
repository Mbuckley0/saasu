module Saasu

  class ItemInvoiceItem < Base

    elements  "quantity"            => :decimal,
              "inventoryItemUid"    => :integer,
              "description"         => :string,
              "taxCode"             => :string,
              "unitPriceInclTax"    => :decimal,
              "totalAmountInclTax"  => :decimal,
              "totalAmountExclTax"  => :decimal,
              "totalTaxAmount"      => :decimal,
              "percentageDiscount"  => :decimal

    required_fields %w(quantity inventoryItemUid unitPriceInclTax)
  end

end