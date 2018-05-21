class Segment

  def self.split_to_segments(waypoints)
    seg = []
    for i in 0..(waypoints.count - 2) do
      segment = { speed: 3.0, weight: 0.5, waypoints: [] }

      if waypoints[i][0].key?("nextSegment") && waypoints[i][0]["nextSegment"].key?("speed")
        segment[:speed] = waypoints[i][0]["nextSegment"]["speed"].to_f
      end

      if waypoints[i][1][:motion] == "linear" && waypoints[i+1][1][:motion] == "linear"
        segment[:waypoints] = [ waypoints[i] , waypoints[i+1] ]
      elsif waypoints[i][1][:motion] == "linear" && waypoints[i+1][1][:motion] == "interpolation" && i <= waypoints.count - 3
        segment[:waypoints] = [ waypoints[i] , waypoints[i+1] , waypoints[i+2] ]
        if waypoints[i+1][0].key?('weight')
          segment[:weight] = waypoints[i+1][0]['weight']
        end
      end

      seg << segment unless segment[:waypoints].empty?
    end
    seg
  end

end
