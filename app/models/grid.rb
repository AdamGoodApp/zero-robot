class Grid

  def initialize(waypoints, timeline)
    @waypoints = waypoints
    @timeline = timeline
  end

  def grid_setup
    timeline = @timeline.select { |w| w["type"] == "grid" }
    waypoints = []

    waypoints << timeline[0]["timeline"].find_all { |w| w["type"] == "waypoint" }
    waypoints << timeline[0]["w0"]
    waypoints << timeline[0]["wx"]
    waypoints << timeline[0]["wy"]

    calc_grid_waypoints(build_waypoints(waypoints.flatten))
  end

  private

  def build_waypoints(waypoints)
    waypoints.map do |w|
      id = w.is_a?(Hash) ? w["waypointId"] : w
      find_waypoint = @waypoints[id]
      motion = find_waypoint["type"] == 1 ? "linear" : "interpolation"

      [w, { motion: motion, rotations: find_waypoint["rotations"] }]
    end
  end

  # Calculate each waypoint in the grid defined by the number of cols and rows
  # Gridpoints 0,X,Y are defined by the last three waypoints in the Array
  def calc_grid_waypoints(waypoints)
    w0 = waypoints[-3]
    wx = waypoints[-2]
    wy = waypoints[-1]
  end


end