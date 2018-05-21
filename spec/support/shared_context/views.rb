shared_context 'a view that renders errors' do | errors |
  context 'with errors' do
    config_view [[:resource, FakeUser.new('a', errors: errors)]]

    it 'renders the error' do
      render
      for error, list in errors
        for message in list
          expect(rendered).to match(message)
        end
      end
    end
  end
end

shared_context 'a view with a flash' do | type, text |
  context "when a #{type} flash is generated" do
    before (:each) do
      flash[type] = text
    end

    it 'renders the flash correctly' do
      render
      expect(rendered).to match(text)
    end
  end
end
