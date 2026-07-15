package Action

import Entity "../entity"
import Map "../map"
import Log "core:log"

ActionBase :: struct {
	entity: ^Entity.Entity,
}

Movement :: struct #all_or_none {
	using base: ActionBase,
	dx, dy: int,
	gameMap: ^Map.Map
}

Action :: union {
	Movement,
}

execute :: proc(action: Action) {
	switch a in action {
	case Movement:
		_executeMovement(a)
	}
}

_executeMovement :: proc(m: Movement) {
	
	tileIsSolid, foundTile := Map.isTileSoild(m.gameMap, m.entity.x + m.dx, m.entity.y + m.dy)

	if(!foundTile){
		Log.debug("Could not find if tile was solid")
	}
	
	if(tileIsSolid){
		return
	}

	Entity.move(m.entity, m.dx, m.dy)
}
