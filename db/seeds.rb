# Imports the sample receipt. Idempotent: skips if it is already there.
unless Recipt.exists?(opened_at: Time.zone.local(2026, 11, 6, 17, 55))
  recipt = ReciptParser.import!(Rails.root.join("db/seeds/receipt.txt").read)
  puts "Imported receipt ##{recipt.id}: #{recipt.recipt_items.count} items, " \
       "total $#{'%.2f' % (recipt.total_cents / 100.0)}"
end
