class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_password, :update_password]
  before_action :check_role, only: [:index]
  before_action :check_if_admin, only: [:edit, :new, :create, :update]


  # GET /users
  # GET /users.json
  def index
    @users = User.order(:last_name).order(:first_name)
    @programs = Program.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    today = Date.today
    @start = @user.start_date
    @num_months = calculate_months(today, @start)
    timerecords = TimeRecord.where("user_id = ?", @user.id)
    @vacation_used = timerecords.sum(:vacation)
    @sick_used = timerecords.sum(:sick)
    @accrued_vacation = @user.starting_vacation + (@num_months*(16 * @user.percent_time)) - @vacation_used
    @accrued_sick = @user.starting_sick + (@num_months * (8* @user.percent_time)) - @sick_used
  end

  # GET /users/new
  def new
    @user = User.new
    @programs = Program.all
  end

  # GET /users/1/edit
  def edit
    #@programs = Program.all
  end

  def user_transactions
    @user = params[:user]
    @transactions = @user.transactions
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
      respond_to do |format|
        if @user.save
          format.html { redirect_to users_path, notice: "User #{@user.first_name} #{@user.last_name} was successfully created." }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { redirect_to users_path, notice: "User was not created" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, notice: "User #{@user.first_name} #{@user.last_name} was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    count = @user.transactions.count
    if count == 0
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_url, notice: "User was successfully deleted." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to users_url, notice: "User cannot be deleted" }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_user
      @user = User.find(params[:id])
      @programs = Program.all
      #@user.calculate_vacation
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :admin, :splits, :percent_time, :coordinator, :accrued_vacation, :accrued_sick, :start_date, :starting_vacation, :starting_sick)
    end

    def calculate_months(today, pastDate)
      (today.year * 12 + today.month) - (pastDate.year * 12 + pastDate.month)
    end


end
