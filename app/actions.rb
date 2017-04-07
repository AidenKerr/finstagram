require "bcrypt"

helpers do
    def current_user
        User.find_by(id: session[:user_id])
    end
end

get '/' do
    @posts = Post.order(created_at: :desc)
    erb :index
end

get "/secret/:name" do
   "Hello world! #{params[:name]} #{params[:school]}" 
end

get /\A\/user\/([\d]+)\z/ do
    #if params['captures'].first.to_i > 0 && params['captures'].first.to_i <= User.all.size
    if User.exists?(params['captures'].first)
        @userpage = User.find(params['captures'].first)
        @posts = @userpage.posts.order(created_at: :desc)
        if @posts.any?
            erb :userpage
        else
            erb :no_profile
        end
    else
        status 404
        erb :oops
    end
end

get /\A\/user\/([\w]+)\z/ do
    if User.where(username: params['captures'].first).count > 0
        @userpage = User.find_by(username: params['captures'].first)
        @posts = @userpage.posts.order(created_at: :desc)
        if @posts.any?
            erb :userpage
        else
            erb :no_profile
        end
    else
        status 404
        erb :oops
    end
end

get "/signup" do
    @user = User.new
    erb :signup
end

post "/signup" do
   
    # grab user input values from params
    email      = params[:email]
    avatar_url = params[:avatar_url]
    username   = params[:username]
    password   = params[:password]
   
   # instantiate a User
    @user = User.new({email: email, avatar_url: avatar_url, username: username})
    @user.password = BCrypt::Password.create(password)
    
    # if user validations pass and user is saved
    if @user.save
        
        # File uploads
        if params[:file]
            filename = params[:file][:filename]
            tempfile = params[:file][:tempfile]
            puts params[:file]
            target = "public/files/#{@user.id}#{File.extname(filename)}"
            
            File.open(target, 'wb') {|f| f.write tempfile.read }
            
            @user.avatar_url = "/files/#{target.split("/").last}"
            @user.save
        end
        
        redirect to("/login")
    else
        erb :signup
    end
   
end

get "/login" do
    erb :login
end

post "/login" do
    username = params[:username]
    password = params[:password]
    
    # Find user by username
    user = User.find_by(username: username)
    
    # Login or fail
    if user && (BCrypt::Password.new(user.password) == password)
        session[:user_id] = user.id
        redirect to("/")
    else
        @error_message = "Login failed."
        erb :login
    end
end

get "/logout" do
    session[:user_id] = nil
    redirect to("/")
end

get "/posts/new" do
    @post = Post.new
    erb :"posts/new"
end

post "/posts" do
    photo_url = params[:photo_url]
    
    # instantiate new Post
    @post = Post.new({photo_url: photo_url, user_id: current_user.id})
    
    #save
    if @post.save
        redirect to("/")
    else
        
        # print error messages
        @post.errors.full_messages.inspect
    end
end

get "/posts/:id" do
    @post = Post.find(params[:id])
    erb :"posts/show"
end

post "/comments" do
    # point values from params to variables
    text = params[:text]
    post_id = params[:post_id]
    
    # instantiate a comment with those values & assign the comment to the current user
    comment = Comment.new({ text: text, post_id: post_id, user_id: current_user.id })
    
    # save
    comment.save
    
    redirect(back)
end

post "/likes" do
    post_id = params[:post_id]
    
    like = Like.new({ post_id: post_id, user_id: current_user.id })
    
    like.save
    
    redirect(back)
end

delete "/likes/:id" do
    like = Like.find(params[:id])
    like.destroy
    redirect(back)
end

not_found do
    status 404
    erb :oops
end