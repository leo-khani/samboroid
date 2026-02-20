extends RigidBody2D

# Gravity constant - Tweak this to change how strong gravity feels
const G = 500.0 

func _integrate_forces(state):
	# Calculate gravity manually
	var total_gravity = Vector2.ZERO
	var planets = get_tree().get_nodes_in_group("planets")

	# DEBUG: Print how many planets were found
	print("Planets found: ", planets.size()) 
	
	for planet in planets:
		var direction = planet.global_position - global_position
		var distance = direction.length()
		
		# Prevent dividing by zero or extreme forces if inside the planet
		# The 'radius' variable needs to be accessible from the planet script
		# For now, we use a safe minimum distance
		var safe_dist = max(distance, 30.0) 
		
		# Inverse Square Law: F = G * M / r^2
		var force_magnitude = G * planet.mass / (safe_dist * safe_dist)
		
		total_gravity += direction.normalized() * force_magnitude

	# Apply the force
	state.apply_central_force(total_gravity)