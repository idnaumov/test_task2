local connect;

addEventHandler( "onResourceStart", resourceRoot,
	function()
		connect = dbConnect ( "mysql", "dbname=testdb;host=127.0.0.1;charset=utf8", "root", "" );
		
		dbExec( connect, "CREATE TABLE IF NOT EXISTS users ( id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32),  last_name VARCHAR(32), address VARCHAR(100))");
	end
);

addEvent( "onPlayerRequestListUsers", true );
addEventHandler( "onPlayerRequestListUsers", root,
	function()
		dbQuery( function( query, source )
			local result = dbPoll( query, 0 );
			
			triggerClientEvent( source, "onClientReciveUsers", source, result );
		end, { client }, connect, "SELECT id, name, last_name, address FROM users" );
	end
);

addEvent( "onPlayerSearch", true );
addEventHandler( "onPlayerSearch", root,
	function( sQuery, pQuery )
		dbQuery( function( query, source )
			local result = dbPoll( query, 0 );
			
			triggerClientEvent( source, "onClientReciveUsers", source, result );
			print( sQuery..' - '..pQuery )
		end, { client }, connect, sQuery, pQuery);
	end
);

addEvent( "onPlayerAddUser", true );
addEventHandler( "onPlayerAddUser", root,
	function( user )
		dbQuery( function( query, source )
			local _, _, id = dbPoll( query, 0 );
			
			user.id = id;
			
			triggerClientEvent( source, "onClientAddUserCrud", source, user );
		end, { client }, connect, "INSERT INTO users (name, last_name, address) VALUES ( ?, ?, ? )", user.name, user.last_name, user.address );
	end
);

addEvent( "onPlayerRemoveUser", true );
addEventHandler( "onPlayerRemoveUser", root,
	function( user )
		dbQuery( function( query, source )
			triggerClientEvent( source, "onClientRemoveUserCrud", source, user );
		end, { client }, connect, "DELETE FROM users WHERE id = ? LIMIT 1", user.id );
	end
);

addEvent( "onPlayerEditUser", true );
addEventHandler( "onPlayerEditUser", root,
	function( user )
		dbQuery( function( query, source )	
			triggerClientEvent( source, "onClientEditUserCrud", source, user );
		end, { client }, connect, "UPDATE users SET name = ?, last_name = ?, address = ? WHERE id = ?", user.name, user.last_name, user.address, user.id );
	end
);