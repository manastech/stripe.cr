class Stripe::Issuing::Cardholder
  include JSON::Serializable
  include StripeMethods

  add_retrieve_method

  add_list_method(
    email : String? = nil,
    phone_number : String? = nil,
    status : String? = nil,
    type : String? = nil,
    created : Hash(String, Int32)? = nil,
    limit : Int32? = nil,
    starting_after : String? = nil,
    ending_before : String? = nil
  )

  enum Type
    Individual
    Company
  end

  struct Billing
    include JSON::Serializable

    struct Address
      include JSON::Serializable

      getter city : String?
      getter country : String?
      getter line1 : String?
      getter line2 : String?
      getter postal_code : String?
      getter state : String?
    end

    getter address : Address?
  end

  struct Company
    include JSON::Serializable

    getter tax_id_provided : Bool?
  end

  struct Individual
    include JSON::Serializable

    struct CardIssuing
      include JSON::Serializable

      struct UserTermsAcceptance
        include JSON::Serializable

        @[JSON::Field(converter: Time::EpochConverter)]
        getter date : Time?
        getter ip : String?
        getter user_agent : String?
      end

      getter user_terms_acceptance : UserTermsAcceptance?
    end

    getter card_issuing : CardIssuing?
  end

  getter id : String
  getter billing : Billing?
  getter email : String?
  getter metadata : Hash(String, String) = {} of String => String
  getter name : String?
  getter phone_number : String?
  getter type : Type
  getter object = "issuing.cardholder"
  getter company : Company?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter individual : Individual?
  getter? livemode : Bool
  getter requirements : Hash(String, String | Array(String) | Nil)?
  getter spending_controls : Card::SpendingControls?

  def self.update(id : String,
                  billing : NamedTuple? = nil,
                  email : String? = nil,
                  metadata : Hash(String, String)? = nil,
                  phone_number : String? = nil,
                  company : Company? = nil,
                  individual : NamedTuple? = nil,
                  spending_controls : NamedTuple? = nil,
                  status : String? = nil)
    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(billing metadata phone_number company individual spending_controls status email) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = Stripe.client.post("/v1/issuing/cardholders/#{id}", form: io.to_s)
    if response.status_code == 200
      Stripe::Issuing::Cardholder.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end

  def self.create(billing : NamedTuple,
                  name : String,
                  type : String,
                  email : String?,
                  metadata : NamedTuple? = nil,
                  phone_number : String? = nil,
                  company : Company? = nil,
                  individual : NamedTuple? = nil,
                  spending_controls : NamedTuple? = nil,
                  status : String? = nil) : Stripe::Issuing::Cardholder
    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(type email billing name metadata phone_number company individual spending_controls status) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = Stripe.client.post("/v1/issuing/cardholders", form: io.to_s)

    if response.status_code == 200
      Stripe::Issuing::Cardholder.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
