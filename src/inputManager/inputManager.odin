package InputManager

import "vendor:raylib"

Action :: enum {
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

InputManager :: struct {
	bindings:     [Action]InputSource,
	states:       [Action]KeyState,
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
}

update :: proc(im: ^InputManager) {
	im.mouse_pos    = raylib.GetMousePosition()
	im.mouse_delta  = raylib.GetMouseDelta()
	im.mouse_scroll = raylib.GetMouseWheelMove()

	for action in Action {
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
	}
}

rebind :: proc(im: ^InputManager, action: Action, source: InputSource) {
	im.bindings[action] = source
}

isPressed :: proc(im: ^InputManager, action: Action) -> bool {
	return im.states[action] == .Pressed
}

// True on the frame pressed and while held
isDown :: proc(im: ^InputManager, action: Action) -> bool {
	state := im.states[action]
	return state == .Down || state == .Pressed
}

isReleased :: proc(im: ^InputManager, action: Action) -> bool {
	return im.states[action] == .Released
}

isUp :: proc(im: ^InputManager, action: Action) -> bool {
	state := im.states[action]
	return state == .Up || state == .Released
}
