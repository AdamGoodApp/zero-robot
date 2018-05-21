describe ApiKey do

  context 'on creation' do
    it 'should belong to a user' do
      a = ApiKey.reflect_on_association(:user)
      expect(a.macro).to eq(:belongs_to)
    end
  end

end