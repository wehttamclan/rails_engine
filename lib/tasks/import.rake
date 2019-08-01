require 'csv'

namespace :import do
  desc "TODO"
  task all: :environment do
    CSV.foreach('./data/merchants.csv', headers: true, header_converters: :symbol) do |row|
      Merchant.create(row.to_h)
    end

    CSV.foreach('./data/customers.csv', headers: true, header_converters: :symbol) do |row|
      Customer.create(row.to_h)
      break if Customer.all.size >= 100
    end

    CSV.foreach('./data/items.csv', headers: true, header_converters: :symbol) do |row|
      # Item shouldn't be created if merchant id doesn't exist.
      Item.create(row.to_h)
    end

    CSV.foreach('./data/invoices.csv', headers: true, header_converters: :symbol) do |row|
      # Invoice shouldn't be created if assiciated customer id or merchant id doesn't exist.
      Invoice.create(row.to_h) if Customer.where(id: row[:customer_id]).first
    end

    CSV.foreach('./data/transactions.csv', headers: true, header_converters: :symbol) do |row|
      # Transaction shouldn't be created if associated invoice id doesn't exist.
      if Invoice.where(id: row[:invoice_id]).first
        Transaction.create(row.to_h.slice(:invoice_id, :credit_card_number, :result, :created_at, :updated_at))
      end
    end

    CSV.foreach('./data/invoice_items.csv', headers: true, header_converters: :symbol) do |row|
      # InvoiceItem shounldn't be created if item id or invoice id doesn't exist.
      if Item.where(id: row[:item_id]).first && Invoice.where(id: row[:invoice_id]).first
        InvoiceItem.create(row.to_h)
      end
    end

    puts "Merchants: #{Merchant.all.size}"
    puts "Customers: #{Customer.all.size}"
    puts "Items: #{Item.all.size}"
    puts "Invoices: #{Invoice.all.size}"
    puts "Transactions: #{Transaction.all.size}"
    puts "InvoiceItem: #{InvoiceItem.all.size}"
  end
end
