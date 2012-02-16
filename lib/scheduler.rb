class Scheduler
  attr_accessor :valid_schedules

  def initialize(user_courses)
    @courses = []
    user_courses.each do |course|
      @courses << Register_Course.new(course)
    end
  end

  def schedule_all
    @valid_schedules = []
    schedule_all_recursive(0, [])
  end

  # Brute force recurses through all course configurations
  # Generates a schedule for each course configuration
  def schedule_all_recursive(course_index, permuation)
    if course_index == @courses.size
      schedule_permutation(permutation)
      return
    end
    course = @courses[course_index]
    course.configurations_array.each do |configuration| #TODO: redo course configuration fetching
      permutation.push(configuration)
      initialize_configuration_permutations(course_index+1)
      permutation.pop
    end
  end

  def schedule_permutation(permutation)
    domains = []
    permutation.each do |configuration|
      configuration.each do |packages|
        domains << packages
      end
    end
    @constraints = make_constraints(domains)
    ac3(domains) #run ac3 once to remove all conflicts from domains
    domains.sort!(|x,y| x.size <=> y.size) #smaller domains are easier to schedule
    success = ac3_DFS(0, domains) #run the ac3 DFS to guess and check our way to a valid schedule
    @valid_schedules << domains if success
  end

  def ac3_DFS(index, domains)
    return true if index >= domains.size
    return ac3_DFS(index+1, domains) if domains[index].size == 1 #this may be a problem, not sure
    domains[index].each do |package|
      domains_copy = domains.clone
      domains_copy[index] = [package]
      if ac3(domains_copy)
        return true if ac3_DFS(cell+1, domains_copy)
      end
    end
    return false
  end

  def ac3(domains)
    constraints = @constraints.clone
    while not constraints.empty? do
      #pop off a constraint from the list
			constraint = constraints.values.first
      constraints.delete(constraint.key)
      
			if (revise(constraint, domains))
				if domains[constraint.a1].empty?
					return false
				end
        #loop through all neighbors, should be all other nodes
        for z in 0...domains.size do
					if z != constraint.a1 and z != constraint.a2
            neighbor_constraint = Arc.new(constraint.a1, z)
            constraints[neighbor_constraint.key] = neighbor_constraint
					end
				end
		  end
    end
		return true    
  end

  def reduce(constraint, domains)
		revised = false
		if domains[constraint.a1].size == 1
			package = domains[constraint.a1][0]
		  revised = true if domains[constraint.a2].delete_if{|x| x.conflict package} #TODO: make a package conflict
		end
		return revised
  end

  make_constraints(domains)
    constraints = {}
    for i in 0...domains.size do
      for j in (i+1)...domains.size do
        constraint = Arc.new(i,j)
        constraints[constraint.key] = constraint
      end
    end
    return constraints
  end
end
