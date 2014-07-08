module Saasu
  class Contact < Entity

    elements  "salutation" => :string,
              "givenName" => :string,
              "middleInitials" => :string,
              "familyName" => :string,
              "dateOfBirth" => :date,

              # only these 2 when fetching all it seems
              "organisation" => :string,
              "organisationUid" => :integer,

              "organisationName" => :string,
              "organisationAbn" => :string,
              "organisationWebsite" => :string,
              "organisationPosition" => :string,
              "contactID" => :string,
              "abn" => :string,
              "websiteUrl" => :string,
              "email" => :string,
              "email_address" => :string,     # really! it's not consistant
              "mainPhone" => :string,
              "homePhone" => :string,
              "fax" => :string,
              "mobilePhone" => :string,
              "otherPhone" => :string,
              "statusUid" => :integer,
              "industryUid" => :integer,
              "postalAddress" => :PostalAddress,
              "otherAddress" => :PostalAddress,
              "street" => :string,
              "city" => :string,
              "postCode" => :string,
              "state" => :string,
              "isActive" => :boolean,
              "acceptDirectDeposit" => :boolean,
              "directDepositAccountName" => :string,
              "acceptCheque" => :boolean,
              "chequePayableTo" => :string,
              "tags" => :string,
              "customField1" => :string,
              "customField2" => :string,
              "twitterID" => :string,
              "skypeID" => :string,
              "linkedInPublicProfile" => :string,
              "autoSendStatement" => :boolean,
              "isPartner" => :boolean,
              "isCustomer" => :boolean,
              "isSupplier" => :boolean,
              "saleTradingTermsType" => :integer,
              "saleTradingTermsPaymentDueInInterval" => :integer,
              "saleTradingTermsPaymentDueInIntervalType" => :integer,
              "purchaseTradingTermsPaymentDueInInterval" => :integer,
              "purchaseTradingTermsPaymentDueInIntervalType" => :integer,
              "defaultSaleDiscount" => :decimal,
              "defaultPurchaseDiscount" => :decimal,
              "error" => :string

    required_fields %w(uid lastUpdatedUid), :only => :update
    class_response_list "contact"
  end
end

