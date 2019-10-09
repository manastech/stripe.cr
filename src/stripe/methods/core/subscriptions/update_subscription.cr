class Stripe
  def update_subscription(
    subscription : String | Subscription,
    customer : String | Customer? | Unset = Unset.new,
    coupon : String? | Unset = Unset.new,
    default_source : String | Token? | Unset = Unset.new,
    default_payment_method : String | Token? | Unset = Unset.new,
    metadata : Hash? | Unset = Unset.new,
    items : U? | Unset = Unset.new,
  ) : Subscription forall T, U
    default_source = default_source.as(Token).id if default_source.is_a?(Token)

    default_payment_method = default_payment_method.as(Token).id if default_payment_method.is_a?(Token)

    validate items, {{U}} do
      type id : String,
      type quantity : Int32,
      type plan : String
    end

    customer = customer.as(Customer).id if customer.is_a?(Customer)

    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(customer coupon default_source metadata default_payment_method items) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.is_a?(Unset)
    {% end %}

    case subscription
    when String   then sub_id = subscription
    when Subscription then sub_id = subscription.id
    end

    response = @client.post("/v1/subscriptions/#{sub_id}", form: io.to_s)

    if response.status_code == 200
      return Subscription.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
