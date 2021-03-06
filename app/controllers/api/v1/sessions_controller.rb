class Api::V1::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :verify_signed_out_user

  respond_to :json

  def create
    @email = params[:user][:email].downcase
    if User.where(email: @email).count > 0
      @user = User.where(email: @email).first
      if @user.valid_password?(params[:user][:password])
        render :status => 200,
               :json => { :success => true,
                          :info => "Logged in",
                          :data => { :auth_token => @user.authentication_token, :name => @user.name } }
      else
        render :status => 401,
           :json => { :success => false,
                      :info => "Incorrect Password",
                      :data => {} }
      end
    else
      render :status => 401,
           :json => { :success => false,
                      :info => "Could not find a user with that email.",
                      :data => {} }
    end
  end

  def destroy
    warden.authenticate!(:scope => resource_name, :store => false, :recall => "#{controller_path}#failure")
    current_user.update_column(:authentication_token, nil)
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged out",
                      :data => {} }
  end

  def failure
    render :status => 401,
           :json => { :success => false,
                      :info => "Login Failed",
                      :data => {} }
  end


end