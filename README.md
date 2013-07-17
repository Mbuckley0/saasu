# Saasu

This gem provide a ruby wrapper to the Saasu api. 

# History 

Originally started by Keiran Johnson this version of the Saasu library was forked and is now maintained by 
[Agworld Pty Ltd](http://www.agworld.co). It has a significant number of new features including creating
and updating of Saasu entities. 

## Installation

    gem install saasu
    
## Getting Started

Firstly setup the library with your api\_key and file\_uid

    Saasu::Base.api_key  = key
    Saasu::Base.file_uid = uid

To fetch all invoices

    invoices = Saasu::Invoice.all
    
By default all sales purchases are retrieved as this field is required.

You can pass in any conditions as a hash. The keys should be in snake case.

    invoices = Saasu::Invoice.all(:transaction_type => "p", :paid_status => "Unpaid")
    
For a complete list of supported options see the [Saasu API Reference](http://help.saasu.com/api/http-get/)
    
To fetch a single invoice by its uid

    invoice = Saasu::Invoice.find(uid)

To create a contact

    sc = Saasu::Contact.new
    
    sc.given_name = "firstname"
    sc.family_name = "lastname"
    sc.email_address = "email"
    sc.email = "email"
    sc.mobile_phone = "mobile"

    response = Saasu::Contact.insert(sc)

You can also add multiple contacts at once by passing an array of Saasu::Contacts to the insert method

    c1 = Saasu::Contact.new(:given_name => "firstname", :family_name => "lastname")
    c2 = Saasu::Contact.new(:given_name => "firstname", :family_name => "lastname")
    
    contacts_array = [c1, c2]
    
    response = Saasu::Contact.insert(contacts_array)

To add an invoice

    i = Saasu::Invoice.new
    i.uid = "0"
    i.transaction_type = "S"
    i.date = Time.now.strftime("%Y-%m-%d")
    i.layout = "S"
    i.status = "I"
    i.invoice_number = "&lt;Auto Number&gt;"
    i.invoice_type = "Sale Invoice"
    i.summary = "Summary"
    i.notes = "Notes"
    
    #optionally associate with a contact
    i.contact_uid = contact.saasu_uid

    fee = Saasu::ServiceInvoiceItem.new
    fee.description = "fee description"
    fee.account_uid = account_uid #e.g. 45555995
    fee.total_amount_incl_tax = 100.0

    i.invoice_items = [fee] #add as many line items to this array as needed

    #optionally add trading terms (see API reference)
    tt = Saasu::TradingTerms.new
    tt.type = 1
    tt.interval = 0
    tt.interval_type = 0
    i.trading_terms = tt

    #optionally include an email message to include with the invoice
    email = Saasu::EmailMessage.new
    email.to = "to@address.com"
    email.from = "from@address.com"
    email.subject = "Subject"
    email.body = "Email body"
    
    #optionally add payments
    qp = Saasu::QuickPayment.new
    qp.date_paid = Time.now.strftime("%Y-%m-%d")
    qp.banked_to_account_uid = account_uid #e.g. 302934848
    qp.amount = 100.0
    qp.summary = "auto entered: payment"
    i.quick_payment = [qp]

    # if you'd like to insert *and* email and invoice to the contact 
    response = Saasu::Invoice.insert_and_email(i, email, Setting.conference[:email_template].to_i)
    
    # of to just insert the invoice
    response = Saasu::Invoice.insert(i)

To retreive a pfd of an invoice

    Saasu::Invoice.get_pdf(uid_of_invoice, uid_of_email_template)
    
## Copyright

Some portions Copyright (c) 2013 Reuben Salagaras
Copyright (c) 2013 Agworld Pty Ltd. See LICENSE for details.

Original Portions - Copyright (c) 2011 Kieran Johnson.
