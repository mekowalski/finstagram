class PostController < ApplicationController

  get '/posts' do
    if is_logged_in?(session)
      @posts = Post.all.sort_by {|post| post.id}.reverse
      erb :'/posts/posts'
    else
      flash[:error] = "Please log in"
      redirect '/login'
    end
  end

  get '/posts/new' do
    if is_logged_in?(session)
      erb :'/posts/new'
    else
      flash[:error] = "Please log in"
      redirect '/login'
    end
  end

  post '/posts' do
    if params[:file] && params[:caption] != ""
      @post = Post.create(caption: params[:caption], user_id: session[:user_id])

      @filename = params[:file][:filename]
      file = params[:file][:tempfile]

      File.open("./public/images/post/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end

      @post.post_photo = @filename
      @post.save
      # binding.pry
      flash[:success] = "Post successfully made!"
      redirect '/posts'
    else
      flash[:error] = "Please make sure both fields are present."
      redirect '/posts/new'
    end
  end

  get '/posts/:id' do
    if is_logged_in?(session)
      @post = Post.find_by_id(params[:id])
      erb :'/posts/id'
    else
      flash[:error] = "Please log in"
      redirect '/login'
    end
  end

  post '/posts/:id/edit' do
    @post = Post.find_by_id(params[:id])
    if is_logged_in?(session) && @post.user_id == current_user.id
      erb :'/posts/edit'
    elsif is_logged_in?(session) && @post.user_id != current_user.id
    flash[:error] = "This is not your post to edit"
    redirect '/posts'
    else
      flash[error] = "Please log in"
      redirect '/login'
    end
  end

  patch '/posts/:id' do
    post = Post.find_by_id(params[:id])
    if params[:caption] != ""
      post.update(caption: params[:caption])
      flash[:success] = "Post successfully updated!"
      redirect "/posts/#{post.id}"
    else
      flash[:error] = "Your post did not update correctly"
      redirect "/posts/#{post.id}/edit"
    end
  end

  delete '/posts/:id/delete' do
    post = Post.find_by_id(params[:id])
    if is_logged_in?(session) && post.user_id == current_user.id
      post.delete
      flash[:success] = "Post removed"
      redirect '/posts'
    elsif is_logged_in?(session) && post.user_id != current_user.id
      flash[:error] = "This is not your post to delete"
      redirect '/posts'
    else
      flash[:error] = "Please log in"
      redirect '/login'
    end
  end

end
