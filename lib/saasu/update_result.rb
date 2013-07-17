module Saasu
  class UpdateResult < Base
      attributes "updatedEntityUid" => :integer,
                 "lastUpdatedUid" => :string,
                 "utcLastModified" => :date,
                 "sentToContact" => :boolean
  end
end
