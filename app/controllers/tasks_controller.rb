class TasksController < ApplicationController
  before_filter :authenticate_user!
  def index
    @list= current_user.lists.find params[:list_id]
    respond_to do |format|
      format.html { redirect_to list_path(@list) }
      format.json do
        @tasks= @list.tasks
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
    redirect_to list_path(@list)
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
        format.json { render json: @task, status: :created, location: @task }
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
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @list = current_user.lists.find params[:list_id]
    @task = @list.tasks.find(params[:id])
    authorize! :read, @list
    authorize! :destroy, @task
    @task.destroy

    respond_to do |format|
      format.html { redirect_to list_path(@list) }
      format.json { head :no_content }
    end
  end

  def init
    @list = current_user.lists.find params[:list_id]
    @task = @list.tasks.find(params[:id])
  end
end
