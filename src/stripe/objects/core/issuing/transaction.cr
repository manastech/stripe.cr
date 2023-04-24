@[EventPayload]
class Stripe::Issuing::Transaction
  include JSON::Serializable

  enum Type
    Capture
    Refund
  end

  enum Wallet
    ApplePay
    GooglePay
    SamsungPay
  end

  getter id : String
  getter object : String = "issuing.transaction"
  getter amount : Int32 = 0
  getter amount_details : Hash(String, String?)
  getter authorization : String
  getter balance_transaction : String
  getter card : String
  getter cardholder : String

  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter currency : String
  getter metadata : Hash(String, String?)

  @[JSON::Field(converter: Enum::StringConverter(Stripe::Issuing::Transaction::Type))]
  getter type : Type

  getter dispute : String?
  getter livemode : Bool
  getter merchant_amount : Int32
  getter merchant_currency : String
  getter merchant_data : Hash(String, String?)
  getter purchase_details : Hash(String, String?)?

  @[JSON::Field(converter: Enum::StringConverter(Stripe::Issuing::Transaction::Wallet))]
  getter wallet : Wallet?
end
