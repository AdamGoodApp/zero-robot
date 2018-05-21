class Scene

  attr_accessor :metadata, :waypoints, :timeline

  def initialize(toolpath)
    scene = JSON.parse(toolpath.scene)

    @metadata = scene["metadata"].nil? ? { "speed": "1" } : scene["metadata"]
    @waypoints = scene["waypoints"] || nil
    @timeline = scene["timeline"] || nil
  end

  # Check for a grid and set it up
  # Recives a Scene from the Toolpath Controller
  # Build Segments and Calculate toolpath trajectory
  def build_toolpath
    Grid.new(waypoints, timeline).grid_setup if grid?
    Toolpath.calc_trajectory(create_segments, metadata)
  end


  private

  # Split timeline waypoint data into segments
  def create_segments
    Segment.split_to_segments(build_waypoints)
  end

  # Merge @waypoints and @timeline data for waypoints
  def build_waypoints
    timeline_waypoints.map do |w|
      find_waypoint = waypoints[w["waypointId"]]
      motion = find_waypoint["type"] == 1 ? "linear" : "interpolation"

      [w, { motion: motion, rotations: find_waypoint["rotations"] }]
    end
  end

  #Find waypoints in Timeline and return an Array
  def timeline_waypoints
    timeline.find_all { |w| w["type"] == "waypoint" }
  end

  # Check to see if a Grid is in the timeline
  def grid?
    timeline.any? { |w| w["type"] == "grid" }
  end

end