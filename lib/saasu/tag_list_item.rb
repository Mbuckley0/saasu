module Saasu

  class TagListItem < Entity

    elements  "tagUid"                => :integer,
              "name"                  => :string,
              "isActive"              => :boolean,
              "isPopular"             => :boolean,
              "isActivity"            => :boolean,
              "isPM"                  => :boolean,
              "isConnector"           => :boolean,
              "isInbuilt"             => :boolean,
              "isCustomer"            => :boolean,
              "isProspect"            => :boolean,
              "isSupplier"            => :boolean,
              "isPartner"             => :boolean,
              "frequency"             => :integer,
              "lastModified"          => :date,
              "lastModifiedByUserId"  => :integer
  end

end