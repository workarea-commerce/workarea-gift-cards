class Workarea::Catalog::Customizations::GiftCard < Workarea::Catalog::Customizations
  customized_fields :email, :from, :message

  validates :email, presence: true,
                    email:    true

  validates :from, length: { maximum: 100 }
  validates :message, length: { maximum: 500 }
end
