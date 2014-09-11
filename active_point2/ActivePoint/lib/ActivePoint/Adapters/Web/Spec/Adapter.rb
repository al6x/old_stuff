class Adapter < WComponent
	extend Injectable
	inject :window => Window
	children :window		
end