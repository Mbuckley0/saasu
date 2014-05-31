module Saasu

  class Invoice < Transaction

    attr_accessor :pdf

    elements "transactionType"    => :string,
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
            "isSent"              => :boolean,
            "tags"                => :string
    
    required_fields %w(uid lastUpdatedUid), :only => :update
    required_fields %w(transactionType invoiceType date layout status)
    defaults :query_options => { :transaction_type => "s", :incpayments => true }
    
    class << self
      # Fetch the PDF of an invoice by its uid
      # @param [Integer] the uid
      #
      def get_pdf(uid, template_uid = nil)
        options_hash = Hash.new.tap do |h|
          h[:uid] = uid
          h[:format] = "pdf"
          h[:templateUid] = template_uid if template_uid.present?
        end
 
        pdf = get(options_hash, false)
        response = new
        if pdf.is_a? Net::HTTPNotFound
          e = ErrorInfo.new
          e.type = "NotFound"
          e.message = "The invoice specified was not found"
          response.errors = e
        else
          response.pdf = pdf
        end

        response
      end
      
      def insert_and_email(entity, email, template_uid = nil)
        post({ :entity => entity, :task => :insert, :email => email, :send_email => true, :template_uid => template_uid })
      end
      
      def update_and_email(entity, email, template_uid = nil)
        post({ :entity => entity, :task => :update, :email => email, :send_email => true, :template_uid => template_uid })
      end
      
    end #class
  end
end
