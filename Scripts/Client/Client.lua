local screen = Vector2( guiGetScreenSize() );

local events = {};

function AddRPCEvent( event, callback )
	addEventHandler( event, resourceRoot, callback );
	
	table.insert( events, { event, resourceRoot, callback } );
end

function RemoveEvents()
	for i, v in ipairs( events ) do
		removeEventHandler( unpack( v ) );
	end
	
	events = {};
end

function ServerCall( event, args )
	triggerServerEvent( event, resourceRoot, args or {} );
end