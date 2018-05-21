class Toolpath < ApplicationRecord

  belongs_to :user


  def self.calc_trajectory(segments, metadata)
    previous_waypoint = nil

    segments.map do |segment|
      waypoint_start = previous_waypoint.nil? ? rotations(segment[:waypoints].first[1][:rotations]) : previous_waypoint
      waypoint_last = rotations(segment[:waypoints].last[1][:rotations])

      if segment[:waypoints].count == 2
        res = linear_step(waypoint_start, waypoint_last, segment[:speed], metadata)
      elsif segment[:waypoints].count == 3
        waypoint_middle = rotations(segment[:waypoints][1][1][:rotations])
        res = cubic_step(waypoint_start, waypoint_middle, waypoint_last, segment[:speed], segment[:weight], metadata)
      end

      previous_waypoint = nil

      if res.length > 0
        last_waypoint = res[res.length - 1]
        if last_waypoint[:success]
          previous_waypoint = last_waypoint.slice(:a0, :a1, :a2, :a3, :a4, :a5).values
        end
      end

      res
    end
  end


  private

  def self.linear_step(waypoint_start, waypoint_last, segment_speed, metadata)
    motion_plan = MotionPlan.linear_cartesian_step(waypoint_start, waypoint_last, segment_speed * metadata["speed"])
    down_sample(motion_plan)
  end

  def self.cubic_step(waypoint_start, waypoint_middle, waypoint_last, segment_speed, segment_weight, metadata)
    motion_plan = MotionPlan.cubic_cartesian_step(waypoint_start, waypoint_middle, waypoint_last, segment_weight, segment_speed * metadata["speed"])
    down_sample(motion_plan)
  end

  def self.down_sample(motion_plan)
    i = 0
    last = motion_plan.length - 1
    motion_plan.select do |item|
      keep = false
      if i == 0 || i == last
        keep = true
      else
        keep = !item[:success] || i % 20 == 0
      end
      i += 1
      keep
    end
  end

  # Cast string rotations to floats
  def self.rotations(rotations)
    rotations.map{ |i| i.to_f }
  end



end
