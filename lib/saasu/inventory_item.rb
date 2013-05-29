module Saasu

  class InventoryItem < Entity

    elements  "code"                      => :string,
              "description"               => :string,
              "isActive"                  => :boolean,
              "isInventoried"             => :boolean,
              "assetAccountUid"           => :integer,
              "stockOnHand"               => :decimal,
              "currentValue"              => :decimal,
              "quantityOnOrder"           => :integer,
              "quantityCommitted"         => :integer,
              "isBought"                  => :boolean,
              "purchaseExpenseAccountUid" => :integer,
              "minimumStockLevel"         => :integer,
              "primarySupplierContactUid" => :integer,
              "defaultReOrderQuantity"    => :integer,
              "isSold"                    => :boolean,
              "saleIncomeAccountUid"      => :integer,
              "saleTaxCode"               => :string,
              "saleCoSAccountUid"         => :integer,
              "sellingPrice"              => :decimal,
              "isSellingPriceIncTax"      => :boolean,
              "buyingPrice"               => :decimal,
              "isBuyingPriceIncTax"       => :boolean,
              "isVoucher"                 => :boolean,
              "validFrom"                 => :date,
              "validTo"                   => :date,
              "isVirtual"                 => :boolean,
              "isVisible"                 => :boolean,
              "rrpInclTax"                => :decimal

    request_url "fullinventoryitemList"
    list_item   "inventoryItem"
  end

end

