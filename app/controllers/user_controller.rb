class UserController < ApplicationController

  get '/login' do
    if !is_logged_in?(session)
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
    if !is_logged_in?(session)
      erb :'/users/new'
    else
      redirect '/posts'
    end
  end

  post '/signup' do
    if params.none? {|k, v| v == ""}
      @user = User.create(username: params[:username], learn_handle: params[:learn_handle], password: params[:password])
      @filename = params[:file][:filename]
      file = params[:file][:tempfile]
      File.open("./public/images/profile/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end
      @user.user_photo = @filename
      @user.save
      session[:user_id] = @user.id
      flash[:success] = "Created successfully!"
      redirect '/posts'
    else
      flash[:error] = "Unsuccessfully created."
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
      erb :'/users/users'
    else
      "redirect somewhere"
    end
  end

  get '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    if is_logged_in?(session) && @user == current_user
      erb :'/users/edit'
    elsif is_logged_in?(session) && @user != current_user
      flash[:error] = "This is not your profile to edit"
      redirect '/posts'
    else
      flash[:error] = "Please log in"
      redirect '/login'
    end
  end

  post '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    if is_logged_in?(session) && @user.id == current_user.id
      erb :'/users/edit'
    elsif is_logged_in?(session) && @user.id != current_user.id
    flash[:error] = "This is not your profile to edit"
    redirect '/posts'
    else
      flash[:error] = "Please log in"
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
      flash[:success] = "Profile photo successfully updated!"
      redirect "/users/#{@user.id}"
    else
      flash[:error] = "Your profile did not update correctly"
      redirect "/users/#{@user.id}/edit"
    end
  end

end
