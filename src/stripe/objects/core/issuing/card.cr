class Stripe::Issuing::Card
  include JSON::Serializable
  include StripeMethods

  add_create_method(
    cardholder : String,
    currency : String,
    type : String,
    metadata : Hash | NamedTuple? = nil,
    status : String? = nil,
    replacement_for : String? = nil,
    replacement_reason : String? = nil,
    shpping : String? = nil,
    spending_controls : NamedTuple? = nil
  )

  add_update_method(
    status : String? = nil,
    cancellation_reason : String? = nil,
    metadata : Hash | NamedTuple? = nil,
    pin : Hash(String, String)? = nil,
    spending_controls : String? = nil
  )

  add_list_method(
    cardholder : String? = nil,
    type : String? = nil,
    created : Hash(String, Int32)? = nil,
    limit : Int32? = nil,
    exp_month : Int32? = nil,
    exp_year : Int32? = nil,
    last4 : Int32? = nil,
    starting_after : String? = nil,
    ending_before : String? = nil
  )

  getter replacement_for : String?
  getter replacement_reason : ReplacementReason?
  getter shipping : Shipping?
  getter spending_controls : SpendingControls

  enum ReplacementReason
    Lost
    Stolen
    Damaged
    Expired
  end

  enum CancellationReason
    Lost
    Stolen
    DesignRejected
  end

  enum Status
    Active
    Inactive
    Canceled
  end

  enum Type
    Phisical
    Virtual
  end

  struct SpendingControls
    include JSON::Serializable

    struct SpendingLimits
      include JSON::Serializable

      enum Interval
        PerAuthorization
        Daily
        Weekly
        Monthly
        Yearly
        AllTime
      end

      getter amount : Int32 = 0
      getter categories : Array(String)?
      getter interval : Interval?
    end

    getter allowed_categories : Array(String)?
    getter blocked_categories : Array(String)?
    getter spending_limits : Array(SpendingLimits) = [] of SpendingLimits
    getter spending_limits_currency : String?
  end

  struct Shipping
    include JSON::Serializable

    enum Service
      Standard
      Express
      Priority
    end

    enum Status
      Pending
      Shipped
      Delivered
      Returned
      Failure
      Canceled
    end

    enum Type
      Bulk
      Individual
    end

    struct Address
      include JSON::Serializable

      getter city : String
      getter country : String
      getter line1 : String
      getter postal_code : String
      getter line2 : String?
      getter state : String?
    end

    struct Customs
      include JSON::Serializable
      getter eori_number : String?
    end

    getter name : String
    getter address : Address
    getter customs : Customs
    getter phone_number : String?
    getter require_signature : Bool?
    getter service : Service?
    getter status : Status?
    getter tracking_number : String?
    getter tracking_url : String?
    getter type : Type?
  end

  getter id : String
  getter cancellation_reason : CancellationReason?
  getter cardholder : String | Issuing::Cardholder
  getter currency : String
  getter exp_month : Int32
  getter exp_year : Int32
  getter last4 : String
  getter metadata : Hash(String, String)

  @[JSON::Field(converter: Enum::StringConverter(Stripe::Issuing::Card::Status))]
  getter status : Status

  @[JSON::Field(converter: Enum::StringConverter(Stripe::Issuing::Card::Type))]
  getter type : Type

  getter object = "issuing.card"
  getter brand : String

  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter cvc : String?
  getter? livemode : Bool
  getter number : String?
  getter replaced_by : String?
  getter replacement_for : String?
  getter replacement_reason : ReplacementReason?
  getter shipping : Shipping?
  getter spending_controls : SpendingControls
  getter? wallets : Hash(String, Hash(String, String | Bool | Nil)?)?

  def self.retrieve(id : String, expand : Array(String)? = nil)
    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(expand) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = Stripe.client.get("/v1/issuing/cards/#{id}", form: io.to_s)

    if response.status_code == 200
      Card.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
