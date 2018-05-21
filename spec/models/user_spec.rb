describe User do

  let(:user) { FactoryGirl.create :user }

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  context 'on creation' do
    it 'is invalid without a email' do
      expect(build(:user, email: nil)).to_not be_valid
    end

    it 'is invalid without a password' do
      expect(build(:user, password: nil)).to_not be_valid
    end

    it 'should belong to a robot' do
      t = User.reflect_on_association(:robot)
      expect(t.macro).to eq(:belongs_to)
    end

    it 'should have many api keys' do
      t = User.reflect_on_association(:api_keys)
      expect(t.macro).to eq(:has_many)
    end
  end

end