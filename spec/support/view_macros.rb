class FakeMapping
  def initialize(recoverable=:no, rememberable=:no)
    @recoverable = recoverable == :recoverable
    @rememberable = rememberable == :rememberable
  end

  def recoverable?
    @recoverable
  end

  def rememberable?
    @rememberable
  end
end

module ViewMacros

  def config_view(options)
    before(:each) do
      meta_view = class << view; self; end
      options.each do |option|
        meta_view.send :define_method, option[0], proc { option[1] }
      end
    end
  end

end