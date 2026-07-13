package InputManager

import "vendor:raylib"

InputAction :: enum {
	MoveUp,
	MoveDown,
	MoveLeft,
	MoveRight,
	Attack,
	Interact,
	Pause,
}

KeyState :: enum {
	Up,
	Pressed,
	Down,
	Released,
}

// A binding can be a keyboard key or mouse button
InputSource :: union {
	raylib.KeyboardKey,
	raylib.MouseButton,
}

REPEAT_INITIAL_DELAY :: 0.35 // seconds before first repeat
REPEAT_INTERVAL      :: 0.10 // seconds between subsequent repeats

InputManager :: struct {
	bindings:     [InputAction]InputSource,
	states:       [InputAction]KeyState,
	repeatable:   [InputAction]bool,
	repeat_timer: [InputAction]f32,
	mouse_pos:    raylib.Vector2,
	mouse_delta:  raylib.Vector2,
	mouse_scroll: f32,
}

init :: proc(im: ^InputManager) {
	im.bindings[.MoveUp]    = raylib.KeyboardKey.W
	im.bindings[.MoveDown]  = raylib.KeyboardKey.S
	im.bindings[.MoveLeft]  = raylib.KeyboardKey.A
	im.bindings[.MoveRight] = raylib.KeyboardKey.D
	im.bindings[.Attack]    = raylib.MouseButton.LEFT
	im.bindings[.Interact]  = raylib.KeyboardKey.E
	im.bindings[.Pause]     = raylib.KeyboardKey.ESCAPE

	im.repeatable[.MoveUp]    = true
	im.repeatable[.MoveDown]  = true
	im.repeatable[.MoveLeft]  = true
	im.repeatable[.MoveRight] = true
}

update :: proc(im: ^InputManager) {
	im.mouse_pos    = raylib.GetMousePosition()
	im.mouse_delta  = raylib.GetMouseDelta()
	im.mouse_scroll = raylib.GetMouseWheelMove()

	for action in InputAction {
		source := im.bindings[action]
		switch s in source {
		case raylib.KeyboardKey:
			switch {
			case raylib.IsKeyPressed(s):  im.states[action] = .Pressed
			case raylib.IsKeyDown(s):     im.states[action] = .Down
			case raylib.IsKeyReleased(s): im.states[action] = .Released
			case:                         im.states[action] = .Up
			}
		case raylib.MouseButton:
			switch {
			case raylib.IsMouseButtonPressed(s):  im.states[action] = .Pressed
			case raylib.IsMouseButtonDown(s):     im.states[action] = .Down
			case raylib.IsMouseButtonReleased(s): im.states[action] = .Released
			case:                                 im.states[action] = .Up
			}
		case:
			im.states[action] = .Up
		}

		switch im.states[action] {
		case .Pressed:
			im.repeat_timer[action] = REPEAT_INITIAL_DELAY
		case .Down:
			if im.repeatable[action] {
				im.repeat_timer[action] -= raylib.GetFrameTime()
			}
		case .Released, .Up:
			im.repeat_timer[action] = 0
		}
	}
}

rebind :: proc(im: ^InputManager, action: InputAction, source: InputSource) {
	im.bindings[action] = source
}

isPressed :: proc(im: ^InputManager, action: InputAction) -> bool {
	return im.states[action] == .Pressed
}

// True on the frame pressed and while held
isDown :: proc(im: ^InputManager, action: InputAction) -> bool {
	state := im.states[action]
	return state == .Down || state == .Pressed
}

isReleased :: proc(im: ^InputManager, action: InputAction) -> bool {
	return im.states[action] == .Released
}

isUp :: proc(im: ^InputManager, action: InputAction) -> bool {
	state := im.states[action]
	return state == .Up || state == .Released
}

// True on initial press, and periodically while held if the action is repeatable.
isTriggered :: proc(im: ^InputManager, action: InputAction) -> bool {
	if isPressed(im, action) do return true
	if im.repeatable[action] && isDown(im, action) && im.repeat_timer[action] <= 0 {
		im.repeat_timer[action] = REPEAT_INTERVAL
		return true
	}
	return false
}
