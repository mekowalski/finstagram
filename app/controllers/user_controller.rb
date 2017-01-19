class UserController < ApplicationController

  get '/login' do
    if !is_logged_in?
      erb :'/users/login'
    else
      redirect '/posts'
    end
  end

  post '/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/posts'
    else
      flash[:error] = "Your login information seems to be incorrect."
      redirect '/login'
    end
  end

  get '/signup' do
    if !is_logged_in?
      erb :'/users/signup'
    else
      redirect '/posts'
    end
  end

  post '/signup' do
    @user = User.new(username: params[:username], learn_handle: params[:learn_handle], password: params[:password])
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Created successfully!"
      redirect '/posts'
    else
      flash[:error] = @user.errors.full_messages
      redirect '/signup'
    end
  end

  get '/logout' do
    session.clear
    flash[:success] = "See you next time!"
    redirect '/login'
  end

  get '/users/:id' do
    @user = User.find_by_id(params[:id])
    if @user
      erb :'/users/id'
    end
  end

  get '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    if is_logged_in? && @user == current_user
      erb :'/users/edit'
    else
      flash[:error] = "This is not your account to edit"
      redirect '/login'
    end
  end

  post '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    if is_logged_in? && @user.id == current_user.id
      erb :'/users/edit'
    else
      flash[:error] = "This is not your account to edit"
      redirect '/login'
    end
  end

  patch '/users/:id' do
    @user = User.find_by_id(params[:id])
    if params[:file]
      @filename = params[:file][:filename]
      file = params[:file][:tempfile]
      File.open("./public/images/profile/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end
      @user.update(user_photo: @filename)
      flash[:success] = "Profile successfully updated!"
      redirect "/users/#{@user.id}"
    else
      flash[:error] = "Your profile did not update correctly"
      redirect "/users/#{@user.id}/edit"
    end
  end

end
