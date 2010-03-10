WINDOW = { width, height }

WINDOW.width, WINDOW.height = window.size()

function cameraToWindow()
	return { -WINDOW.width / 2, -WINDOW.height / 2, WINDOW.width / 2, WINDOW.height / 2 }
end

function updateWindow()
	WINDOW.width, WINDOW.height = window.size()
end

panels = { left = { width = 128, height = 768 }, right = { width = 32, height = 768 } }