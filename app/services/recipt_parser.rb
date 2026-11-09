# Parses the plain-text POS receipt format (see db/seeds/receipt.txt) into a
# Recipt with one ReciptItem per unit, so each unit can be assigned to a person.
class ReciptParser
  MONEY = /\d[\d,]*\.\d{2}/
  ITEM_LINE = /\A(?<name>\S.*?)\s{2,}(?:(?<paid>#{MONEY})\s+)?(?<due>#{MONEY})\s*\z/
  QTY_LINE = /\A\s+(?<qty>\d+)\s*@\s*(?<unit>#{MONEY})\s*ea/
  RULE = /\A-{10,}\s*\z/

  Line = Struct.new(:name, :qty, :unit_cents, :paid, keyword_init: true)

  def self.import!(text, venue: nil) = new(text).import!(venue:)

  def initialize(text)
    @lines = text.lines.map(&:chomp)
  end

  def import!(venue: nil)
    categories = parse_categories
    Recipt.transaction do
      recipt = Recipt.create!(venue:, server: header("Server"), opened_at: opened_at)
      position = 0
      parse_items.each do |line|
        line.qty.times do
          recipt.recipt_items.create!(
            name: line.name, price: line.unit_cents, paid: line.paid,
            category: categories[line.name], position: position += 1
          )
        end
      end
      recipt
    end
  end

  def parse_items
    start = @lines.index { |l| l =~ RULE }
    items = []
    @lines[(start + 1)..].each do |l|
      break if l =~ RULE
      if (m = QTY_LINE.match(l)) && items.any?
        items.last.qty = m[:qty].to_i
        items.last.unit_cents = cents(m[:unit])
      elsif (m = ITEM_LINE.match(l))
        paid_cents = m[:paid] ? cents(m[:paid]) : 0
        items << Line.new(name: m[:name].strip, qty: 1,
                          unit_cents: paid_cents + cents(m[:due]),
                          paid: paid_cents.positive? && cents(m[:due]).zero?)
      end
    end
    items
  end

  # Reads the "TOTALS BY ITEM" section: headings like DRINKS / FOOD followed by
  # "name  qty  unit  total" rows. Returns { "ORION TAP" => "Drinks", ... }.
  def parse_categories
    start = @lines.index { |l| l.strip == "TOTALS BY ITEM" } or return {}
    current = nil
    @lines[(start + 1)..].each_with_object({}) do |l, map|
      if l =~ /\A[A-Z]+\s*\z/
        current = l.strip.capitalize
      elsif current && (m = /\A(?<name>\S.*?)\s{2,}\d+\s+#{MONEY}\s+#{MONEY}\s*\z/.match(l))
        map[m[:name].sub(/\s+\(.*\)\z/, "")] = current # "SET MENU (paid/invoiced)" -> "SET MENU"
      end
    end
  end

  private

  def header(key)
    @lines.find { |l| l.start_with?("#{key}:") }&.split(":", 2)&.last&.strip
  end

  def opened_at
    raw = header("Opened") or return nil
    Time.zone.strptime(raw, "%I:%M %p %d %b %y")
  rescue ArgumentError
    nil
  end

  def cents(str) = (str.delete(",").to_d * 100).to_i
end
