class TasksController < ApplicationController
  before_filter :authenticate_user!
  def getOrder(list)
    case list.sortby
    when "priority"
      return "priority DESC"
    when "due"
      return "due DESC"
    else
      return "id ASC"
    end
  end

  def index
    case params[:list_id]
    when "all"
			@tasks=Array.new(1)
			current_user.lists.each do |list|
				@tasks=@tasks.concat(list.tasks)
			end
      @tasks=@tasks[1..-1]
    when "week"
      @tasks=Task.getByDate(current_user.lists,(Date.new(1)..Date.today()+7))
    when "today"
      @tasks=Task.getByDate(current_user.lists,(Date.new(1)..Date.today()))
    else
      @list= current_user.lists.find params[:list_id]
      @tasks = @list.tasks.order(getOrder(@list))
    end

    respond_to do |format|
      format.html { redirect_to list_path(@list) }
      format.json do
        #@tasks= @list.tasks
        render json: @tasks
      end
    end
  end
  # GET /tasks/1
  # GET /tasks/1.json
  def show
    self.init
    authorize! :read, @list
    authorize! :read, @task

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    self.init
    authorize! :read, @list
    authorize! :update, @task
  end

  def toggle_done
    @list = current_user.lists.find params[:list_id]
    @task = @list.tasks.find(params[:task_id])
    authorize! :read, @list
    authorize! :update, @task
    @task.done = !@task.done
    @task.save
    respond_to do |format|
      format.html {redirect_to list_path(@list)}
      format.json {render json: []}
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @list = current_user.lists.find params[:list_id]
    @task = @list.tasks.build(params[:task])
    authorize! :read, @list
    authorize! :create, @task

    respond_to do |format|
      if @task.save
        format.html { redirect_to @list, notice: I18n.t('tasks.create_success') }
        format.json { render json: @task, status: :created, location: list_task_path(@list, @task) }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    self.init
    authorize! :read, @list
    authorize! :update, @task

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to @list, notice: I18n.t('tasks.update_success') }
        format.json { render json: [] }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    begin
      @list = current_user.lists.find params[:list_id]
      @task = @list.tasks.find(params[:id])
    rescue
      current_user.lists.each do |list|
        begin
          @list=list
          @task = @list.tasks.find(params[:id])
          break
        rescue

        end
      end
    end
    #print '*'*50
    authorize! :read, @list
    authorize! :destroy, @task
    @task.destroy

    respond_to do |format|
      # format.html { render :test=>''}#redirect_to list_path(@list) }
      format.json { head :no_content }
    end
  end

  def init
    #@task=
    begin
      @list = current_user.lists.find params[:list_id]
      @task = @list.tasks.find(params[:id])
    rescue
      current_user.lists.each do |list|
        begin
          @list=list
          @task = @list.tasks.find(params[:id])
          break
        rescue

        end
      end
    end
  end
end
