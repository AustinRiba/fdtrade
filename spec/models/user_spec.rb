require 'spec_helper'

describe User do

  before { @user = User.new(first: "Austin", last: "Riba", email: "user@example.com",
							password: "password", password_confirmation: "password", 
							house_id: 1, ident: "ab1234", rank: "Captain") }

  subject { @user }

  it { should respond_to(:first) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:last) }
  it { should respond_to(:phone) }
  it { should respond_to(:ident) }
  it { should respond_to(:house_id) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token)}
  it { should respond_to(:authenticate) }
  it { should respond_to(:rank) }
  it { should respond_to(:admin)}
  it { should respond_to(:trades)}

  
  it { should be_valid }
  it { should_not be_admin }
  
  describe "when admin attribute set to 'true'" do
	before do
		@user.save!
		@user.toggle!(:admin)
	end
	it { should be_admin }
  end
  
  describe "when email is not present" do
	before { @user.email = " "}
	it { should_not be_valid }
  end
  
  describe "when ident is not present" do
	before { @user.ident = " "}
	it { should_not be_valid }
  end
  
  describe "when first name is not present" do
	before { @user.first = " "}
	it { should_not be_valid }
  end
  
  describe "when last name is not present" do
	before { @user.last = " "}
	it { should_not be_valid }
  end
  
  describe "when name is too long" do
    before { @user.first = "a" * 51 }
    it { should_not be_valid }
  end
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end
  describe "when ident format is invalid" do
    it "should be invalid" do
      idents = %w[123456 asbcad ab12345
                     abc1234 ^%1234]
      idents.each do |invalid_ident|
        @user.ident = invalid_ident
        @user.should_not be_valid
      end      
    end
  end

  describe "when ident format is valid" do
    it "should be valid" do
      idents = %w[ab1234 Bn7584 PO0000]
      idents.each do |valid_ident|
        @user.ident = valid_ident
        @user.should be_valid
      end      
    end
  end
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
     it { should_not be_valid }
  end
  
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  describe "return value of authenticate method" do
	  before { @user.save }
	  let(:found_user) { User.find_by_email(@user.email) }

  describe "with valid password" do
    it { should == found_user.authenticate(@user.password) }
  end

  describe "with invalid password" do
    let(:user_for_invalid_password) { found_user.authenticate("invalid") }

    it { should_not == user_for_invalid_password }
    specify { user_for_invalid_password.should be_false }
  end
end

	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it { should be_invalid }
	end
	
	describe "remember token" do
		before { @user.save }
		its(:remember_token) { should_not be_blank }
	end
	describe "trade associations" do

    before { @user.save }
    let!(:sooner_trade) do 
      FactoryGirl.create(:trade, user: @user, date: 1.day.from_now)
    end
    let!(:further_trade) do
      FactoryGirl.create(:trade, user: @user, date: 2.days.from_now)
    end

    it "should have the right trades in the right order" do
      @user.trades.should == [sooner_trade, further_trade]
    end
    it "should destroy associated trades" do
      trades = @user.trades.dup
      @user.destroy
      trades.should_not be_empty
      trades.each do |trade|
        Trade.find_by_id(trade.id).should be_nil
      end
    end
  end
end
