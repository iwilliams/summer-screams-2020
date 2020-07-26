extends RigidBody

#func _ready():
#    self.connect("body_entered", self, "_thud")
#
#var local_collision_pos
#
#func _thud(body):
##    $ThudPlayer.transform.origin = local_collision_pos
#    $ThudPlayer.play(0)
#
#func _integrate_forces(state: PhysicsDirectBodyState):
#    if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
#        local_collision_pos = state.get_contact_local_position(state.get_contact_count()-1)
#        if state.get_contact_collider_object(state.get_contact_count()-1) is StaticBody:
#            local_collision_pos -= translation
#        else:
#            local_collision_pos *= -1
#        var thud_player = $ThudPlayer
#        thud_player.transform.origin = local_collision_pos
