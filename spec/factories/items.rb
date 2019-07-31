FactoryBot.define do
  factory :item do
    name { Faker::Superhero.name }
    description { Faker::TvShows::TwinPeaks.quote }
    unit_price { 1 }
    merchant
  end
end
