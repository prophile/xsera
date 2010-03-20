WINDOW = { width, height }

WINDOW.width, WINDOW.height = window.size()

panels = { left = { width = 128, height = 768, center = { x = -WINDOW.width / 2, y = 0 } }, right = { width = 32, height = 768, center = { x = WINDOW.width / 2, y = 0 } } }

function CameraToWindow()
	return { -WINDOW.width / 2, -WINDOW.height / 2, WINDOW.width / 2, WINDOW.height / 2 }
end

function updateWindow()
	WINDOW.width, WINDOW.height = window.size()
	panels.left.center = { x = -WINDOW.width / 2 + panels.left.width / 2, y = 0 }
	panels.right.center = { x = WINDOW.width / 2 - panels.right.width / 2, y = 0 }
end