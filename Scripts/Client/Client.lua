local events = {};

function AddRPCEvent( event, callback )
	addEventHandler( event, root, callback );
	
	table.insert( events, { event, root, callback } );
end

function RemoveEvents()
	for i, v in ipairs( events ) do
		removeEventHandler( unpack( v ) );
	end
	
	events = {};
end

function ServerCall( event, args )
	triggerServerEvent( event, localPlayer, args or {} );
end
