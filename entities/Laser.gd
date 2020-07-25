tool
extends RigidBody


export(bool) var is_on = false
export(bool) var is_mirror = false

var thickness = .1
var last_collider: PhysicsBody = null
#onready var ig: ImmediateGeometry = find_node("ImmediateGeometry")


func draw_face(ig: ImmediateGeometry, top_left: Vector3, bottom_right: Vector3):
    ig.set_uv(Vector2(0, 0))
    ig.add_vertex(top_left) # top left
    ig.set_uv(Vector2(1, 0))
    ig.add_vertex(Vector3(bottom_right.x, top_left.y, top_left.z)) # top right
    ig.set_uv(Vector2(1, 1))
    ig.add_vertex(bottom_right) # bottom right
    
    ig.set_uv(Vector2(0, 0))
    ig.add_vertex(top_left) # top left
    ig.set_uv(Vector2(1, 1))
    ig.add_vertex(bottom_right) # bottom right
    ig.set_uv(Vector2(0, 1))
    ig.add_vertex(Vector3(top_left.x, bottom_right.y, bottom_right.z)) # bottom left
    

func _process(delta):
    var ig = find_node("ImmediateGeometry")
#    var ray: RayCast = find_node("RayCast")
#    var end = ray.get_collision_point()
    
    var end = Vector3.INF
    var colliding_body
    for ray in [$NRaycast, $ERaycast, $SRaycast, $WRaycast]:
        var end_point = to_local((ray as RayCast).get_collision_point())
        if end_point.x < end.x:
            end = end_point
            colliding_body = (ray as RayCast).get_collider()
    
    end.z = 0
    end.y = 0

    if end.x == INF || end.x == 0:
        end.x = 10
    
    ig.clear()
#    if end && is_on:
    if is_on:
        ig.begin(Mesh.PRIMITIVE_TRIANGLES)
        ig.set_color(Color.red)
        draw_face(ig, Vector3(0, thickness, 0), Vector3(end.x, 0, thickness))
        draw_face(ig, Vector3(0, 0, thickness), Vector3(end.x, -thickness, 0))
        draw_face(ig, Vector3(end.x, thickness, 0), Vector3(0, 0, -thickness))
        draw_face(ig, Vector3(end.x, 0, -thickness), Vector3(0, -thickness, 0))
        ig.end()

        
        $OmniLight.visible = true
        $OmniLight.transform.origin = end
    else:
        $OmniLight.visible = false
        
    if colliding_body:
        if is_on \
                && colliding_body.is_in_group("lasers") \
                && colliding_body.is_mirror \
                && !colliding_body.is_on:
            colliding_body.is_on = true
            
        if last_collider != null \
                && last_collider != colliding_body \
                && last_collider.is_in_group("lasers") \
                && last_collider.is_mirror \
                && last_collider.is_on:
            last_collider.is_on = false
        
        if last_collider == colliding_body \
                && colliding_body.is_in_group("lasers") \
                && colliding_body.is_on \
                && colliding_body.is_mirror \
                && !is_on:
            colliding_body.is_on = false
                
        last_collider = colliding_body
