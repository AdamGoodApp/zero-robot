module Api
  module V1
    class ToolpathsController < BaseController

      before_action :find_toolpath, except: [:show, :create, :calc_without_toolpath, :share]
      before_action :find_user, only: [:share]


      def show
        render json: { toolpaths: @user.toolpaths }
      end

      def create
        if toolpath = @user.toolpaths.create(name: toolpath_params[:name], scene: toolpath_params[:scene])
          RobotChannel.new_toolpath(@user, {id: toolpath.id, name: toolpath.name})
          render json: { id: toolpath.id, trajectory: build_scene(toolpath) }
        end
      end

      def update
        if @toolpath.update(toolpath_params)
          RobotChannel.updated_toolpath(@user, { id: @toolpath.id, name: @toolpath.name })
          render json: { toolpath: @toolpath, trajectory: build_scene(@toolpath) }
        end
      end

      def destroy
        if @toolpath.destroy
          RobotChannel.deleted_toolpath(@user, {id: @toolpath.id})
          render json: {success: "Deleted toolpath"}
        end
      end

      def build_trajectory
        render json: { toolpath: @toolpath, trajectory: build_scene(@toolpath) }
      end

      def calc_without_toolpath
        toolpath = Toolpath.new(scene: toolpath_params[:scene])
        render json: { trajectory: build_scene(toolpath) }
      end

      def share
        toolpath = @shared_user.copy_scene(toolpath_params)
        RobotChannel.shared_toolpath(@shared_user, {id: toolpath.id, name: toolpath.name, sharer: @user.name})
        toolpath
      end


      private

      def build_scene(toolpath)
        Scene.new(toolpath).build_toolpath
      end

      def find_toolpath
        @toolpath = @user.toolpaths.find_by_name(params[:toolpath_name]) || Toolpath.find(params[:id])
      end

      def find_user
        @shared_user = User.find(user_params.to_f)
      end

      def toolpath_params
        params.require(:toolpath).permit!
      end

      def user_params
        params.require(:to_user)
      end

    end
  end
end
